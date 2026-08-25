extends Node
class_name PackFactoryGlobal

var PackScene = preload("res://components/pack/pack.tscn")

const ENHANCEMENTS := [
	preload("res://components/token/enhancements/charged_grape/charged_grape.tres"),
	preload("res://components/token/enhancements/spicy_grape/spicy_grape.tres"),
	preload("res://components/token/enhancements/clover/clover.tres"),
]
const ENHANCE_CHANCE := 0.3

#---------------------------------------------------------------------------------------------------
# Scene / data loading
#---------------------------------------------------------------------------------------------------

func create_scene(data: PackData):
	var scene = PackScene.instantiate()
	scene.data = data
	return scene

var _packs_cache: Array[PackData] = []
var _packs_loaded := false

func load_all_packs() -> Array[PackData]:
	if not _packs_loaded:
		_packs_cache = DataLoader.load_all("res://components/pack/data/", PackData)
		_packs_loaded = true
	return _packs_cache.duplicate()

#---------------------------------------------------------------------------------------------------
# Offer generation
#---------------------------------------------------------------------------------------------------

func generate_offers(pack_data: PackData) -> Array[OfferData]:
	var pools := _pools_for(pack_data)          # {type: [candidates]} — 1 entry, or 3 for ANY
	var offers: Array[OfferData] = []
	for i in pack_data.size:
		var type = _pick_type(pools)            # a type that still has candidates
		if type == null:
			break
		var pool: Array = pools[type]
		var data = Rarity.pick_weighted(pool)
		pool.erase(data)                        # distinct within its type
		offers.append(_make_offer(pack_data, type, data))
	_apply_guarantees(offers, pack_data, pools)
	return offers

func _pools_for(pack_data: PackData) -> Dictionary:
	if pack_data.type == PackData.Type.ANY:
		return {
			PackData.Type.RELIC: _relic_pool(),
			PackData.Type.ITEM:  ItemFactory.load_all_items(),
			PackData.Type.TOKEN: TokenFactory.load_all_tokens(),
		}
	return { pack_data.type: _pool_for(pack_data) }

func _pool_for(pack_data: PackData) -> Array:
	match pack_data.type:
		PackData.Type.RELIC: return _relic_pool()
		PackData.Type.ITEM:  return ItemFactory.load_all_items()
		PackData.Type.TOKEN: return TokenFactory.load_all_tokens()
	return []

func _relic_pool() -> Array:
	var owned := GameState.relics.map(func(r): return r.relic_name)
	return RelicFactory.load_all_relics().filter(func(r): return r.relic_name not in owned)

func _pick_type(pools: Dictionary):
	var available := pools.keys().filter(func(t): return not pools[t].is_empty())
	if available.is_empty():
		return null
	return available[randi() % available.size()]   # uniform across available types

func _make_offer(pack_data: PackData, type: PackData.Type, data) -> OfferData:
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
			var token_data = data
			var enhancement := _enhancement_for(pack_data)
			if enhancement:
				token_data = data.duplicate()                  # don't mutate the pool instance
				token_data.enhance(enhancement)
			offer.token_data = token_data
	return offer

func _enhancement_for(pack_data: PackData) -> TokenEnhancement:
	if pack_data.enhancement:
		return pack_data.enhancement.duplicate()                        # themed pack → always this one
	if pack_data.random_enhancement and randf() < ENHANCE_CHANCE:
		return ENHANCEMENTS[randi() % ENHANCEMENTS.size()].duplicate()   # random enhancements
	return null                                                          # plain pack → never

#---------------------------------------------------------------------------------------------------
# Guarantees
#---------------------------------------------------------------------------------------------------

func _apply_guarantees(offers: Array[OfferData], pack_data: PackData, pools: Dictionary) -> void:
	# Guarantee: at least one offer at or above the pack's rarity tier.
	if pack_data.rarity <= Rarity.Type.COMMON:
		return
	for offer in offers:
		if _offer_rarity(offer) >= pack_data.rarity:
			return

	var candidates := []                        # [{type, data}] across all pools
	for type in pools:
		for d in pools[type]:
			if _rarity_of(d) >= pack_data.rarity:
				candidates.append({ "type": type, "data": d })
	if candidates.is_empty():
		return

	var pick = candidates[randi() % candidates.size()]
	var replacement := _make_offer(pack_data, pick.type, pick.data)

	var weakest := 0                            # swap out the weakest offer, keep `size` offers
	for i in offers.size():
		if _offer_rarity(offers[i]) < _offer_rarity(offers[weakest]):
			weakest = i
	offers[weakest] = replacement

#---------------------------------------------------------------------------------------------------
# Rarity helpers
#---------------------------------------------------------------------------------------------------

func _offer_rarity(offer: OfferData) -> int:
	match offer.type:
		OfferData.Type.RELIC: return _rarity_of(offer.relic_data)
		OfferData.Type.ITEM:  return _rarity_of(offer.item_data)
		OfferData.Type.TOKEN: return _rarity_of(offer.token_data)
	return Rarity.Type.COMMON

func _rarity_of(data) -> int:
	var r = data.get("rarity")                  # null for items/tokens with no rarity → COMMON
	return r if r != null else Rarity.Type.COMMON
