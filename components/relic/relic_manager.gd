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
		
func get_score_report(context: RelicContext) -> RelicReport:
	var report = RelicReport.new()
	var items: Array[RelicReportItem] = []
	report.prev_score = context.word_score
	for relic in active_relics:
		context.relic = relic
		var score = context.word_score
		var report_item = relic.data.get_score_report(context)
		if report_item:
			items.append(report_item)
	if items.size() > 0:
		report.new_score = items[-1].new_score
	else:
		report.new_score = context.word_score
	report.items = items
	return report
			
func add_grow_amount(context: RelicContext):
	var expansions = 0
	for relic in active_relics:
		var bonus = relic.data.add_grow_amount(context)
		if bonus > 0:
			relic.pulse()
		expansions += bonus
	return expansions
	
func get_letter_matches(letter: String) -> Array:
	var matches = [letter]
	for relic in relics:
		matches = relic.data.modify_letter_matches(letter, matches)
	return matches
	
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
