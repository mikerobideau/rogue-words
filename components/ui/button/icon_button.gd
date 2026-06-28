extends TextureButton
class_name IconButton

@onready var icon = $Icon
@onready var label = $LabelMargin/Label

@export var icon_texture: Texture2D:
	set(v):
		icon_texture = v
		if icon:
			icon.texture = v

@export var label_text: String:
	set(v):
		label.text = v

func _ready():
	icon.texture = icon_texture
