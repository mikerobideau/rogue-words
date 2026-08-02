extends Panel
class_name Hand

var TokenScene = preload("res://components/token/token.tscn")

signal token_clicked()
signal discard_clicked()
signal token_destroyed(token: Token)

@onready var token_container = $Tokens
@onready var discard_button = $DiscardContainer/DiscardButton

const DEFAULT_HAND_SIZE = 7
const H_PAD = 25
const V_PAD = 0
	
var bag: Array[TokenData]
var hand_size := DEFAULT_HAND_SIZE
var y_in: int
var y_out: int
var slide_distance: int

func _ready():
	modulate.a = 0.0
	discard_button.mouse_entered.connect(_on_discard_button_mouse_entered)

func _on_discard_button_mouse_entered():
	Sound.play(Sound.SOUND_MOUSEOVER)
	
func on_round_start():
	bag = GameState.tokens.duplicate()
	GameState.token_added.connect(_on_token_added)
	draw_tokens(hand_size)
	
func _on_token_added(token: TokenData):
	bag.append(token)
	
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
			for token in bag:
				token.data.spent = false
		var token_data = bag.pop_back()
		var token_scene = TokenFactory.create_scene(token_data)
		token_container.add_child(token_scene)
		token_scene.clicked.connect(_on_token_clicked)
		token_scene.destroyed.connect(_on_token_destroyed.bind(token_scene))
		token_scene.pop_open()
	Sound.play(Sound.SOUND_DRAW_TOKEN)
	_layout_tokens()
		
func discard(tokens: Array[Token]):
	for token in tokens:
		token.data.spent = true
		GameState.discarded_tokens.append(token.data)
		token_container.remove_child(token)
	draw_tokens(tokens.size())
	_layout_tokens()
	
func is_empty() -> bool:
	return token_container.get_children().size() < 1
		
func _layout_tokens():
	var diameter = Token.RADIUS * 2
	var tokens = token_container.get_children()
	
	for i in range(tokens.size()):
		var x = H_PAD + Token.RADIUS + i * (diameter + H_PAD)
		var y = size.y / 2
		tokens[i].position = Vector2(x, y)
	
func _on_token_clicked(token: Token):
	token_clicked.emit(token)

func _on_token_destroyed(token: Token):
	token_destroyed.emit(token)

func _on_discard_button_pressed() -> void:
	discard_clicked.emit()

func get_hand() -> Array[Token]:
	var tokens := [] as Array[Token]
	for child in token_container.get_children():
		if child is Token:
			tokens.append(child)
	return tokens
	
func slide_in(delay := 0.5):
	await get_tree().process_frame
	y_in = position.y
	slide_distance = size.y + 50
	y_out = y_in + slide_distance
	position.y = y_out
	modulate.a = 1.0
	await get_tree().create_timer(delay).timeout
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, 'position:y', y_in, 0.5)
