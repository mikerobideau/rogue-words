extends Control
class_name Pickup

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
	title.text = "Pick one — free"
	vbox.add_child(title)

	for offer in _offers():
		var b := Button.new()
		if offer.kind == "relic":
			b.text = "Relic:  " + offer.data.relic_name
		else:
			b.text = "Item:  " + offer.data.item_name
		b.pressed.connect(_on_pick.bind(offer))
		vbox.add_child(b)

	var skip := Button.new()
	skip.text = "Skip"
	skip.pressed.connect(func(): completed.emit())
	vbox.add_child(skip)

func _offers() -> Array:
	var offers := []
	var items := ItemFactory.load_all_items()
	var owned := GameState.relics.map(func(rd): return rd.relic_name)
	var relics := RelicFactory.load_all_relics().filter(func(rd): return rd.relic_name not in owned)
	for i in 3:
		if relics.size() > 0 and randf() < 0.5:
			offers.append({ "kind": "relic", "data": relics.pick_random() })
		elif items.size() > 0:
			offers.append({ "kind": "item", "data": items.pick_random() })
	return offers

func _on_pick(offer: Dictionary) -> void:
	if offer.kind == "relic":
		if GameState.has_empty_relic_slot() > 0:
			GameState.add_relic(offer.data.duplicate())
	else:
		if GameState.has_empty_item_slot() > 0:
			GameState.add_item(offer.data.duplicate())
	Sound.play(Sound.SOUND_MONEY_EARNED)
	completed.emit()
