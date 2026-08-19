extends Control
class_name Round

signal game_over(message: String)
signal game_won()

const TilePopupScene = preload('res://components/ui/popup_box/tile_score_popup.tscn')
const TURNS_PER_ROUND = 12
const DISCARDS_PER_ROUND = 3

signal completed()

@onready var hand = $BottomMargin/Hand
@onready var board = $BoardContainer/Board
@onready var word_finder = $WordFinder
@onready var scorer = $Scorer
@onready var top_container = $TopMargin/TopContainer
@onready var word_target = $WordTarget
@onready var score_panel = $Left/ScorePanel
@onready var round_summary = $RoundSummary
@onready var token_bag = $TokenBag

var hud: Control
var relic_manager: Node
var scoring := false:
	set(v):
		scoring = v

var selected_token: Token:
	set(v):
		if selected_token:
			selected_token.selected = false
		selected_token = v
		if v:
			v.selected = true
		hud.item_container.token_selected = v != null
		
var discards_remaining: int:
	set(v):
		discards_remaining = v if v >= 0 else 0
		hand.discard_button.label_text = str(discards_remaining)
		_update_discard_disabled()
	
var turn_number: int:
	set(v):
		turn_number = v
		turns_remaining = TURNS_PER_ROUND - (turn_number - 1)
			
var turns_remaining := TURNS_PER_ROUND:
	set(v):
		turns_remaining = clamp(v, 0, INF)
		score_panel.turns_remaining = str(turns_remaining)

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	turn_number = 1
	discards_remaining = GameState.current_boss.get_discards(DISCARDS_PER_ROUND)
	
	hand.hand_size = GameState.current_boss.get_hand_size(hand.DEFAULT_HAND_SIZE)
	hand.token_clicked.connect(_on_token_clicked)
	hand.token_destroyed.connect(_on_token_destroyed)
	hand.discard_clicked.connect(_on_discard_clicked)
	hand.slide_in()
	hand.on_round_start()
	
	GameState.discarded_tokens = [] as Array[TokenData]
	
	word_finder.relic_manager = relic_manager
	word_finder.min_word_length = GameState.current_boss.get_min_word_length(word_finder.DEFAULT_MIN_WORD_LENGTH)
	
	board.max_spaces = board.num_starting_spaces + TURNS_PER_ROUND - 1
	board.space_clicked.connect(_on_space_clicked)
	board.space_hovered.connect(_on_space_hovered)
	board.num_starting_spaces = GameState.current_boss.get_starting_board_size(board.DEFAULT_NUM_STARTING_SPACES)
	board.start()
	
	score_panel.score = 0
	score_panel.target_score = GameState.target_score
	score_panel.slide_in()
	
	top_container.slide_in()
	
	hud.relic_container.refresh_relics()
	hud.item_container.refresh_items()
	hud.item_container.item_use_requested.connect(_on_item_use_requested)
	
	round_summary.closed.connect(func(): completed.emit())
	
	#await get_tree().create_timer(0.0).timeout
	#_on_round_complete(RelicContext.new())
	
func _on_item_use_requested(slot: ItemSlot):
	if scoring or selected_token == null:
		return
	var token := selected_token
	var item_data := slot.item.data
	await slot.animate_and_consume(token)
	_apply_item(item_data, token)
	selected_token = null
	
func _update_discard_disabled():
	hand.discard_button.disabled = discards_remaining == 0
	
func _on_discard_clicked():
	var selected_tokens = hand.all_tokens()
	var context = _get_relic_context()
	hand.discard(selected_tokens as Array[Token])
	discards_remaining -= 1
	context.discarded_tokens = selected_tokens
	relic_manager.on_discard(context)

func _on_space_clicked(space: Space):
	#Process placement
	if scoring or not space.enabled or space.token != null or !selected_token:
		return
	scoring = true
	hand.remove_token(selected_token)
	board.place(selected_token, space)
	var context = _get_relic_context()
	await relic_manager.on_token_placed(context)
	selected_token = null

	if space.token != null: #relic_manager.on_token_placed may destroy the token before it is scored
		var found_words = word_finder.find_words(space)
		
		await _score_words(found_words, context, space)
		
		if score_panel.target_met():
			_on_round_complete(context)
			return
			
	#After turn
	turn_number += 1
	if turns_remaining < 1:
		game_over.emit('You ran out of turns')
		return
	await get_tree().create_timer(1.0).timeout
	hand.draw_tokens(1)
	if hand.is_empty():
		game_over.emit('You ran out of tokens')
		return
	var expansions = board.NUM_EXPANSIONS + relic_manager.add_grow_amount(context)
	board.grow(expansions)
	scoring = false

