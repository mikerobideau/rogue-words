extends Node
class_name RelicManager

var RelicScene = preload("res://components/relic/relic.tscn")

var relics: Array[Relic] = []
var active_relics: Array[Relic] = []

func _ready():
	_load_all_relics()
	
func on_token_placed(context: RelicContext):
	for relic in active_relics:
		relic.data.on_token_placed(context)
		
func on_score_event(context: RelicContext):
	for relic in active_relics:
		if relic.data.on_score_event(context):
			relic.pulse()
	
func _add(data: RelicData):
	var scene = RelicScene.instantiate()
	scene.data = data
	relics.append(scene)
	
func _load_all_relics():
	var base_path = "res://components/relic/data"
	var dir = DirAccess.open(base_path)
	dir.list_dir_begin()
	var entry = dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with("."):
			_load_relics_from(base_path + '/' + entry)
		elif entry.ends_with(".tres"):
			var relic = load(base_path + '/' + entry)
			_add(relic)
		entry = dir.get_next()
	for relic in relics:
		active_relics.append(relic)
		
func _load_relics_from(path: String):
	var sub_dir = DirAccess.open(path)
	if sub_dir == null:
		return
	sub_dir.list_dir_begin()
	var file = sub_dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var relic = load(path + '/' + file)
			_add(relic)
		file = sub_dir.get_next()
