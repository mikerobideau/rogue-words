extends Container
class_name Hand

var TokenScene = preload("res://components/token/token.tscn")

signal token_clicked()

@onready var token_container = $Tokens

const HAND_SIZE = 5
const H_PAD = 10
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
		_layout_tokens()
		
func discard(tokens: Array[Token]):
	for token in tokens:
		GameState.discarded_tokens.append(token.data)
		token_container.remove_child(token)
	draw_tokens(tokens.size())
	_layout_tokens()
		
func _layout_tokens():
	var diameter = Token.RADIUS * 2
	var tokens = token_container.get_children()
	var total_width = H_PAD + tokens.size() * (diameter + H_PAD)
	var total_height = V_PAD * 2 * diameter
	custom_minimum_size = Vector2(total_width, total_height)
	
	for i in range(tokens.size()):
		var token = tokens[i]
		var x = H_PAD + token.RADIUS + i * (diameter + H_PAD)
		var y = V_PAD + token.RADIUS
		tokens[i].position = Vector2(x, y)
	
func _on_token_clicked(token: Token):
	token_clicked.emit(token)
