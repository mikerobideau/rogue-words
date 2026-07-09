extends Control
class_name Main

@onready var hud = $Hud
@onready var screen_container = $ScreenContainer
@onready var relic_manager = $RelicManager
@onready var center_panel = $ScreenContainer/CenterPanel

const DEFAULT_CENTER_PANEL_COLOR = '#f5f5f5'

const SCREENS = {
	'title':  preload("res://screens/title/title.tscn"),
	'round': preload("res://screens/round/round.tscn"),
	'shop': preload("res://shop/shop.tscn"),
	'boss_intro': preload("res://screens/boss/boss_intro.tscn"),
	'game_won': preload("res://screens/game_won/game_won.tscn"),
	'game_over': preload("res://screens/game_over/game_over.tscn")
}

var current_screen: Control = null

func _ready():
	size = get_viewport().get_visible_rect().size
	_show_title()
	#_enter_shop()
	#_on_new_game()
	
func _show_title():
	hud.visible = false
	var title = SCREENS.title.instantiate()
	_show_screen(title, {})
	title.new_game.connect(_on_new_game)
	
func _show_boss_intro():
	hud.visible = false
	var boss_intro = SCREENS.boss_intro.instantiate()
	Sound.play('boss_intro')
	boss_intro.title = 'Incoming Storm'
	boss_intro.description = GameState.current_boss.description
	_show_screen(boss_intro, {})
	await get_tree().create_timer(3).timeout
	hud.visible = true
	
func _on_new_game():
	GameState.round_number = 0
	GameState.money = 5
	GameState.tokens = TokenFactory.create_starting_tokens()
	var test_relic = preload("res://components/relic/compost.tres")
	GameState.relics = [test_relic.duplicate()]
	#GameState.relics = [] as Array[RelicData]
	#GameState.items = [] as Array[ItemData]
	GameState.items = _random_items(3)
	hud.visible = true
	var round = SCREENS.round.instantiate()
	_next_round()
	
func _next_round():
	GameState.round_number += 1
	if GameState.is_boss_round:
		await _show_boss_intro()
		hud.title = 'Boss: ' + GameState.current_boss.description
		#center_panel.color = Color.BLACK
	else:
		hud.title = 'Round ' + str(GameState.round_number)
		center_panel.color = DEFAULT_CENTER_PANEL_COLOR
	GameState.tokens.shuffle()
	var round = SCREENS.round.instantiate()
	round.hud = hud
	round.relic_manager = relic_manager
	round.completed.connect(_on_round_completed)
	round.game_over.connect(_on_game_over)
	round.game_won.connect(_on_game_won)
	_show_screen(round, {})
	
func _on_round_completed():
	hud.on_round_complete()
	GameState.discarded_tokens = [] as Array[TokenData]
	_enter_shop()
	
func _enter_shop():
	center_panel.color = DEFAULT_CENTER_PANEL_COLOR
	hud.title = 'Shop'
	var shop = SCREENS.shop.instantiate()
	shop.completed.connect(_next_round)
	_show_screen(shop, {})
	
func _show_screen(screen: Control, config: Dictionary):
	if current_screen:
		current_screen.queue_free()
		current_screen = null
	current_screen = screen
	screen_container.add_child(current_screen)

func _on_game_won():
	Sound.play('win4')
	hud.visible = false
	var game_won = SCREENS.game_won.instantiate()
	_show_screen(game_won, {})
	game_won.new_game.connect(_on_new_game)

func _on_game_over(message: String):
	hud.visible = false
	var game_over = SCREENS.game_over.instantiate()
	_show_screen(game_over, {'message': message})
	game_over.new_game.connect(_on_new_game)
	game_over.subtitle = message
	
#Helpers
func _random_items(n: int) -> Array[ItemData]:
	var all := ItemFactory.load_all_items()
	all.shuffle()
	var result: Array[ItemData] = []
	result.assign(all.slice(0, n))
	return result
	
