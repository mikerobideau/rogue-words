extends Node
class_name SoundGlobal

const sounds = {
	'token': preload("res://assets/sound/mixkit-game-ball-tap-2073.wav"),
	'water_drop': preload("res://assets/sound/mixkit-arcade-game-jump-coin-216.wav"),
	'small_bonus': preload("res://assets/sound/universfield-game-bonus-03-487857.mp3"),
	'bonus': preload("res://assets/sound/mixkit-arcade-bonus-alert-767.wav"),
	'big_bonus': preload("res://assets/sound/universfield-video-game-bonus-323603.mp3"),
	'shimmer_bonus': preload("res://assets/sound/mixkit-extra-bonus-in-a-video-game-2045.wav"),
	'shuffle': preload("res://assets/sound/mixkit-thin-metal-card-deck-shuffle-3175.wav"),
	'success': preload("res://assets/sound/mixkit-fantasy-game-success-notification-270.wav"),
	'win': preload("res://assets/sound/mixkit-completion-of-a-level-2063.wav"),
	'win2': preload("res://assets/sound/mixkit-final-level-bonus-2061.wav"),
	'win3': preload("res://assets/sound/mixkit-small-win-2020.wav"),
	'small_win': preload("res://assets/sound/mixkit-small-win-2020.wav"),
	'level_up': preload("res://assets/sound/mixkit-game-experience-level-increased-2062.wav"),
	'item_unlocked': preload("res://assets/sound/mixkit-unlock-new-item-game-notification-254.wav"),
	'complete': preload("res://assets/sound/mixkit-game-flute-bonus-2313.wav"),
	'hazard': preload("res://assets/sound/tunetank.com_video-game-boing-retro.wav"),
}

var player: AudioStreamPlayer

func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)

func play(sound: String):
	player.stream = sounds[sound]
	player.play()
	await player.finished
