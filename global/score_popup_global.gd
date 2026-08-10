extends Node
class_name ScorePopupGlobal

enum Anchor { CENTER, RIGHT }
enum Template { DEFAULT, WORD, BASE, MULT }

const TEMPLATES := {
	Template.DEFAULT: preload("res://components/ui/popup_box/popup_box.tscn"),
	Template.WORD: preload("res://components/ui/popup_box/word_popup.tscn")
}

var layer: CanvasLayer

func _ready() -> void:
	layer = CanvasLayer.new()
	layer.layer = 200
	add_child(layer)

func spawn(template: Template, message: String, target: Node, anchor := Anchor.CENTER, offset_x := 0, offset_y := 0) -> Control:
	var popup = TEMPLATES[template].instantiate()
	layer.add_child(popup)
	popup.set_text(message)
	await get_tree().process_frame
	_position(popup, target, anchor, offset_x, offset_y)
	return popup

func show(template: Template, message: String, target: Node, lifetime := 0.5, offset_x := 0, offset_y := 0,
		anchor := Anchor.CENTER) -> void:
	var popup := await spawn(template, message, target, anchor, offset_x, offset_y)
	var t := popup.create_tween().set_parallel(true)
	t.tween_property(popup, 'position:y', popup.position.y - 10, lifetime).set_ease(Tween.EASE_OUT)
	t.tween_property(popup, 'modulate:a', 0.0, lifetime).set_delay(0.2)
	await t.finished
	popup.queue_free()

func dismiss(popup: Control, fade := true) -> void:
	if not is_instance_valid(popup):
		return
	if fade:
		var t := popup.create_tween()
		t.tween_property(popup, 'modulate:a', 0.0, 0.2)
		await t.finished
	popup.queue_free()

func _position(popup: Control, target: Node, anchor: int, offset_x: int, offset_y: int) -> void:
	var rect = target.get_global_rect() if target is Control else Rect2(target.global_position, Vector2.ZERO)
	if anchor == Anchor.RIGHT:
		popup.position = Vector2(
			rect.position.x + rect.size.x + offset_x,
			rect.position.y + rect.size.y * 0.5 - popup.size.y * 0.5 + offset_y)
	else:
		popup.position = Vector2(
			rect.position.x + rect.size.x * 0.5 - popup.size.x * 0.5 + offset_x,
			rect.position.y - popup.size.y + offset_y)
