extends Node
class_name ScorePopupGlobal

var PopupScene = preload("res://components/ui/popup_box/popup_box.tscn")

enum Anchor { CENTER, RIGHT }

func show(message: String, target: Node, lifetime := 0.5, offset_x := 0, offset_y := 0, anchor := Anchor.CENTER):
	var popup = PopupScene.instantiate()

	var canvas = CanvasLayer.new()
	canvas.layer = 200
	canvas.add_child(popup)
	
	get_tree().root.add_child(canvas)
	popup.label.text = message
	
	#size panel
	await get_tree().process_frame 
	popup.reset_size() 

	var rect = target.get_global_rect() if target is Control else Rect2(target.global_position, Vector2.ZERO)

	if anchor == Anchor.RIGHT:
		popup.position = Vector2(
			rect.position.x + rect.size.x + offset_x,
			rect.position.y + rect.size.y * 0.5 - popup.size.y * 0.5 + offset_y
		)
	else:
		popup.position = Vector2(
			rect.position.x + rect.size.x * 0.5 - popup.size.x * 0.5 + offset_x,
			rect.position.y - popup.size.y + offset_y
		)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, 'position:y', popup.position.y - 10, lifetime).set_ease(Tween.EASE_OUT)
	tween.tween_property(popup, 'modulate:a', 0.0, lifetime).set_delay(0.2)
	await tween.finished
	canvas.queue_free()
