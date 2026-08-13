extends Node2D
class_name Scorer

func score_word(found_word: Dictionary, context: RelicContext) -> WordScore:
	var report := WordScore.new()
	report.word = found_word["word"]
	for i in found_word["path"].size():
		var tile_report = _score_tile(found_word["path"][i], found_word["letters"][i], report.word, context)
		report.tiles.append(tile_report)
	for tile in report.tiles:
		report.total += tile.score
	return report

func _score_tile(space: Space, display_letter: String, word: String, context: RelicContext) -> TileScore:
	var tile := TileScore.new()
	tile.space = space
	tile.display_letter = display_letter
	var token_mult := 0
	if space.token.enhancement:
		space.token.enhancement.on_scored(space.token)
		token_mult = space.token.enhancement.get_mult()

	var juice := float(space.token.value + space.data.get_juice())
	var mult := float(1 + space.data.get_mult() + token_mult)
	
	#if space.token.data.enhancement:
	#	mult *= space.token.data.enhancement.get_mult()
	
	tile.beats.append({ "juice": juice, "mult": mult, "relic": null })

	for relic in context.relics:
		var j = relic.data.get_juice(context)
		var m = relic.data.get_mult(context)
		if j != 0.0 or m != 0.0:
			juice += j
			mult += m
			tile.beats.append({ "juice": juice, "mult": mult, "relic": relic })

	tile.juice = juice
	tile.mult = mult
	tile.score = int(round(juice * mult))
	return tile
