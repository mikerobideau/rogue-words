func score_word(found_word: Dictionary, context: RelicContext) -> WordScore:
	var report := WordScore.new()
	report.word = found_word["word"]
	for i in found_word["path"].size():
		report.tiles.append(_tile_base(found_word["path"][i], found_word["letters"][i]))
	_apply_relics(report, context)
	for tile in report.tiles:
		tile.score = int(round(tile.base * tile.mult))
		report.total += tile.score
	return report

func _tile_base(space: Space, display_letter: String) -> TileScore:
	var tile := TileScore.new()
	tile.space = space
	tile.display_letter = display_letter
	tile.base = float(space.token.value)
	tile.mult = float(space.get_letter_mult())
	if space.token.data.enhancement:
		tile.mult *= space.token.data.enhancement.get_mult()
	return tile

func _apply_relics(report: WordScore, context: RelicContext) -> void:
	for relic in GameState.relics:
		var beat := { "relic": relic, "hits": [] }
		for tile in report.tiles:
			var j := relic.get_juice(context)
			var m := relic.get_mult(context)
			if j != 0.0 or m != 0.0:
				tile.base += j
				tile.mult = (tile.mult + m)
				beat["hits"].append({ "tile": tile, "juice": j, "mult": m })
		if not beat["hits"].is_empty():
			report.relic_beats.append(beat)
