extends Control
class_name Round

@onready var round_label = $Control/HBoxContainer/RoundLabel
@onready var hand = $HandContainer/Hand
@onready var board = $Board
@onready var word_finder = $WordFinder

var selected_token: Token

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	round_label.text = 'Round ' + str(GameState.round_number)
	hand.token_clicked.connect(_on_token_clicked)
	board.space_clicked.connect(_on_space_clicked)	

func _on_space_clicked(space: Space):
	if !selected_token:
		return
	hand.remove_token(selected_token)
	board.place(selected_token, space)
	selected_token.selected = false
	selected_token = null
	var paths = word_finder.find_words(space)
	for path in paths:
		print_debug('Found: ' + _path_to_word(path))
		await board.highlight(path)
	board.grow()
	hand.draw_tokens(1)
	
func _path_to_word(path: Array):
	var word := ""
	for p in path:
		word += p.token.letter
	return word

func _on_token_clicked_tmp(token: Token):
	if token.selected:
		if selected_token != null and selected_token != token:
			selected_token.selected = false
		selected_token = token
	else:
		if selected_token == token:
			selected_token = null
			
func _on_token_clicked(token: Token):
	var prev_selected = selected_token
	selected_token = null if selected_token == token else token
	if prev_selected != null and prev_selected != selected_token:
		prev_selected.selected = false
	token.selected = token == selected_token
