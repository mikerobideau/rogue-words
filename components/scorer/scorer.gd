extends Node2D
class_name Scorer

var relic_manager: RelicManager

func score_word(found_word: Dictionary) -> WordScore:
	var report := WordScore.new()
	report.word = found_word["word"]
	var total := 0
	for i in found_word["path"].size():
		var tile := _score_tile(found_word["path"][i], found_word["letters"][i])
		report.tiles.append(tile)
		total += tile.score
	report.total = total
	return report

func _score_tile(space: Space, display_letter: String) -> TileScore:
	var tile := TileScore.new()
	tile.space = space
	tile.display_letter = display_letter
	tile.base = space.token.value
	tile.mults = _collect_mults(space)

	var mult := 1
	for m in tile.mults:
		mult *= m["value"]
	tile.mult = mult
	tile.score = tile.base * mult
	return tile

func _collect_mults(space: Space) -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	var space_mult := space.get_mult()
	if space_mult > 1:
		result.append({ "kind": TileScore.MultKind.SPACE, "label": space.data.type_label(), "value": space_mult })

	var enhancement := space.token.data.enhancement
	if enhancement and enhancement.get_mult() > 1:
		result.append({ "kind": TileScore.MultKind.ENHANCEMENT, "label": enhancement.enhancement_name, "value": enhancement.get_mult() })

	if relic_manager:
		var relic_mult := relic_manager.get_mult()
		if relic_mult > 1:
			result.append({ "kind": TileScore.MultKind.RELIC, "label": "Relic", "value": relic_mult })

	return result
