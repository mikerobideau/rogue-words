extends Node
class_name ScorePopupGlobal

func show(message: String, target: Node, lifetime := 0.5, offset_y := 0):
	#create
	var label := Label.new()
	label.text = message
	label.add_theme_color_override("font_color", Color.BLACK)
	var canvas = CanvasLayer.new()
	canvas.layer = 200
	canvas.add_child(label)
	get_tree().root.add_child(canvas)
	await get_tree().process_frame
	var rect = target.get_global_rect() if target is Control else Rect2(target.global_position, Vector2.ZERO)

	#position
	label.position = Vector2(
		rect.position.x + rect.size.x * 0.5 - label.size.x * 0.5,
		rect.position.y - label.size.y + offset_y
	)
	
	#animate
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, 'position:y', label.position.y - 10, 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, 'modulate:a', 0.0, 0.5).set_delay(0.3)
	await tween.finished
	canvas.queue_free()
