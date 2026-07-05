extends VBoxContainer
class_name RelicContainer

@onready var slots = [$RelicSlot1, $RelicSlot2, $RelicSlot3, $RelicSlot4, $RelicSlot5]

func _ready():
	GameState.relics_changed.connect(_refresh_relics)
	_refresh_relics()

func _refresh_relics():
	for slot in slots:
		slot.clear()
	for i in slots.size():
		if i < GameState.relics.size():
			var relic = GameState.relics[i]
			slots[i].set_relic(relic)
		slots[i].register_tooltip()

func get_relics() -> Array[Relic]:
	return slots.map(func(s): s.relic)
