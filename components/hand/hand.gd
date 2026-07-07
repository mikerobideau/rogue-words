extends Panel
class_name Hand

var TokenScene = preload("res://components/token/token.tscn")

signal token_clicked()
signal discard_clicked()

@onready var token_container = $Tokens
@onready var discard_button = $DiscardContainer/DiscardButton

const HAND_SIZE = 5
const H_PAD = 50
const V_PAD = 0
	
var bag: Array[TokenData]
	
func on_round_start():
	bag = GameState.tokens.duplicate()
	draw_tokens(HAND_SIZE)
	
func remove_token(token: Token):
	token_container.remove_child(token)
	_layout_tokens()
	return token
	
func draw_tokens(n: int):
	for i in range(n):
		if bag.is_empty():
			if GameState.discarded_tokens.is_empty():
				return
			bag = GameState.discarded_tokens.duplicate()
			GameState.discarded_tokens = [] as Array[TokenData]
		var token_data = bag.pop_back()
		var token_scene = TokenFactory.create_scene(token_data)
		token_container.add_child(token_scene)
		token_scene.clicked.connect(_on_token_clicked)
		token_scene.pop_open()
	Sound.play('token')
	_layout_tokens()
		
func discard(tokens: Array[Token]):
	for token in tokens:
		GameState.discarded_tokens.append(token.data)
		token_container.remove_child(token)
	draw_tokens(tokens.size())
	_layout_tokens()
	
func is_empty() -> bool:
	return token_container.get_children().size() < 1
		
func _layout_tokens():
	var diameter = Token.RADIUS * 2
	var tokens = token_container.get_children()
	var total_width = tokens.size() * (diameter + H_PAD) + H_PAD
	custom_minimum_size = Vector2(total_width, diameter)
	
	for i in range(tokens.size()):
		var x = H_PAD + Token.RADIUS + i * (diameter + H_PAD)
		var y = size.y / 2
		tokens[i].position = Vector2(x, y)
	
func _on_token_clicked(token: Token):
	token_clicked.emit(token)

func _on_discard_button_pressed() -> void:
	discard_clicked.emit()
