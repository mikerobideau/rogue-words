extends Node
class_name SoundGlobal

const sounds = {
	'token': preload("res://assets/sound/mixkit-game-ball-tap-2073.wav"),
	'water_drop': preload("res://assets/sound/mixkit-arcade-game-jump-coin-216.wav"),
	'small_bonus': preload("res://assets/sound/universfield-game-bonus-03-487857.mp3"),
	'bonus': preload("res://assets/sound/mixkit-arcade-bonus-alert-767.wav"),
	'big_bonus': preload("res://assets/sound/universfield-video-game-bonus-323603.mp3"),
	'blip_select': preload("res://assets/sound/jsfxr/blipSelect.wav"),
	'complete1': preload("res://assets/sound/pixabay/linhmitto-bubble-254777.mp3"),
	'complete2': preload("res://assets/sound/mixkit-game-flute-bonus-2313.wav"),
	'coin2': preload("res://assets/sound/jsfxr/coin1.wav"),
	'coin1': preload("res://assets/sound/pixabay/freesound_community-coin_c_02-102844.mp3"),
	'click': preload("res://assets/sound/jsfxr/click.wav"),
	'click1': preload("res://assets/sound/jsfxr/click (1).wav"),
	'click2': preload("res://assets/sound/jsfxr/click (2).wav"),
	'click3': preload("res://assets/sound/jsfxr/click (3).wav"),
	'click4': preload("res://assets/sound/jsfxr/click (4).wav"),
	'click5': preload("res://assets/sound/jsfxr/click (5).wav"),
	'decay1': preload("res://assets/sound/jsfxr/decay1.wav"),
	'decay2': preload("res://assets/sound/jsfxr/decay2.wav"),
	'decay3': preload("res://assets/sound/jsfxr/decay3.wav"),
	'decay4': preload("res://assets/sound/jsfxr/decay4.wav"),
	'decay5': preload("res://assets/sound/jsfxr/decay5.wav"),
	'decay6': preload("res://assets/sound/jsfxr/decay6.wav"),
	'decay7': preload("res://assets/sound/jsfxr/decay7.wav"),
	'destroyed1': preload("res://assets/sound/jsfxr/destroyed1.wav"),
	'laser_shoot': preload("res://assets/sound/jsfxr/laserShoot.wav"),
	'pack_open1': preload("res://assets/sound/lucadialessandro-intro-sound-180639.mp3"),
	'pack_open2': preload("res://assets/sound/yodguard-item-pickup-1-540174.mp3"),
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
	'liquid1': preload("res://assets/sound/pixabay/freesound_community-splash-6213.mp3"),
	'liquid2': preload("res://assets/sound/pixabay/freesound_community-pouring-water-2015-103711.mp3"),
	'liquid3': preload("res://assets/sound/pixabay/freesound_community-water-splash-46402.mp3"),
	'liquid4': preload("res://assets/sound/pixabay/freesound_community-water-splash-102492.mp3"),
	'pop2': preload("res://assets/sound/pixabay/universfield-bubble-pop-06-351337.mp3"),
	'pop3': preload("res://assets/sound/pixabay/universfield-bubble-popping-229138.mp3"),
	'pop_double': preload("res://assets/sound/pixabay/universfield-bubble-pop-07-487896.mp3"),
	'pop_multiple': preload("res://assets/sound/pixabay/dragon-studio-bubble-pop-406640.mp3"),
	'purchase1': preload("res://assets/sound/alexzavesa-clinking-coins-8-468434.mp3"),
	'purchase2': preload("res://assets/sound/vadim_makes_sound-vintage-cash-drawer-open-1-547824.mp3"),	
	'shimmer_bonus': preload("res://assets/sound/mixkit-extra-bonus-in-a-video-game-2045.wav"),
	'shuffle': preload("res://assets/sound/mixkit-thin-metal-card-deck-shuffle-3175.wav"),
	'success': preload("res://assets/sound/mixkit-fantasy-game-success-notification-270.wav"),
	'synth': preload("res://assets/sound/jsfxr/synth.wav"),
	'splat1': preload("res://assets/sound/pixabay/49053354-splat-305791.mp3"),
	'splat2': preload("res://assets/sound/pixabay/universfield-wet-splat-impact-567197.mp3"),
	'splat3': preload("res://assets/sound/pixabay/universfield-wet-squelch-impact-352302.mp3"),
	'upgrade1': preload("res://assets/sound/jsfxr/upgrade1.wav"),
	'upgrade2': preload("res://assets/sound/jsfxr/upgrade2.wav"),
	'upgrade3': preload("res://assets/sound/jsfxr/upgrade3.wav"),
	'upgrade4': preload("res://assets/sound/jsfxr/upgrade4.wav"),
	'whoosh1': preload("res://assets/sound/pixabay/dragon-studio-simple-whoosh-382724.mp3"),
	'whoosh2': preload("res://assets/sound/pixabay/dragon-studio-whoosh-effect-382717.mp3"),
	'win': preload("res://assets/sound/mixkit-completion-of-a-level-2063.wav"),
	'win2': preload("res://assets/sound/mixkit-final-level-bonus-2061.wav"),
	'win3': preload("res://assets/sound/mixkit-small-win-2020.wav"),
	'win4': preload("res://assets/sound/mixkit-winning-chimes-2015.wav"),
	'small_win': preload("res://assets/sound/mixkit-small-win-2020.wav"),
	'level_up': preload("res://assets/sound/mixkit-game-experience-level-increased-2062.wav"),
	'item_unlocked': preload("res://assets/sound/mixkit-unlock-new-item-game-notification-254.wav"),
	'hazard': preload("res://assets/sound/tunetank.com_video-game-boing-retro.wav"),
	'boss_intro1': preload("res://screens/title/mixkit-movie-whoosh-impact-presentation-2903.wav"),
	'boss_intro2': preload("res://assets/sound/pixabay/dragon-studio-simple-whoosh-02-433006.mp3")
}

