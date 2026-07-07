extends VBoxContainer
class_name RelicContainer

@onready var slots = [$RelicSlot1, $RelicSlot2, $RelicSlot3, $RelicSlot4, $RelicSlot5]

func _ready():
	GameState.relics_changed.connect(refresh_relics)
	refresh_relics()

func refresh_relics():
	for slot in slots:
		slot.clear()
	for i in slots.size():
		if i < GameState.relics.size():
			var relic = GameState.relics[i]
			slots[i].set_relic(relic)

func get_relics() -> Array[Relic]:
	var result: Array[Relic] = []
	for s in slots:
		if s.relic_data:
			result.append(s.relic)
	return result
