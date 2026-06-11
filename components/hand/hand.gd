extends Container
class_name Hand

var TokenScene = preload("res://components/token/token.tscn")

signal token_clicked()

@onready var token_container = $Tokens

const LETTERS: Dictionary = {"A": 1, "B": 3, "C": 3, "D": 2, "E": 1, "F": 4, "G": 2, "H": 4, "I": 1, "J": 8, "K": 5, "L": 1, "M": 3, "N": 1, "O": 1, "P": 3, "Q": 10, "R": 1, "S": 1, "T": 1, "U": 1, "V": 4, "W": 4, "X": 8, "Y": 4, "Z": 10}
const HAND_SIZE = 7
const H_PAD = 10
const V_PAD = 0
	
var bag = _create_mock_bag(50)

func _ready():
	draw_tokens(HAND_SIZE)
	
func remove_token(token: Token):
	token_container.remove_child(token)
	_layout_tokens()
	return token
	
func draw_tokens(n: int):
	for i in range(n):
		if bag.is_empty():
			push_warning('Hand attempted to draw from an empty bag.')
			return
		var token = bag.pop_back()
		token_container.add_child(token)
		token.clicked.connect(_on_token_clicked)
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

func _create_mock_bag(n: int) -> Array:
	#var letters = ['C', 'E', 'W', 'S']
	var letters = ['Z', 'Z', 'Z', 'L', 'N', 'A', 'E', 'I']
	#var letters = LETTERS.keys()
	var mock_bag: Array = []
	for i in range(n):
		var token = TokenScene.instantiate()
		var letter = letters[randi() % letters.size()]
		token.letter = letter
		token.value = LETTERS[letter]
		mock_bag.append(token)
	mock_bag.shuffle()
	return mock_bag
	
func _on_token_clicked(token: Token):
	token_clicked.emit(token)
	
