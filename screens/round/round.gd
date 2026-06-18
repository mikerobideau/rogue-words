extends Control
class_name Round

var ScoreToastScene = preload("res://components/score_toast/score_toast.tscn")
var WordScene = preload("res://components/scorer/word.tscn")
var WordScoreScene = preload("res://components/scorer/word_score.tscn")

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
@onready var discard_ui = $DiscardUiContainer/DiscardUi

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

func _ready():
	if DEBUG:
		_debug()
	hand.on_round_start()
	discards_remaining = GameState.discards_per_round
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
	if !selected_token:
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
	
	if !_check_round_complete():
		var expansions = 3 + relic_manager.add_grow_amount(context)
		board.grow(expansions)
		hand.draw_tokens(1)

func _on_space_clicked_old(space: Space):
	var delay = 0.2
	if !selected_token:
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
		
		#scale up
		for letter_report in word_report.letter_reports:
			letter_report.space.token.scale_up()
		
		for letter_report in word_report.letter_reports:
			sound.play()
			var token = letter_report.space.token
			word.add_token(token)
			#token.pulse(0.3)
			word_score.add(letter_report.score)
			await get_tree().create_timer(delay).timeout
		context.word_score = word_score.score
		var relic_report = relic_manager.get_score_report(context)
		
		for report in relic_report.items:
			sound.play()
			report.relic.pulse()
			var toast = ScoreToastScene.instantiate()
			toast.text = report.text
			var x =  report.relic.global_position.x + report.relic.size.x / 2
			var y = report.relic.global_position.y + report.relic.size.y + 10
			toast.position = Vector2(x, y)
			add_child(toast)
			toast.animate()
			word_score.score = report.new_score
			await get_tree().create_timer(0.3).timeout
		
		await get_tree().create_timer(0.3).timeout
		word.clear()
		word_score.clear()
		print_debug('new score ' + str(relic_report.new_score))
		#score.value += relic_report.new_score
		
		for letter_report in word_report.letter_reports:
			letter_report.space.token.scale_down()
		
	var expansions = 3 + relic_manager.add_grow_amount(context)
	board.grow(expansions)
	var is_round_complete = _check_round_complete()
	if !is_round_complete:
		hand.draw_tokens(1)
		
func _check_round_complete():
	if score_panel.target_met():
		completed.emit()
	
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

#---debug---

func _debug():
	var line = Line2D.new()
	var center_x = get_viewport().get_visible_rect().size.x / 2
	line.add_point(Vector2(center_x, 0))
	line.add_point(Vector2(center_x, get_viewport().get_visible_rect().size.y))
	line.default_color = Color.WEB_GRAY
	line.width = 2
	add_child(line)
