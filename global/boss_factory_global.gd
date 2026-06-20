extends Node
class_name BossFactoryGlobal

func load_all_bosses() -> Array[BossData]:
	return DataLoader.load_all("res://components/boss/data/", BossData)
	
func random_boss_data():
	var bosses = load_all_bosses()
	return bosses[randi() % bosses.size()]
