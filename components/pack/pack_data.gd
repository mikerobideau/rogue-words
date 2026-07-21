extends Resource
class_name PackData

enum Type {
	RELIC,
	ITEM,
	TOKEN
}

const TYPE_NAMES: Dictionary = {
	Type.RELIC: 'Coupon',
	Type.ITEM: 'Item',
	Type.TOKEN: 'Token'
}

@export var pack_name: String	
@export var cost: int
@export var type: Type
@export var size: int
@export var num_picks: int
@export var rarity: Rarity.Type
@export var offers: Array[OfferData]
@export var enhancement: TokenEnhancement
@export var random_enhancement := false #tokens sometimes get a random enhancement
@export var texture: Texture2D

func type_name() -> String:
	return TYPE_NAMES[type]
