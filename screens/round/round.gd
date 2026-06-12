extends Control
class_name Round

var ScoreToastScene = preload("res://components/score_toast/score_toast.tscn")
var WordScene = preload("res://components/scorer/word.tscn")
var WordScoreScene = preload("res://components/scorer/word_score.tscn")

signal completed()

@export var target_score := 100

@onready var round_label = $Control/HBoxContainer/RoundLabel
@onready var hand = $HandContainer/Hand
@onready var board = $Board
@onready var word_finder = $WordFinder
@onready var scorer = $Scorer
@onready var score = $TopRight/Score
@onready var relic_manager = $"../RelicManager"
@onready var item_manager = $"../ItemManager"
@onready var relic_container = $Inventory/RelicContainer
@onready var item_container = $Inventory/ItemContainer
@onready var animator = $ScoringAnimator
@onready var word = $WordMargin/Center/Word
@onready var word_score = $WordScoreMargin/Center/WordScore

var selected_token: Token
var selected_item: Item

func _ready():
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
	
	var all_relic_events = [] 
	var results = word_finder.find_words(space)
	for result in results:
		var event = scorer.score(result)	
		result.event = event
		context.score_event = event
		
		for s in result.path:
			var token = s.token
			var letter = token.letter
			word.add_letter(letter)
			token.pulse(0.3)
			word_score.add(token.value)
			await get_tree().create_timer(0.3).timeout
		word.clear()
		word_score.clear()
		await get_tree().create_timer(0.3).timeout
		
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
