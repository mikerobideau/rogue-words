extends CanvasLayer
class_name RoundSummary

signal closed()

const ROW_DELAY := 0.3
const FADE_TIME := 0.3

@onready var grid: GridContainer = $Panel/TitleMargin/VBoxContainer/GridContainer
@onready var actions = $Panel/Actions

func _ready():
	pass
	#visible = true
	#play_turns_remaining(2)

func _on_continue_pressed() -> void:
	visible = false
	closed.emit()

func play_turns_remaining(turns: int):
	await _add_row(str(turns) +  ' turns remaining ', '+ $' + str(turns))
	if turns > 0:
		GameState.money += turns
		Sound.play(Sound.SOUND_MONEY_EARNED)
	await get_tree().create_timer(ROW_DELAY).timeout
	
func play_discards_remaining(discards: int):
	await _add_row(str(discards) +  ' discards remaining ', '+ $' + str(discards))
	if discards > 0:
		GameState.money += discards
		Sound.play(Sound.SOUND_MONEY_EARNED)
	await get_tree().create_timer(ROW_DELAY).timeout
	
func play_interest(money: int, interest: float):
	var interest_earned = roundi(money * interest)
	if interest_earned > 0:
		GameState.money += interest_earned
		Sound.play(Sound.SOUND_MONEY_EARNED)
	await _add_row('Interest earned', '+ $' + str(interest_earned) )

func show_actions():
	actions.visible = true

func _add_row(category: String, value: String) -> void:
	var cat := _make_label(category, HORIZONTAL_ALIGNMENT_LEFT)
	var val := _make_label(value, HORIZONTAL_ALIGNMENT_RIGHT)
	cat.modulate.a = 0.0
	val.modulate.a = 0.0
	grid.add_child(cat)
	grid.add_child(val)
	await get_tree().process_frame

	var t := create_tween().set_parallel(true)
	t.tween_property(cat, "modulate:a", 1.0, FADE_TIME)
	t.tween_property(val, "modulate:a", 1.0, FADE_TIME)
	await t.finished

func _make_label(text: String, align: int) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = align
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.add_theme_color_override("font_color", Color.BLACK)
	return l
