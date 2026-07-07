extends Node
class_name GameStateGlobal

signal money_changed(value: int)
signal relics_changed()
signal items_changed()
signal tokens_changed()

#---------------------------------------------------------------------------------------------------
#PROGRESSION
#---------------------------------------------------------------------------------------------------

var target_scores: Array[int] = [
	50, 75, 125, 200, 280,
	350, 430, 520, 620, 730,
	860, 1000, 1150, 1320, 1500,
	1700, 1950, 2250, 2600, 3000, 3500
]

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
