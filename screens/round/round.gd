extends Control
class_name Round

var ScoreToastScene = preload("res://components/score_toast/score_toast.tscn")

signal completed()

@export var target_score := 100

@onready var round_label = $Control/HBoxContainer/RoundLabel
@onready var hand = $HandContainer/Hand
@onready var board = $Board
@onready var word_finder = $WordFinder
@onready var scorer = $Scorer
@onready var score = $Score
@onready var relic_manager = $"../RelicManager"
@onready var relic_container = $RelicContainer

var selected_token: Token

func _ready():
	relic_container.setup(relic_manager.active_relics)
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
	var paths = word_finder.find_words(space)
	for path in paths:
		context.score_event = scorer.score(path)	
		relic_manager.on_score_event(context)
		var toast = ScoreToastScene.instantiate()
		toast.text = str(context.score_event.score) + ' - ' + context.score_event.word
		add_child(toast)
		await board.highlight(path)
		toast.queue_free()
		score.add(context.score_event.score)
	var expansions = 3
	for relic in relic_manager.active_relics:
		expansions += relic.data.add_grow_amount(context)
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
			
func _on_token_clicked(token: Token):
	var prev_selected = selected_token
	selected_token = null if selected_token == token else token
	if prev_selected != null and prev_selected != selected_token:
		prev_selected.selected = false
	token.selected = token == selected_token

func _get_relic_context():
	var context = RelicContext.new()
	context.placed_token = selected_token
	return context
