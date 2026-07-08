extends TokenEnhancement
class_name ChargedGrape

var charge = 0

func on_placed():
	charge += 1
	
func get_plus_score():
	return charge
