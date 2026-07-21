extends Resource
class_name OfferData

enum Type { RELIC, ITEM, TOKEN }

@export var type: Type
@export var relic_data: RelicData
@export var item_data: ItemData
@export var token_data: TokenData

func data() -> Resource:
	match type:
		Type.RELIC: return relic_data
		Type.ITEM:  return item_data
		Type.TOKEN: return token_data
	return null

func grant() -> void:
	match type:
		Type.RELIC: GameState.add_relic(relic_data)
		Type.ITEM:  GameState.add_item(item_data)
		Type.TOKEN: GameState.add_token(token_data)

func create_scene() -> Node:
	match type:
		Type.RELIC: return RelicFactory.create_scene(relic_data)
		Type.ITEM:  return ItemFactory.create_scene(item_data)
		Type.TOKEN: return TokenFactory.create_scene(token_data)
	return null

func name() -> String:
	match type:
		Type.RELIC:
			return relic_data.relic_name
		Type.ITEM:
			return item_data.item_name
		Type.TOKEN:
			return token_data.token_name
		_:
			return ''
			
func get_rarity_label() -> String:
		match type:
			Type.RELIC:
				return Rarity.to_text(relic_data.rarity)
			Type.ITEM:
				return ''
			Type.TOKEN:
				return ''
			_:
				return ''	
			
func get_title_text() -> String:
		match type:
			Type.RELIC:
				return relic_data.relic_name
			Type.ITEM:
				return item_data.item_name
			Type.TOKEN:
				return token_data.get_title()
			_:
				return ''
				
func get_description() -> String:
		match type:
			Type.RELIC:
				return relic_data.get_tooltip_text(RelicContext.new())
			Type.ITEM:
				return item_data.description
			Type.TOKEN:
				return token_data.letter
			_:
				return ''
