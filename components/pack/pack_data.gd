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
@export var type: Type
@export var size: int
@export var num_picks: int
@export var rarity: Rarity.Type
@export var offers: Array[OfferData]

var cost: int:
	get:
		match rarity:
			Rarity.Type.COMMON:    return 5
			Rarity.Type.UNCOMMON:  return 7
			Rarity.Type.RARE:      return 10
			Rarity.Type.LEGENDARY: return 15
			_:                     return 4

func type_name() -> String:
	return TYPE_NAMES[type]
