extends TextureRect
class_name ShopSign

const MARGIN_Y = 20

var y_in: int
var y_out: int
var slide_distance: int

func slide_in(delay := 0.5):
	await get_tree().process_frame
	y_in = position.y + MARGIN_Y
	slide_distance = size.y + 50
	y_out = y_in - slide_distance
	position.y = y_out
	modulate.a = 1.0
	await get_tree().create_timer(delay).timeout
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, 'position:y', y_in, 0.5)
