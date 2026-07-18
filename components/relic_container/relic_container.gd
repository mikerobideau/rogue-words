extends Panel
class_name RelicContainer

@onready var slots = [$Slots/RelicSlot1, $Slots/RelicSlot2, $Slots/RelicSlot3, $Slots/RelicSlot4, $Slots/RelicSlot5]

func _ready():
	GameState.relics_changed.connect(refresh_relics)
	GameState.items_changed.connect(_refresh_tooltips)
	GameState.tokens_changed.connect(_refresh_tooltips)
	for slot in slots:
		slot.container = self
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

func move_relic(source: RelicData, target: RelicData) -> void:
	if source == target:
		return
	var i := GameState.relics.find(source)
	if i == -1:
		return
	if target == null:
		GameState.relics.remove_at(i)       # dropped on empty slot → move to end
		GameState.relics.append(source)
	else:
		var j := GameState.relics.find(target)
		if j == -1:
			return
		GameState.relics[i] = target         # swap in place — no remove/insert shift
		GameState.relics[j] = source
	GameState.relics_changed.emit()

func _refresh_tooltips():
	for slot in slots:
		slot.refresh_tooltip()
