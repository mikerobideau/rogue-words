extends Control
class_name Round

var ScoreToastScene = preload("res://components/score_toast/score_toast.tscn")
var WordScene = preload("res://components/scorer/word.tscn")
var WordScoreScene = preload("res://components/scorer/word_score.tscn")

signal completed()

const DEBUG = false

@export var target_score := 100

@onready var round_label = $Control/HBoxContainer/RoundLabel
@onready var hand = $HandContainer/Hand
@onready var board = $MarginContainer/Board
@onready var word_finder = $WordFinder
@onready var scorer = $Scorer
@onready var score = $TopRight/Score
@onready var relic_manager = $"../RelicManager"
@onready var item_manager = $"../ItemManager"
@onready var relic_container = $RelicMargin/Center/RelicContainer
@onready var item_container = $Inventory/ItemContainer
@onready var animator = $ScoringAnimator
@onready var word = $WordMargin/Center/Word
@onready var word_score = $WordScoreMargin/Center/WordScore

var selected_token: Token
var selected_item: Item

func _ready():
	if DEBUG:
		_debug()
	relic_container.setup(relic_manager.active_relics)
	item_container.setup(item_manager.active_items)
	item_container.item_selected.connect(_on_item_selected)
	word_finder.relic_manager = relic_manager
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	#round_label.text = 'Round ' + str(GameState.round_number)
	hand.token_clicked.connect(_on_token_clicked)
	board.space_clicked.connect(_on_space_clicked)	
	score.target_score = target_score

func _on_space_clicked(space: Space):
	if !selected_token:
		return
	hand.remove_token(selected_token)
	board.place(selected_token, space)
	var context = _get_relic_context()
	relic_manager.on_token_placed(context)
	selected_token.selected = false
	selected_token = null
	
	#var all_relic_events = [] 
	
	var found_words = word_finder.find_words(space)
	for found_word in found_words:
		var word_report = scorer.get_word_report(found_word)
		
		#scale up
		for letter_report in word_report.letter_reports:
			letter_report.space.token.scale_up()
		
		for letter_report in word_report.letter_reports:
			var token = letter_report.space.token
			word.add_token(token)
			#token.pulse(0.3)
			word_score.add(letter_report.score)
			await get_tree().create_timer(0.3).timeout
		await get_tree().create_timer(0.3).timeout
		word.clear()
		word_score.clear()
		
		#scale down
		for letter_report in word_report.letter_reports:
			letter_report.space.token.scale_down()
		
		await get_tree().create_timer(0.3).timeout
		
		
		#for letter_report in word_report.letter_reports:
		#	print_debug(letter_report.letter + ' - ' + str(letter_report.score) + ' ' + letter_report.bonus_label)
		#print_debug(word_report.word + ' ' + str(word_report.score))

		#var event = scorer.score(result)	
		#result.event = event
		#context.score_event = event
		
		#for s in result.path:
		#	var token = s.token
		#	var letter = token.letter
		#	word.add_letter(letter)
		#	token.pulse(0.3)
		#	word_score.add(token.value)
		#	await get_tree().create_timer(0.3).timeout
		#word.clear()
		#word_score.clear()
		#await get_tree().create_timer(0.3).timeout
		
		#var relic_results = relic_manager.on_score_event(context)
		#all_relic_events.append(relic_results)
		
		#var triggered = relic_manager.on_score_event(context)
		#var toast = ScoreToastScene.instantiate()
		#toast.text = str(context.score_event.score) + ' - ' + context.score_event.word
		#board.highlight(word.path)
		#add_child(toast)
		#await toast.animate()
		
	#print_debug(str(results.size()))
	#if results.size() > 0:
	#	await animator.play(results, all_relic_events)
		
	var expansions = 3 + relic_manager.add_grow_amount(context)
	board.grow(expansions)
	var is_round_complete = _check_round_complete()
	if !is_round_complete:
		hand.draw_tokens(1)
		
func _check_round_complete():
	if score.value >= score.target_score:
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
	if selected_item:
		if selected_item.data.can_enhance_token:
			selected_item.data.enhance_token(token)
			selected_item.selected = false
			selected_item.played.emit(selected_item)
			selected_item = null
			selected_token = null
			return
		else:
			selected_item = null
	
	var prev_selected = selected_token
	selected_token = null if selected_token == token else token
	if prev_selected != null and prev_selected != selected_token:
		prev_selected.selected = false
	token.selected = token == selected_token

func _get_relic_context():
	var context = RelicContext.new()
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
