extends Node
class_name SoundGlobal

const sounds = {
	'token': preload("res://assets/sound/mixkit-game-ball-tap-2073.wav"),
	'water_drop': preload("res://assets/sound/mixkit-arcade-game-jump-coin-216.wav"),
	'small_bonus': preload("res://assets/sound/universfield-game-bonus-03-487857.mp3"),
	'bonus': preload("res://assets/sound/mixkit-arcade-bonus-alert-767.wav"),
	'big_bonus': preload("res://assets/sound/universfield-video-game-bonus-323603.mp3"),
	'blip_select': preload("res://assets/sound/jsfxr/blipSelect.wav"),
	'click': preload("res://assets/sound/jsfxr/click.wav"),
	'click1': preload("res://assets/sound/jsfxr/click (1).wav"),
	'click2': preload("res://assets/sound/jsfxr/click (2).wav"),
	'click3': preload("res://assets/sound/jsfxr/click (3).wav"),
	'click4': preload("res://assets/sound/jsfxr/click (4).wav"),
	'click5': preload("res://assets/sound/jsfxr/click (5).wav"),
	'laser_shoot': preload("res://assets/sound/jsfxr/laserShoot.wav"),
	'pickup_coin': preload("res://assets/sound/jsfxr/pickupCoin.wav"),
	'pickup_coin1': preload("res://assets/sound/jsfxr/pickupCoin (1).wav"),
	'pickup_coin2': preload("res://assets/sound/jsfxr/pickupCoin (2).wav"),
	'pickup_coin3': preload("res://assets/sound/jsfxr/pickupCoin (3).wav"),
	'pickup_coin4': preload("res://assets/sound/jsfxr/pickupCoin (4).wav"),
	'power_up': preload("res://assets/sound/jsfxr/powerUp.wav"),
	'power_up1': preload("res://assets/sound/jsfxr/powerUp (1).wav"),
	'power_up2': preload("res://assets/sound/jsfxr/powerUp (2).wav"),
	'power_up3': preload("res://assets/sound/jsfxr/powerUp (3).wav"),
	'power_up4': preload("res://assets/sound/jsfxr/powerUp (4).wav"),
	'power_up5': preload("res://assets/sound/jsfxr/powerUp (5).wav"),
	'power_up6': preload("res://assets/sound/jsfxr/powerUp (6).wav"),
	'power_up7': preload("res://assets/sound/jsfxr/powerUp (7).wav"),
	'power_up8': preload("res://assets/sound/jsfxr/powerUp (8).wav"),
	'random': preload("res://assets/sound/jsfxr/random.wav"),
	'random1': preload("res://assets/sound/jsfxr/random (1).wav"),
	'shimmer_bonus': preload("res://assets/sound/mixkit-extra-bonus-in-a-video-game-2045.wav"),
	'shuffle': preload("res://assets/sound/mixkit-thin-metal-card-deck-shuffle-3175.wav"),
	'success': preload("res://assets/sound/mixkit-fantasy-game-success-notification-270.wav"),
	'synth': preload("res://assets/sound/jsfxr/synth.wav"),
	'win': preload("res://assets/sound/mixkit-completion-of-a-level-2063.wav"),
	'win2': preload("res://assets/sound/mixkit-final-level-bonus-2061.wav"),
	'win3': preload("res://assets/sound/mixkit-small-win-2020.wav"),
	'win4': preload("res://assets/sound/mixkit-winning-chimes-2015.wav"),
	'small_win': preload("res://assets/sound/mixkit-small-win-2020.wav"),
	'level_up': preload("res://assets/sound/mixkit-game-experience-level-increased-2062.wav"),
	'item_unlocked': preload("res://assets/sound/mixkit-unlock-new-item-game-notification-254.wav"),
	'complete': preload("res://assets/sound/mixkit-game-flute-bonus-2313.wav"),
	'hazard': preload("res://assets/sound/tunetank.com_video-game-boing-retro.wav"),
	'boss_intro': preload("res://screens/title/mixkit-movie-whoosh-impact-presentation-2903.wav"),
	'purchase': preload("res://assets/sound/vadim_makes_sound-vintage-cash-drawer-open-1-547824.mp3")	
}

const SOUND_MOUSEOVER = 'click5' #click2 or click5

const SOUND_TOKEN = 'click2' #click2 or token
const SOUND_DRAW_TOKEN = 'click2'
const SOUND_TOKEN_DESTROYED = 'random'

const SOUND_ENHANCED_SPACE = 'small_bonus' #small_bonus, water_drop
const SOUND_ENHANCED_TOKEN = 'water_drop' #small_bonus, power_up8, shimmer_bonus, water_drop
const SOUND_ENHANCED_LETTER_SPACE = 'water_drop' #small_bonus, #bonus, power_up, blip_select, water_drop
const SOUND_ENHANCED_WORD_SPACE = 'water_drop'  #bonus, power_up, blip_select, water_drop
const SOUND_MULT = 'bonus' #power_up

const SOUND_RELIC = 'water_drop' #small_bonus, bonus, power_up, blip_select

const SOUND_ENEMY = 'power_up2' #power_up2, power_up3, power_up4, power_up5
const SOUND_SPLAT = 'power_up7'
const SOUND_DISABLED = 'laser_shoot' #laser_shoot or synth

const SOUND_MONEY = 'pickup_coin4'
const SOUND_PURCHASE = 'purchase'

var player: AudioStreamPlayer

var sound_disabled := false

func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)

func play(sound: String):
	if sound_disabled:
		return
	player.stream = sounds[sound]
	player.play()
	await player.finished
