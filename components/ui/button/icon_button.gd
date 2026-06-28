extends TextureButton
class_name IconButton

@export var icon_texture: Texture2D:
	set(v):
		icon_texture = v
		if icon:
			icon.texture = v
			
@onready var icon = $Icon

func _ready():
	icon.texture = icon_texture
