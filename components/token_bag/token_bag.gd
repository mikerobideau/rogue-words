extends CanvasLayer
class_name TokenBag

@onready var tokens = $Panel/Margin/ScrollContainer/Tokens

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("view_token_bag"):
		_toggle()
	
func _toggle():
	visible = !visible
	if !visible:
		_clear()
		return

	var sorted_tokens = GameState.tokens.duplicate()
	sorted_tokens.sort_custom(func(a, b): return a.letter < b.letter)
	
	for token_data in sorted_tokens:
		var wrapper = Control.new()
		wrapper.custom_minimum_size = Vector2(Token.RADIUS * 2, Token.RADIUS * 2)
		var token = TokenFactory.create_scene(token_data)
		token.position = Vector2(Token.RADIUS, Token.RADIUS)
		if token.data.spent:
			token.modulate = Color(0.45, 0.45, 0.45)
		token.is_selectable = false
		wrapper.add_child(token)
		tokens.add_child(wrapper)
		
func _clear():
	for child in tokens.get_children():
		child.queue_free()
