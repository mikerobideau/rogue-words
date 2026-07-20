extends Node
class_name PackFactoryGlobal

var PackScene = preload("res://components/pack/pack.tscn")

func create_scene(data: PackData):
	var scene = PackScene.instantiate()
	scene.data = data
	return scene

func load_all_packs() -> Array[PackData]:
	return DataLoader.load_all("res://components/pack/data/", PackData)

func generate_offers(pack_data: PackData) -> Array[OfferData]:
	var pool := _pool_for(pack_data)          # built once, filtered (e.g. owned relics removed)
	var offers: Array[OfferData] = []
	for i in pack_data.size:
		if pool.is_empty():
			break
		var offer = _roll_offer(pack_data.type, pool)
		offers.append(offer)
	#_apply_guarantees(offers, pack_data)
	return offers

func _pool_for(pack_data: PackData) -> Array:
	match pack_data.type:
		PackData.Type.RELIC:
			var owned := GameState.relics.map(func(r): return r.relic_name)
			return RelicFactory.load_all_relics().filter(func(r): return r.relic_name not in owned)
		PackData.Type.ITEM:
			return ItemFactory.load_all_items()
		PackData.Type.TOKEN:
			return TokenFactory.load_all_tokens()
	return []

func _roll_offer(type: PackData.Type, pool: Array) -> OfferData:
	var data = Rarity.pick_weighted(pool)
	pool.erase(data)

	var offer := OfferData.new()
	match type:
		PackData.Type.RELIC:
			offer.type = OfferData.Type.RELIC
			offer.relic_data = data
		PackData.Type.ITEM:
			offer.type = OfferData.Type.ITEM
			offer.item_data = data
		PackData.Type.TOKEN:
			offer.type = OfferData.Type.TOKEN
			offer.token_data = data
	return offer
