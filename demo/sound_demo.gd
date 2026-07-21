extends Control

const COLUMNS := 5

func _ready():
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	add_child(margin)

	var scroll := ScrollContainer.new()
	margin.add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = COLUMNS
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(grid)

	var names := Sound.sounds.keys()
	names.sort()                                   # alphabetical for easy scanning
	for sound_name in names:
		var button := Button.new()
		button.text = sound_name
		button.pressed.connect(Sound.play.bind(sound_name))
		grid.add_child(button)
