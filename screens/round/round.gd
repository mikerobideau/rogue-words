extends Control
class_name Round

signal game_over(message: String)
signal game_won()

const TURNS_PER_ROUND = 12
const DISCARDS_PER_ROUND = 3

signal completed()

@onready var hand = $BottomMargin/Hand
@onready var board = $BoardContainer/Board
@onready var word_finder = $WordFinder
@onready var scorer = $Scorer
@onready var top_container = $TopMargin/TopContainer
@onready var instruction = $TopMargin/TopContainer/Instruction
@onready var word = $TopMargin/TopContainer/Word
@onready var score_panel = $Left/ScorePanel
@onready var round_summary = $RoundSummary
@onready var token_bag = $TokenBag

var hud: Control
var relic_manager: Node
var scoring := false:
	set(v):
		scoring = v
		_update_instruction()
		
var active_item_slot: ItemSlot

var selected_tokens: Array[Token]:
	set(v):
		selected_tokens = v
		selected_token = selected_tokens[0] if selected_tokens.size() == 1 else null
		_update_discard_disabled()
		_update_instruction()

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
	_update_instruction()
	
	hud.relic_container.refresh_relics()
	hud.item_container.refresh_items()
	hud.item_container.item_use_requested.connect(_on_item_use_requested)
	
	round_summary.closed.connect(func(): completed.emit())
	
	#await get_tree().create_timer(0.0).timeout
	#_on_round_complete(RelicContext.new())
	
func _on_item_use_requested(slot: ItemSlot):
	active_item_slot = slot 
	
func _update_discard_disabled():
	hand.discard_button.disabled = discards_remaining == 0 or selected_tokens.size() < 1
	
func _update_instruction():
	if scoring:
		instruction.visible = false
		instruction.text = 'Scoring'
	elif selected_tokens.size() < 1:
		instruction.visible = true
		instruction.text = 'Choose a token'
	elif selected_tokens.size() == 1:
		instruction.visible = true
		instruction.text = 'Play or discard'
	elif selected_tokens.size() > 1:
		instruction.visible = true
		instruction.text = 'Discard all'
	else:
		instruction.visible = true
		instruction.text = 'Unhandled'
	
func _clear_selected_token():
	if selected_token:
		selected_token.selected = false
		selected_token = null
		
func _clear_selected_tokens():
	for token in selected_tokens:
		if is_instance_valid(token):
			token.selected = false
	selected_tokens = []
	_clear_selected_token()
	
func _on_discard_clicked():
	if selected_tokens.size() < 1:
		return
	var context = _get_relic_context()
	hand.discard(selected_tokens as Array[Token])
	discards_remaining -= 1
	context.discarded_tokens = selected_tokens
	relic_manager.on_discard(context)
	_clear_selected_tokens()

func _on_space_clicked(space: Space):
	#Process placement
	if scoring or not space.enabled or space.token != null or !selected_token:
		return
	scoring = true
	hand.remove_token(selected_token)
	board.place(selected_token, space)
	var context = _get_relic_context()
	await relic_manager.on_token_placed(context)
	selected_tokens.erase(selected_token)

	if space.token != null: #relic_manager.on_token_placed may destroy the token before it is scored
		var found_words = word_finder.find_words(space)
		var word_number = 1
		for found_word in found_words:
			var word_report = scorer.get_word_report(found_word)
			context.word = word_report.word
			context.word_score = word_report.score
			context.word_report = word_report
			var relic_report = await relic_manager.get_score_report(context)
			await word.play(word_report, relic_report, word_number > 3)
			await word.fly_tokens_to(score_panel.juice_target.global_position)
			score_panel.score += relic_report.new_score
			await get_tree().create_timer(0.5).timeout
			word_number += 1
		
		if score_panel.target_met():
			_on_round_complete(context)
			return
			
	#After turn
	turn_number += 1
	if turns_remaining < 1:
		game_over.emit('You ran out of turns')
		return
	await get_tree().create_timer(0.5).timeout
	_clear_selected_tokens()
	hand.draw_tokens(1)
	if hand.is_empty():
		game_over.emit('You ran out of tokens')
		return
	var expansions = board.NUM_EXPANSIONS + relic_manager.add_grow_amount(context)
	board.grow(expansions)
	scoring = false
	
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
			_clear_selected_tokens()
		else:
			#item is selected but can't be applied to token
			#auto-deselect item and select token
			_toggle_token_selection(token)
			hud.item_container.deselect()
	else:
		_toggle_token_selection(token)

func _on_token_destroyed(token: Token):
	var context = _get_relic_context()
	context.destroyed_token = token.data
	relic_manager.on_token_destroyed(context)

func _apply_item(item_data: ItemData, token: Token):
	item_data.enhance_token(token)
	_clear_selected_token()
	GameState.remove_item(item_data)
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
	context.relics = hud.get_relics()
	context.placed_token = selected_token
	context.hand = hand.get_hand()
	context.turn_number = turn_number
	context.tokens = GameState.tokens
	return context

func _on_bag_button_pressed() -> void:
	token_bag.toggle()
