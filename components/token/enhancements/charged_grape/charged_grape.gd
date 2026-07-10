extends TokenEnhancement
class_name ChargedGrape

signal charged()

func on_scored():
	charged.emit()
