extends Node
class_name BossFactoryGlobal

var _bosses_cache: Array[BossData] = []
var _bosses_loaded := false

func load_all_bosses() -> Array[BossData]:
	if not _bosses_loaded:
		_bosses_cache = DataLoader.load_all("res://components/boss/data/", BossData)
		_bosses_loaded = true
	return _bosses_cache.duplicate()
	
func random_boss_data():
	var bosses = load_all_bosses()
	return bosses[randi() % bosses.size()]
