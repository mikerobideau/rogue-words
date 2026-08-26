extends Control
class_name Main

@onready var hud = $Hud
@onready var screen_container = $ScreenContainer
@onready var relic_manager = $RelicManager
@onready var rain = $ScreenContainer/RainPanel
@onready var cloud_far = $ScreenContainer/ParallaxBackground/CloudFar
@onready var cloud_near = $ScreenContainer/ParallaxBackground/CloudNear
@onready var music = $Music

const SCREENS = {
	'title':  preload("res://screens/title/title.tscn"),
	'round': preload("res://screens/round/round.tscn"),
	'shop': preload("res://shop/shop.tscn"),
	'map': preload("res://screens/map/map.tscn"),
	'upgrade': preload("res://screens/upgrade_relic/upgrade_relic.tscn"),
	'pickup': preload("res://screens/pickup/pickup.tscn"),
	'boss_intro': preload("res://screens/boss/boss_intro.tscn"),
	'game_won': preload("res://screens/game_won/game_won.tscn"),
	'game_over': preload("res://screens/game_over/game_over.tscn")
}

var current_screen: Control = null
var map: Map
var current_node: MapNode

func _ready():
	size = get_viewport().get_visible_rect().size
	music.play()
	_show_title()
	#GameState.money = 100
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
	Sound.play(Sound.SOUND_BOSS_INTRO)
	boss_intro.title = 'Incoming Storm'
	boss_intro.description = GameState.current_boss.description
	_show_screen(boss_intro, {})
	await get_tree().create_timer(3).timeout
	hud.visible = true
	
func _on_new_game(data: LoadoutData):
	GameState.money = 0
	GameState.tokens = data.create_starting_tokens()
	GameState.relics = [] as Array[RelicData]
	GameState.items = [] as Array[ItemData]
	hud.visible = true
	_new_map()

func _new_map():
	if current_screen:
		current_screen.queue_free()
		current_screen = null
	if is_instance_valid(map):
		map.queue_free()
	map = SCREENS.map.instantiate()
	map.node_selected.connect(_on_map_node_selected)
	map.completed.connect(_on_game_won)
	screen_container.add_child(map)
	_show_map()

func _show_map():
	hud.title = 'The Beanstalk'
	rain.visible = false
	map.visible = true

func _on_map_node_selected(node: MapNode):
	current_node = node
	map.visible = false
	match node.type:
		MapNode.Type.ROUND:
			await _start_round(node)
		MapNode.Type.SHOP:
			_start_shop(node)
		MapNode.Type.UPGRADE:
			_start_upgrade(node)
		MapNode.Type.PICKUP:
			_start_pickup(node)

func _start_round(node: MapNode):
	GameState.current_boss = node.config.boss
	GameState.target_score = node.config.get("target_score", 100)
	GameState.tokens.shuffle()
	if node.config.boss.bosses.size() > 0:
		await _show_boss_intro()
		rain.visible = true
	else:
		hud.title = 'Round'
		rain.visible = false
	var round = SCREENS.round.instantiate()
	round.hud = hud
	round.relic_manager = relic_manager
	round.completed.connect(_on_node_finished)
	round.game_over.connect(_on_game_over)
	_show_screen(round, {})

func _start_shop(node: MapNode):
	hud.title = 'Shop'
	var shop = SCREENS.shop.instantiate()
	shop.num_offers = node.config.get("num_offers", 2)
	shop.num_packs = node.config.get("num_packs", 2)
	shop.completed.connect(_on_node_finished)
	_show_screen(shop, {})

func _start_upgrade(_node: MapNode):
	hud.title = 'Upgrade'
	var up = SCREENS.upgrade.instantiate()
	up.completed.connect(_on_node_finished)
	_show_screen(up, {})

func _start_pickup(_node: MapNode):
	hud.title = 'Pickup'
	var pk = SCREENS.pickup.instantiate()
	pk.completed.connect(_on_node_finished)
	_show_screen(pk, {})

func _on_node_finished():
	if current_node.type == MapNode.Type.ROUND:
		_grant_reward(current_node.config.get("reward", {}))
		hud.on_round_complete()
		GameState.discarded_tokens = [] as Array[TokenData]
	rain.visible = false
	if current_screen:
		current_screen.queue_free()
		current_screen = null
	map.advance(current_node)
	if is_instance_valid(map) and not map.is_queued_for_deletion():
		_show_map()

func _grant_reward(reward: Dictionary):
	GameState.money += reward.get("money", 0)
	for item in reward.get("items", []):
		if GameState.has_empty_item_slot() > 0:
			GameState.add_item(item.duplicate())
	for relic in reward.get("relics", []):
		if GameState.has_empty_relic_slot() > 0:
			GameState.add_relic(relic.duplicate())
	
func _show_screen(screen: Control, config: Dictionary):
	if current_screen:
		current_screen.queue_free()
		current_screen = null
	current_screen = screen
	screen_container.add_child(current_screen)

func _on_game_won():
	Sound.play('win4')
	hud.visible = false
	if is_instance_valid(map):
		map.queue_free()
		map = null
	var game_won = SCREENS.game_won.instantiate()
	_show_screen(game_won, {})
	game_won.new_game.connect(_on_new_game)

func _on_game_over(message: String):
	hud.visible = false
	if is_instance_valid(map):
		map.queue_free()
		map = null
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
	
