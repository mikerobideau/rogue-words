extends Node
class_name GameStateGlobal

signal money_changed(value: int)
signal relics_changed()
signal items_changed()
signal tokens_changed()
signal token_added()

#---------------------------------------------------------------------------------------------------
#PROGRESSION
#---------------------------------------------------------------------------------------------------

var target_scores: Array[int] = [
	1, 75, 100, 150, 225, 325, 500, 700, 1000, 1500, 2000, 3000, 4500, 6500, 10000
]

var num_rounds = target_scores.size()

#---------------------------------------------------------------------------------------------------
#ROUND
#---------------------------------------------------------------------------------------------------

var target_score: int

var round_number := 0:
	set(v):
		round_number = v
		target_score = target_scores[v - 1]
		discarded_tokens = [] as Array[TokenData]
		is_boss_round = round_number % 3 == 0
		current_boss = BossFactory.random_boss_data() if is_boss_round else BossData.new()
		
#---------------------------------------------------------------------------------------------------
#MONEY
#---------------------------------------------------------------------------------------------------

var money: int:
	set(v):
		money = v
		money_changed.emit(v)

#---------------------------------------------------------------------------------------------------
#TOKENS
#---------------------------------------------------------------------------------------------------

var tokens: Array[TokenData]

func add_token(token: TokenData):
	tokens.append(token)
	tokens_changed.emit()
	token_added.emit(token)

var discarded_tokens: Array[TokenData]

#---------------------------------------------------------------------------------------------------
#RELICS
#---------------------------------------------------------------------------------------------------

var relics: Array[RelicData]
var max_relics = 5

func add_relic(relic: RelicData):
	relics.append(relic)
	relics_changed.emit()
	
func remove_relic(relic: RelicData):
	relics.erase(relic)
	relics_changed.emit()
	
func relic_slots_available():
	return max_relics - relics.size()
	
#---------------------------------------------------------------------------------------------------
#ITEMS
#---------------------------------------------------------------------------------------------------

var items: Array[ItemData]
var max_items = 3

func add_item(item: ItemData):
	items.append(item)
	items_changed.emit()
	
func remove_item(item: ItemData):
	items.erase(item)
	items_changed.emit()

func item_slots_available() -> int:
	return max_items - items.size()

#---------------------------------------------------------------------------------------------------
#BOSS
#---------------------------------------------------------------------------------------------------

var current_boss: BossData
var is_boss_round: bool