func _score_words(found_words: Array, context: RelicContext, space: Space):
	for found_word in found_words:
		context.word = found_word["word"]
		await relic_manager.before_score(context)
		var word_score = scorer.score_word(found_word, context)
		await _animate_word(word_score, context, space)
		score_panel.score += word_score.total
		
func _animate_word(word_score: WordScore, context: RelicContext, space: Space):
	var word_popup = await ScorePopup.spawn(ScorePopup.Template.WORD, word_score.word, word_target)
	var popups := {}
	var max_beats := 0
	for tile in word_score.tiles:
		tile.space.play_glow()
		var tile_popup = TilePopupScene.instantiate()
		await ScorePopup.pin_node(tile_popup, tile.space, ScorePopup.Anchor.CENTER, 0, -60)
		popups[tile.space] = tile_popup
		max_beats = max(max_beats, tile.beats.size())

	for i in max_beats:
		var pulsed := {}
		for tile in word_score.tiles:
			if i < tile.beats.size():
				var beat = tile.beats[i]
				var popup = popups[tile.space]
				popup.set_base(beat['juice'])
				popup.set_mult(beat['mult'])
				if beat['relic'] != null:
					var node = beat['relic']
					if node and not pulsed.has(node):
						node.pulse()
						pulsed[node] = true
		Sound.play(Sound.SOUND_RELIC_SCORE if i > 0 else Sound.SOUND_TOKEN)
		await get_tree().create_timer(Settings.BEAT).timeout

	for popup in popups.values():
		popup.resolve()
	ScorePopup.dismiss(word_popup)
	await get_tree().create_timer(Settings.BEAT).timeout
	for tile in word_score.tiles:
		tile.space.play_default()
	_send_juice(popups.values())
	await get_tree().create_timer(Settings.BEAT).timeout

func _send_juice(popups: Array):
	var tweens: Array[Tween] = [] 
	for popup in popups:
		popup.top_level = true
		var t := create_tween()
		t.tween_property(popup, "global_position", score_panel.juice_target.global_position, Settings.BEAT).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		t.tween_callback(popup.queue_free)
		tweens.append(t)
	await tweens[0].finished
	
func _on_space_hovered(space: Space):
	if selected_token:
		if word_finder.forms_word(space, selected_token):
			space.activate()
	
func _on_round_complete(context: RelicContext):
	if GameState.round_number == GameState.num_rounds:
		game_won.emit()
		return
	Sound.play(Sound.SOUND_WIN)
	relic_manager.on_round_complete(context)
	for token in GameState.tokens:
		token.spent = false
	round_summary.visible = true
	await round_summary.play_turns_remaining(turns_remaining)
	await round_summary.play_discards_remaining(discards_remaining)
	await round_summary.play_interest(GameState.money, GameState.interest)
	round_summary.show_actions()

func _path_to_word(path: Array):
	var word := ''
	for p in path:
		word += p.token.letter
	return word
			
func _on_token_clicked(token: Token):
	if scoring:
		return
	_toggle_token_selection(token)

func _on_token_destroyed(token: Token):
	var context = _get_relic_context()
	context.destroyed_token = token.data
	relic_manager.on_token_destroyed(context)

func _apply_item(item_data: ItemData, token: Token):
	item_data.enhance_token(token)
	GameState.remove_item(item_data)
	selected_token = null

func _toggle_token_selection(token: Token):
	token.selected = not token.selected
	if token.selected:
		selected_token = token
	else:
		selected_token = null

func _get_relic_context():
	var context = RelicContext.new()
	context.relics = hud.get_relics()
	context.placed_token = selected_token
	context.hand = hand.get_hand()
	context.turn_number = turn_number
	context.tokens = GameState.tokens
	return context

func _on_bag_button_pressed() -> void:
	token_bag.toggle()
