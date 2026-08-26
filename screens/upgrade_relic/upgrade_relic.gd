extends Control
class_name UpgradeRelic

signal completed()

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "Choose a relic to upgrade"
	vbox.add_child(title)

	if GameState.relics.is_empty():
		var none := Label.new()
		none.text = "No relics to upgrade"
		vbox.add_child(none)
		_add_continue(vbox)
		return

	for relic_data in GameState.relics:
		var b := Button.new()
		b.text = relic_data.relic_name + "  —  " + relic_data.get_upgrade_text()
		b.pressed.connect(_on_relic_chosen.bind(relic_data))
		vbox.add_child(b)

func _add_continue(vbox: VBoxContainer) -> void:
	var skip := Button.new()
	skip.text = "Continue"
	skip.pressed.connect(func(): completed.emit())
	vbox.add_child(skip)

func _on_relic_chosen(relic_data: RelicData) -> void:
	relic_data.upgrade()
	Sound.play(Sound.SOUND_RELIC_UPGRADE)
	completed.emit()
