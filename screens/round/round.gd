extends Control
class_name Round

signal game_over(message: String)

const TURNS_PER_ROUND = 12
const DISCARDS_PER_ROUND = 2

signal completed()

const DEBUG = false

@onready var sound = $Sound
@onready var score_panel = $ScorePanelMargin/ScorePanel
@onready var hand = $HandContainer/Hand
@onready var board = $MarginContainer/Board
@onready var word_finder = $WordFinder
@onready var scorer = $Scorer
@onready var relic_manager = $"../RelicManager"
@onready var item_manager = $"../ItemManager"
@onready var relic_container = $RelicMarginContainer/RelicContainer
@onready var item_container = $Inventory/ItemContainer
@onready var animator = $ScoringAnimator
@onready var word = $WordContainer/Word
@onready var word_score = $WordContainer/WordScore
@onready var discard_ui = $BottomRight/HBoxContainer/DiscardUi
@onready var turns_remaining_label = $BottomRight/HBoxContainer/TurnsRemaining

var selected_tokens: Array[Token]
var selected_token: Token
var discard_mode := false:
	set(v):
		discard_mode = v
		_clear_selected_token()
		_clear_selected_tokens()
		_clear_selected_item()
		
var selected_item: Item
var discards_remaining: int:
	set(v):
		discards_remaining = v if v >= 0 else 0
		discard_ui.discard_text = 'DISCARD (' + str(v) + ')'
		if discards_remaining < 1:
			discard_ui.discard_disabled = true
			
var turns_remaining := TURNS_PER_ROUND:
	set(v):
		turns_remaining = clamp(v, 0, INF)
		turns_remaining_label.text = str(turns_remaining) + ' turns remaining'

func _ready():
	if DEBUG:
		_debug()
	turns_remaining = TURNS_PER_ROUND
	hand.on_round_start()
	discards_remaining = GameState.current_boss.get_discards(DISCARDS_PER_ROUND)
	GameState.discarded_tokens = [] as Array[TokenData]
	relic_container.setup(GameState.relics)
	item_container.setup(GameState.items)
	item_container.item_selected.connect(_on_item_selected)
	word_finder.relic_manager = relic_manager
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	score_panel.round_number = GameState.round_number
	hand.token_clicked.connect(_on_token_clicked)
	board.space_clicked.connect(_on_space_clicked)	
	score_panel.target_score = GameState.target_score
	discard_ui.discard_clicked.connect(_on_discard_clicked)
	discard_ui.cancel_discard_clicked.connect(_on_cancel_discard_clicked)
	discard_ui.confirm_discard_clicked.connect(_on_confirm_discard_clicked)
	
func _clear_selected_token():
	if selected_token:
		selected_token.selected = false
		selected_token = null

func _clear_selected_item():
	if selected_item:
		selected_item.selected = false
		selected_item = null
		
func _clear_selected_tokens():
	for token in selected_tokens:
		token.selected = false
	selected_tokens = []
	
func _on_discard_clicked():
	discard_mode = true
	discard_ui.confirm_disabled = true
	discard_ui.confirm_text = 'DISCARD'
	
func _on_cancel_discard_clicked():
	discard_mode = false
	
func _on_confirm_discard_clicked():
	hand.discard(selected_tokens)
	discards_remaining -= 1
	discard_mode = false

func _on_space_clicked(space: Space):
	if space.token != null or !selected_token:
		return
	hand.remove_token(selected_token)
	board.place(selected_token, space)
	var context = _get_relic_context()
	relic_manager.on_token_placed(context)
	selected_token.selected = false
	selected_token = null
	var found_words = word_finder.find_words(space)
	for found_word in found_words:
		var word_report = scorer.get_word_report(found_word)
		context.word = word_report.word
		context.word_score = word_report.score
		var relic_report = relic_manager.get_score_report(context)
		await score_panel.play_word(word_report, relic_report)
		
	await get_tree().create_timer(0.5).timeout
	score_panel.clear_words()
	
	if score_panel.target_met():
		completed.emit()
		return
	turns_remaining -= 1
	if turns_remaining < 1:
		game_over.emit('You ran out of turns')
		return
	hand.draw_tokens(1)
	if hand.is_empty():
		game_over.emit('You ran out of tokens')
		return
	var expansions = board.NUM_EXPANSIONS + relic_manager.add_grow_amount(context)
	board.grow(expansions)
	
func _path_to_word(path: Array):
	var word := ""
	for p in path:
		word += p.token.letter
	return word
	
func _on_item_selected(item: Item):
	selected_token = null
	var prev_selected = selected_item
	selected_item = null if selected_item == item else item
	if prev_selected != null and prev_selected != selected_item:
		prev_selected.selected = false
	item.selected = item == selected_item
			
func _on_token_clicked(token: Token):
	if discard_mode:
		if token in selected_tokens:
			selected_tokens.erase(token)
			token.selected = false
		else:
			selected_tokens.append(token)
			token.selected = true
		discard_ui.confirm_text = 'DISCARD ' + str(selected_tokens.size()) if selected_tokens.size() > 0 else 'DISCARD'
		discard_ui.confirm_disabled = selected_tokens.size() < 1
		return
		
	if selected_item:
		if selected_item.data.can_enhance_token:
			selected_item.data.enhance_token(token)
			selected_item.selected = false
			selected_item.played.emit(selected_item)
			_clear_selected_token()
			_clear_selected_item()
			return
	
	var prev_selected = selected_token
	selected_token = null if selected_token == token else token
	if prev_selected != null and prev_selected != selected_token:
		prev_selected.selected = false
	token.selected = token == selected_token

func _get_relic_context():
	var context = RelicContext.new()
	context.relics = relic_container.get_relics()
	context.state = GameState
	context.placed_token = selected_token
	return context

func _on_no_tokens_remaining():
	game_over.emit('You ran out of tokens')

#---debug---

func _debug():
	var line = Line2D.new()
	var center_x = get_viewport().get_visible_rect().size.x / 2
	line.add_point(Vector2(center_x, 0))
	line.add_point(Vector2(center_x, get_viewport().get_visible_rect().size.y))
	line.default_color = Color.WEB_GRAY
	line.width = 2
	add_child(line)
