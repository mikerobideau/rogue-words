extends Control
class_name Main

@onready var hud = $Hud
@onready var screen_container = $ScreenContainer
@onready var relic_manager = $RelicManager
@onready var item_manager = $ItemManager

var SCREENS = {
	'title':  preload("res://screens/title/title.tscn"),
	'round': preload("res://screens/round/round.tscn"),
	'shop': preload("res://shop/shop.tscn"),
	'boss_intro': preload("res://screens/boss/boss_intro.tscn"),
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
	var boss_intro = SCREENS.boss_intro.instantiate()
	Sound.play('boss_intro')
	boss_intro.title = GameState.current_boss.boss_name
	boss_intro.description = GameState.current_boss.description
	_show_screen(boss_intro, {})
	await get_tree().create_timer(2.5).timeout
	
func _on_game_over(message: String):
	var game_over = SCREENS.game_over.instantiate()
	_show_screen(game_over, {'message': message})
	game_over.new_game.connect(_on_new_game)
	game_over.subtitle = message
	
func _on_new_game():
	GameState.round_number = 0
	GameState.money = 10
	GameState.tokens = TokenFactory.create_starting_tokens()
	GameState.relics = RelicFactory.load_all_relics()
	GameState.items = ItemFactory.load_all_items()
	hud.visible = true
	var round = SCREENS.round.instantiate()
	_next_round()
	
func _next_round():
	GameState.round_number += 1
	if GameState.is_boss_round:
		await _show_boss_intro()
	GameState.tokens.shuffle()
	var round = SCREENS.round.instantiate()
	round.hud = hud
	round.relic_manager = relic_manager
	round.completed.connect(_on_round_completed)
	round.game_over.connect(_on_game_over)
	_show_screen(round, {})
	
func _on_round_completed():
	hud.on_round_complete()
	GameState.discarded_tokens = [] as Array[TokenData]
	_enter_shop()
	
func _enter_shop():
	var shop = SCREENS.shop.instantiate()
	shop.completed.connect(_next_round)
	_show_screen(shop, {})
	
func _show_screen(screen: Control, config: Dictionary):
	if current_screen:
		current_screen.queue_free()
		current_screen = null
	current_screen = screen
	screen_container.add_child(current_screen)
