extends SpaceData
class_name MoneySpace

@export var money: int
@export var required_letter: String
@export var color: Color

func get_text_color() -> Color:
	return color

func get_badge_color() -> Color:
	return color

func get_badge_text() -> String:
	return '$' + str(money)

func get_label_text() -> String:
	return '$' + str(money) + ' on ' + required_letter

func on_token_placed(token) -> void:
	if token is LeafToken:
		return
	if token.letter == required_letter:
		GameState.money += money
		Sound.play(Sound.SOUND_MONEY_EARNED)
		ScorePopup.show(ScorePopup.Template.DEFAULT, '+$' + str(money), token)
