extends Control
class_name Round

signal game_over(message: String)

const TURNS_PER_ROUND = 10
const DISCARDS_PER_ROUND = 2

signal completed()

const DEBUG = false

@onready var hand = $HandContainer/Hand
@onready var board = $Board
@onready var word_finder = $WordFinder
@onready var scorer = $Scorer
@onready var word = $WordContainer/Word
@onready var score_panel = $Left/CenterContainer/ScorePanel

var hud: Control
var relic_manager: Node
var scoring := false
var active_item_slot: ItemSlot

var selected_tokens: Array[Token]:
	set(v):
		selected_tokens = v
		selected_token = selected_tokens[0] if selected_tokens.size() == 1 else null
		_update_discard_disabled()

var selected_token: Token
		
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
	if DEBUG:
		_debug()
	hand.on_round_start()
	turn_number = 1
	discards_remaining = GameState.current_boss.get_discards(DISCARDS_PER_ROUND)
	GameState.discarded_tokens = [] as Array[TokenData]
	word_finder.relic_manager = relic_manager
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hand.token_clicked.connect(_on_token_clicked)
	board.space_clicked.connect(_on_space_clicked)	
	hand.discard_clicked.connect(_on_discard_clicked)
	score_panel.score = 0
	score_panel.target_score = GameState.target_score
	hud.relic_container.refresh_relics()
	hud.item_container.refresh_items()
	hud.item_container.item_use_requested.connect(_on_item_use_requested)
	
func _on_item_use_requested(slot: ItemSlot):
	active_item_slot = slot 
	
func _update_discard_disabled():
	hand.discard_button.disabled = discards_remaining == 0 or selected_tokens.size() < 1
	
func _clear_selected_token():
	if selected_token:
		selected_token.selected = false
		selected_token = null

func _clear_selected_item():
	hud.item_container.deselect()
		
func _clear_selected_tokens():
	for token in selected_tokens:
		token.selected = false
	selected_tokens = []
	
func _on_discard_clicked():
	if selected_tokens.size() < 1:
		return
	hand.discard(selected_tokens as Array[Token])
	discards_remaining -= 1
	_clear_selected_tokens()

func _on_space_clicked(space: Space):
	#Process placement
	if scoring or space.token != null or !selected_token:
		return
	scoring = true
	hand.remove_token(selected_token)
	board.place(selected_token, space)
	var context = _get_relic_context()
	await relic_manager.on_token_placed(context)
	selected_tokens.erase(selected_token)
	
	#Scoring
	if !selected_token.is_queued_for_deletion(): #on_token_placed can destroy the token, in which case scoring must be skipped
		var found_words = word_finder.find_words(space)
		for found_word in found_words:
			var word_report = scorer.get_word_report(found_word)
			context.word = word_report.word
			context.word_score = word_report.score
			context.word_report = word_report
			var relic_report = relic_manager.get_score_report(context)
			await word.play(word_report, relic_report)
			score_panel.score += relic_report.new_score
			
		await get_tree().create_timer(0.5).timeout
		
		if score_panel.target_met():
			_on_round_complete(context)
			return
			
	#After turn
	turn_number += 1
	if turns_remaining < 1:
		game_over.emit('You ran out of turns')
		return
	hand.draw_tokens(1)
	if hand.is_empty():
		game_over.emit('You ran out of tokens')
		return
	var expansions = board.NUM_EXPANSIONS + relic_manager.add_grow_amount(context)
	board.grow(expansions)
	scoring = false
	
func _on_round_complete(context: RelicContext):
	Sound.play('win')
	relic_manager.on_round_complete(context)
	await get_tree().create_timer(1.0).timeout
	completed.emit()
	return
	
func _path_to_word(path: Array):
	var word := ""
	for p in path:
		word += p.token.letter
	return word
			
func _on_token_clicked(token: Token):
	if scoring: 
		return
	if active_item_slot:
		var item_data = active_item_slot.item_data
		if item_data and item_data.can_enhance_token:
			await active_item_slot.animate_and_consume(token)
			_apply_item(item_data, token)
			active_item_slot = null
		else:
			#item is selected but can't be applied to token
			#auto-deselect item and select token
			_toggle_token_selection(token)
			hud.item_container.deselect()
	else:
		_toggle_token_selection(token)

func _apply_item(item_data: ItemData, token: Token):
	item_data.enhance_token(token)
	#selected_item.played.emit(selected_item)
	_clear_selected_token()
	return

func _toggle_token_selection(token: Token):
	token.selected = not token.selected
	if token.selected:
		var addition: Array[Token] = [token]
		selected_tokens = selected_tokens + addition
	else:
		var filtered: Array[Token] = []
		filtered.assign(selected_tokens.filter(func(t): return t != token))
		selected_tokens = filtered

func _get_relic_context():
	var context = RelicContext.new()
	context.state = GameState
	context.relics = hud.get_relics()
	context.placed_token = selected_token
	context.hand = hand.get_hand()
	context.turn_number = turn_number
	return context

#---debug---

func _debug():
	var line = Line2D.new()
	var center_x = get_viewport().get_visible_rect().size.x / 2
	line.add_point(Vector2(center_x, 0))
	line.add_point(Vector2(center_x, get_viewport().get_visible_rect().size.y))
	line.default_color = Color.WEB_GRAY
	line.width = 2
	add_child(line)