const SOUND_MOUSEOVER = 'click5' #click2 or click5

const SOUND_TOKEN = 'click2' #click2, token,
const SOUND_DRAW_TOKEN = 'click2'
const SOUND_TOKEN_DESTROYED = 'splat2' #destroyed1, splat1, splat2, splat3
const SOUND_ENHANCED_SPACE = 'pop2' #small_bonus, water_drop, pop2
const SOUND_ENHANCED_TOKEN = 'water_drop' #small_bonus, power_up8, shimmer_bonus, water_drop
const SOUND_ENHANCED_LETTER_SPACE = 'water_drop' #small_bonus, #bonus, power_up, blip_select, water_drop
const SOUND_ENHANCED_WORD_SPACE = 'water_drop'  #bonus, power_up, blip_select, water_drop
const SOUND_MULT = 'bonus' #power_up

const SOUND_RELIC_SCORE = 'bonus' #small_bonus, bonus, #upgrade4, power_up, blip_select, pop2
const SOUND_RELIC_UPGRADE = 'upgrade1'
const SOUND_RELIC_DECAY = 'decay7'
const SOUND_RELIC_RESET_POSITIVE = 'upgrade2'
const SOUND_RELIC_RESET_NEGATIVE = 'decay4'
const SOUND_RELIC_MONEY = 'coin1'

const SOUND_JUICE = 'liquid4'

const SOUND_WIN = 'win4' #complete1, win, win4

const SOUND_BOSS_INTRO = 'boss_intro2'

const SOUND_ENEMY = 'power_up2' #power_up2, power_up3, power_up4, power_up5
const SOUND_DISABLED = 'laser_shoot' #laser_shoot or synth

const SOUND_SELL = 'purchase1'
const SOUND_PURCHASE = 'purchase1'
const SOUND_REROLL = 'purchase1'
const SOUND_PACK_OPEN = 'pack_open1' #pop_multiple, pack_open2
const SOUND_OFFER_FLIPPED = 'whoosh2' #pop_double, upgrade1
const SOUND_PACK_CLOSED = 'whoosh1'

var sound_disabled := false

func play(sound: String):
	if sound_disabled:
		return
	var player  =AudioStreamPlayer.new()
	add_child(player)
	player.stream = sounds[sound]
	player.play()
	await player.finished
	player.queue_free()
