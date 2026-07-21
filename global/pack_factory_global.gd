extends Node
class_name PackFactoryGlobal

const ENHANCEMENTS := [
	preload("res://components/token/enhancements/charged_grape/charged_grape.tres"),
	preload("res://components/token/enhancements/spicy_grape/spicy_grape.tres"),
	preload("res://components/token/enhancements/clover/clover.tres"),
]
const ENHANCE_CHANCE := 0.5

var PackScene = preload("res://components/pack/pack.tscn")

func create_scene(data: PackData):
	var scene = PackScene.instantiate()
	scene.data = data
	return scene

func load_all_packs() -> Array[PackData]:
	return DataLoader.load_all("res://components/pack/data/", PackData)

func generate_offers(pack_data: PackData) -> Array[OfferData]:
	var pool := _pool_for(pack_data)
	var offers: Array[OfferData] = []
	for i in pack_data.size:
		if pool.is_empty():
			break
		offers.append(_roll_offer(pack_data, pool))   # pass pack_data, not just type
	_apply_guarantees(offers, pack_data, pool)
	return offers

func _roll_offer(pack_data: PackData, pool: Array) -> OfferData:
	var data = Rarity.pick_weighted(pool)
	pool.erase(data)
	return _make_offer(pack_data, data)

func _make_offer(pack_data: PackData, data) -> OfferData:
	var offer := OfferData.new()
	match pack_data.type:
		PackData.Type.RELIC:
			offer.type = OfferData.Type.RELIC
			offer.relic_data = data
		PackData.Type.ITEM:
			offer.type = OfferData.Type.ITEM
			offer.item_data = data
		PackData.Type.TOKEN:
			offer.type = OfferData.Type.TOKEN
			var token_data = data
			var enhancement := _enhancement_for(pack_data)
			if enhancement:
				token_data = data.duplicate()          # don't mutate the pool instance
				token_data.enhance(enhancement)
			offer.token_data = token_data
	return offer
func _apply_guarantees(offers: Array[OfferData], pack_data: PackData, pool: Array) -> void:
	# Guarantee: at least one offer at or above the pack's rarity tier.
	if pack_data.rarity <= Rarity.Type.COMMON:
		return
	for offer in offers:
		if _offer_rarity(offer) >= pack_data.rarity:
			return

	var candidates := pool.filter(func(d): return _rarity_of(d) >= pack_data.rarity)
	if candidates.is_empty():
		return

	var replacement := _make_offer(pack_data, Rarity.pick_weighted(candidates))   # was _make_offer(pack_data.type, ...)

	var weakest := 0
	for i in offers.size():
		if _offer_rarity(offers[i]) < _offer_rarity(offers[weakest]):
			weakest = i
	offers[weakest] = replacement

func _offer_rarity(offer: OfferData) -> int:
	match offer.type:
		OfferData.Type.RELIC: return _rarity_of(offer.relic_data)
		OfferData.Type.ITEM:  return _rarity_of(offer.item_data)
		OfferData.Type.TOKEN: return _rarity_of(offer.token_data)
	return Rarity.Type.COMMON

func _rarity_of(data) -> int:
	var r = data.get("rarity")                   # null for items/tokens without a rarity field
	return r if r != null else Rarity.Type.COMMON

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

func _enhancement_for(pack_data: PackData) -> TokenEnhancement:
	if pack_data.enhancement:
		return pack_data.enhancement.duplicate()                        # themed pack → always this one
	if pack_data.random_enhancement and randf() < ENHANCE_CHANCE:
		return ENHANCEMENTS[randi() % ENHANCEMENTS.size()].duplicate()   # mystery pack → sometimes random
	return null                                                          # plain pack → never
