extends "res://prototypes/nine_pocket/nine_pocket_ui.gd"

const D := preload("res://prototypes/nine_pocket/nine_pocket_data.gd")

enum Phase { SHOP, TRADER, JUDGE, RESULT, GAMEOVER, WIN }

class Disc:
	var uid := 0
	var title := ""
	var band := ""
	var cover := ""
	var seed := 0
	var genre := 0
	var era := 0
	var label := 0
	var rarity := 0
	var cond := 0
	var runtime := 40
	var ability := {}

var rng := RandomNumberGenerator.new()
var phase := Phase.SHOP
var round_n := 1
var cash := 0
var next_uid := 1
var sheets: Array = []
var sleeves: Array[String] = []
var view := 0
var judges: Array[Dictionary] = []
var pair_median := {}
var shop_discs: Array[Dictionary] = []
var shop_packs: Array[Dictionary] = []
var shop_sleeves: Array[Dictionary] = []
var reroll_cost := 2
var trader := {}
var sel := Vector2i(-1, -1)
var mode := ""
var mode_i := -1
var paid: Array[Disc] = []
var pack_items: Array[Disc] = []
var pack_keep: Array[bool] = []
var pack_cash := 0
var pack_title := ""
var show_trader := false
var result := {}
var message := ""
var message_t := 0.0
var pack_queue: Array[Dictionary] = []
var steps: Array[Dictionary] = []
var step_i := 0
var step_timer := 0.0
var judging := false
var pending := {}
var shown := {}
var shown_cash := 0
var albums: Array = []
var covers := {}
var slot_flash: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

func _ready() -> void:
	_ui_ready()
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_load_albums()
	_new_run()

func _process(delta: float) -> void:
	message_t = maxf(0.0, message_t - delta)
	for i in 9:
		slot_flash[i] = maxf(0.0, slot_flash[i] - delta * 3.0)
	if judging:
		step_timer -= delta
		if step_timer <= 0.0:
			if step_i < steps.size():
				_play_step(steps[step_i])
				step_i += 1
				step_timer = clampf(7.0 / maxf(1.0, steps.size()), 0.15, 0.45)
			elif step_i == steps.size():
				step_i += 1
				step_timer = 0.9
			else:
				_finish_judging()
	_ui_process(delta)

func _unhandled_input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and ev.pressed:
		var mb := ev as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_ui_click(_ui_mouse())
		elif mb.button_index == MOUSE_BUTTON_RIGHT:
			_cancel()
	elif ev is InputEventKey and ev.pressed and not ev.echo and (ev as InputEventKey).keycode == KEY_ESCAPE:
		show_trader = false
		_cancel()

func _cancel() -> void:
	sel = Vector2i(-1, -1)
	mode = ""
	paid.clear()

func _say(msg: String) -> void:
	message = msg
	message_t = 3.0

func _shuffle(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = arr[i]
		arr[i] = arr[j]
		arr[j] = t

func _weighted(w: Array) -> int:
	var total := 0
	for x in w:
		total += int(x)
	var roll := rng.randi_range(1, maxi(1, total))
	for i in w.size():
		roll -= int(w[i])
		if roll <= 0:
			return i
	return 0

func _new_run() -> void:
	rng.randomize()
	next_uid = 1
	var pairs: Array = []
	for i in D.CATEGORIES.size():
		for j in range(i + 1, D.CATEGORIES.size()):
			pairs.append([D.CATEGORIES[i], D.CATEGORIES[j]])
	_shuffle(pairs)
	judges.clear()
	for k in D.ROUNDS:
		var a: String = pairs[k][0]
		var b: String = pairs[k][1]
		if rng.randf() < 0.5:
			var t := a
			a = b
			b = t
		judges.append({"a": a, "b": b, "name": "The %s %s" % [D.CAT[a]["adj"], D.CAT[b]["noun"]], "target": 0})
	_calibrate()
	cash = D.START_CASH
	round_n = 1
	sheets.clear()
	result = {}
	pack_items.clear()
	pack_queue.clear()
	show_trader = false
	judging = false
	_begin_round()

func _calibrate() -> void:
	var blank: Array = []
	blank.resize(9)
	blank.fill("")
	for k in judges.size():
		var j := judges[k]
		var totals: Array = []
		for t in D.CALIBRATION_SHEETS:
			var sheet: Array = []
			for i in 9:
				var d := _make_disc()
				if d.ability.has("cat") and rng.randf() < D.CALIBRATION_FOCUS:
					d.ability["cat"] = j["a"] if rng.randf() < 0.5 else j["b"]
				sheet.append(d)
			var c: Dictionary = _score(sheet, blank, [sheet])["cats"]
			totals.append(maxi(1, int(c[j["a"]])) * maxi(1, int(c[j["b"]])))
		totals.sort()
		j["target"] = maxi(D.MIN_TARGET, int(round(float(totals[totals.size() / 2]) * D.ROUND_FACTOR[k])))

func _begin_round() -> void:
	var sheet: Array = []
	sheet.resize(9)
	sheets.append(sheet)
	view = sheets.size() - 1
	sleeves.resize(9)
	sleeves.fill("")
	_cancel()
	reroll_cost = D.REROLL_BASE
	_roll_shop_discs()
	shop_packs.clear()
	var pk: Array = D.PACKS.keys()
	_shuffle(pk)
	for i in mini(D.SHOP_PACKS, pk.size()):
		shop_packs.append({"id": pk[i], "sold": false})
	shop_sleeves.clear()
	var sk: Array = D.SLEEVES.keys()
	_shuffle(sk)
	for i in mini(D.SHOP_SLEEVES, sk.size()):
		shop_sleeves.append({"id": sk[i], "sold": false})
	_make_trader()
	slot_flash.fill(0.0)
	phase = Phase.SHOP

func _cur() -> Array:
	return sheets[sheets.size() - 1]

func _open_slots() -> Array[int]:
	var out: Array[int] = []
	var cur := _cur()
	for i in 9:
		if cur[i] == null:
			out.append(i)
	return out

func _load_albums() -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string(D.CATALOG))
	if not data is Array:
		push_error("Missing %s: run tools/make_covers.gd" % D.CATALOG)
		return
	for a in data:
		var g := D.GENRES.find(String(a["genre"]))
		if g < 0:
			push_warning("Unknown genre %s for %s" % [a["genre"], a["album"]])
			continue
		var h := absi(String(a["band"]).hash())
		albums.append({"title": a["album"], "band": a["band"], "cover": a["cover"], "genre": g, "era": h % D.ERAS.size(), "label": (h / 7) % D.LABELS.size()})

func _cover_tex(path: String) -> Texture2D:
	if not covers.has(path):
		var img := Image.load_from_file(ProjectSettings.globalize_path(path))
		if img:
			img.generate_mipmaps()
			covers[path] = ImageTexture.create_from_image(img)
		else:
			covers[path] = null
	return covers[path]

func _make_disc(rarity: int = -1) -> Disc:
	var d := Disc.new()
	d.uid = next_uid
	next_uid += 1
	d.seed = rng.randi()
	var a: Dictionary = albums[rng.randi_range(0, albums.size() - 1)]
	d.title = a["title"]
	d.band = a["band"]
	d.cover = a["cover"]
	d.genre = a["genre"]
	d.era = a["era"]
	d.label = a["label"]
	d.rarity = rarity if rarity >= 0 else _weighted(D.RARITY_WEIGHTS)
	d.cond = _weighted(D.CONDITION_WEIGHTS)
	d.runtime = rng.randi_range(D.RUNTIME_MIN, D.RUNTIME_MAX)
	d.ability = _make_ability(d.rarity)
	return d

func _make_ability(r: int) -> Dictionary:
	var keys: Array = D.ABILITY_WEIGHTS.keys()
	var w: Array = []
	for k in keys:
		w.append(D.ABILITY_WEIGHTS[k][r])
	var kind: String = keys[_weighted(w)]
	var a := {"kind": kind, "when": String(D.ABILITY_WHEN.get(kind, "activated")), "cat": D.CATEGORIES[rng.randi_range(0, D.CATEGORIES.size() - 1)], "n": 0}
	var attrs := ["era", "genre", "label"]
	match kind:
		"flat":
			a["n"] = 2 + 2 * r
		"per_attr":
			a["scope"] = D.SCOPES[rng.randi_range(0, D.SCOPES.size() - (1 if r > 0 else 2))]
			a["f"] = _rand_cond()
			a["n"] = 2 if r == 2 and a["scope"] != "binder" else 1
		"distinct":
			a["attr"] = attrs[rng.randi_range(0, 2)]
			a["n"] = 1 + mini(r, 1)
		"neighbor_match":
			a["attr"] = attrs[rng.randi_range(0, 2)]
			a["n"] = 2 + r
		"era_step":
			a["n"] = 2 + r
		"runtime":
			a["n"] = 1
		"slot_bonus":
			a["slot"] = ["corner", "center", "edge"][rng.randi_range(0, 2)]
			a["n"] = (6 if a["slot"] == "center" else 3) + 2 * r
		"self_mint":
			a["n"] = 4 + 2 * r
		"cond_balance":
			a["n"] = 1
			if rng.randf() < 0.5:
				a["cat"] = "condition"
		"cash":
			a["n"] = 1 + 2 * r
		"gen_cash":
			a["n"] = 2 + 2 * r
		"sold_cash":
			a["n"] = 3 + 3 * r
	return a

func _filter_text(c: Dictionary) -> String:
	return _cond_text(c).trim_prefix("1 ")

func _ability_text(a: Dictionary) -> String:
	if a.is_empty():
		return ""
	var pre: String = {"activated": "Activated: ", "placed": "Placed: ", "sold": "Sold: "}[a["when"]]
	var cn := String(D.CAT[a["cat"]]["name"])
	var n := int(a["n"])
	var t := ""
	match String(a["kind"]):
		"flat":
			t = "+%d %s." % [n, cn]
		"per_attr":
			t = "+%d %s per %s disc in %s." % [n, cn, _filter_text(a["f"]), D.SCOPE_TEXT[a["scope"]]]
		"distinct":
			t = "+%d %s per distinct %s on this sheet." % [n, cn, D.ATTR_TEXT[a["attr"]]]
		"neighbor_match":
			t = "+%d %s per neighbor with the same %s." % [n, cn, D.ATTR_TEXT[a["attr"]]]
		"era_step":
			t = "+%d %s per neighbor one decade apart." % [n, cn]
		"runtime":
			t = "+%d %s per %d min of its runtime." % [n, cn, D.RUNTIME_STEP]
		"slot_bonus":
			t = "+%d %s if in a %s slot." % [n, cn, a["slot"]]
		"self_mint":
			t = "+%d %s if this disc is Mint." % [n, cn]
		"cond_balance":
			t = "+%d %s per Mint disc in your binder, -%d per Worn." % [n, cn, n]
		"retrigger_left":
			t = "Retrigger the disc to its left."
		"retrigger_nbrs":
			t = "Retrigger all neighboring discs."
		"double":
			t = "Double the current %s." % cn
		"cash", "gen_cash":
			t = "Gain $%d." % n
		"gen_pack":
			t = "Get a free Bargain Bin bundle."
		"sold_cash":
			t = "Gain $%d extra." % n
		"sold_rare":
			t = "Create a random Rare album."
	return pre + t

func _sell_price(d: Disc) -> int:
	return D.SELL_BASE[d.rarity] + d.cond

func _buy_price(d: Disc) -> int:
	return _sell_price(d) * D.BUY_MULT + (D.ABILITY_PREMIUM if not d.ability.is_empty() else 0)

func _sl(sl: Array, i: int) -> String:
	return String(sl[i]) if i < sl.size() else ""

func _attr(d: Disc, attr: String) -> int:
	match attr:
		"genre":
			return d.genre
		"era":
			return d.era
	return d.label

func _meets_s(d: Disc, s: String, c: Dictionary) -> bool:
	var v := int(c["v"])
	match String(c["attr"]):
		"genre":
			return d.genre == v or s == "wild"
		"cond":
			return (2 if s == "polish" else d.cond) >= v
		"rarity":
			return mini(2, d.rarity + (1 if s == "grade" else 0)) >= v
	return _meets(d, c)

func _nbrs(i: int) -> Array[int]:
	var out: Array[int] = []
	if i >= 3:
		out.append(i - 3)
	if i < 6:
		out.append(i + 3)
	if i % 3 > 0:
		out.append(i - 1)
	if i % 3 < 2:
		out.append(i + 1)
	return out

func _scope_slots(i: int, scope: String) -> Array[int]:
	match scope:
		"row":
			return [i / 3 * 3, i / 3 * 3 + 1, i / 3 * 3 + 2]
		"column":
			return [i % 3, i % 3 + 3, i % 3 + 6]
		"neighbors":
			return _nbrs(i)
	return [0, 1, 2, 3, 4, 5, 6, 7, 8]

func _slot_is(i: int, slot: String) -> bool:
	match slot:
		"corner":
			return i in [0, 2, 6, 8]
		"center":
			return i == 4
	return i in [1, 3, 5, 7]

func _score(sheet: Array, sl: Array, binder: Array) -> Dictionary:
	var ctx := {"cats": {}, "cash": 0, "steps": [], "sheet": sheet, "sl": sl, "binder": binder}
	for k in D.CATEGORIES:
		ctx["cats"][k] = 0
	for i in 9:
		if sheet[i] != null:
			_activate(ctx, i, false)
	return ctx

func _push(ctx: Dictionary, slot: int, kind: String, cat: String, n: int) -> void:
	if n == 0 and kind != "again":
		return
	match kind:
		"add":
			ctx["cats"][cat] += n
		"mul":
			ctx["cats"][cat] *= n
		"cash":
			ctx["cash"] += n
	ctx["steps"].append({"slot": slot, "kind": kind, "cat": cat, "n": n, "cats": ctx["cats"].duplicate(), "cash": ctx["cash"]})

func _activate(ctx: Dictionary, i: int, again: bool) -> void:
	var s := _sl(ctx["sl"], i)
	var times := 2 if s == "echo" and not again else 1
	for t in times:
		if again or t > 0:
			_push(ctx, i, "again", "", 0)
		_fire(ctx, i, again)
		if s == "gold":
			_push(ctx, i, "cash", "", 2)

func _fire(ctx: Dictionary, i: int, again: bool) -> void:
	var sheet: Array = ctx["sheet"]
	var sl: Array = ctx["sl"]
	var d: Disc = sheet[i]
	var a := d.ability
	if a.is_empty() or String(a["when"]) != "activated":
		return
	var s := _sl(sl, i)
	var n := int(a["n"]) + (D.AMP_BONUS if s == "amp" else 0)
	var cat := String(a["cat"])
	match String(a["kind"]):
		"flat":
			_push(ctx, i, "add", cat, n)
		"per_attr":
			var m := 0
			if a["scope"] == "binder":
				for sh: Array in ctx["binder"]:
					for j in 9:
						if sh[j] != null and _meets_s(sh[j], _sl(sl, j) if is_same(sh, sheet) else "", a["f"]):
							m += 1
			else:
				for j in _scope_slots(i, String(a["scope"])):
					if sheet[j] != null and _meets_s(sheet[j], _sl(sl, j), a["f"]):
						m += 1
			_push(ctx, i, "add", cat, n * m)
		"distinct":
			var seen := {}
			for j in 9:
				if sheet[j] != null:
					seen[-1 if a["attr"] == "genre" and _sl(sl, j) == "wild" else _attr(sheet[j], a["attr"])] = true
			_push(ctx, i, "add", cat, n * seen.size())
		"neighbor_match":
			var m := 0
			for j in _nbrs(i):
				var e: Disc = sheet[j]
				if e != null and (_attr(e, a["attr"]) == _attr(d, a["attr"]) or (a["attr"] == "genre" and (s == "wild" or _sl(sl, j) == "wild"))):
					m += 1
			_push(ctx, i, "add", cat, n * m)
		"era_step":
			var m := 0
			for j in _nbrs(i):
				if sheet[j] != null and absi(sheet[j].era - d.era) == 1:
					m += 1
			_push(ctx, i, "add", cat, n * m)
		"runtime":
			_push(ctx, i, "add", cat, n * (d.runtime / D.RUNTIME_STEP))
		"slot_bonus":
			if _slot_is(i, String(a["slot"])):
				_push(ctx, i, "add", cat, n)
		"self_mint":
			if (2 if s == "polish" else d.cond) == 2:
				_push(ctx, i, "add", cat, n)
		"cond_balance":
			var m := 0
			for sh: Array in ctx["binder"]:
				for j in 9:
					if sh[j] != null:
						var c: int = 2 if is_same(sh, sheet) and _sl(sl, j) == "polish" else sh[j].cond
						m += 1 if c == 2 else (-1 if c == 0 else 0)
			_push(ctx, i, "add", cat, n * m)
		"retrigger_left":
			if not again and i % 3 > 0 and sheet[i - 1] != null:
				_activate(ctx, i - 1, true)
		"retrigger_nbrs":
			if not again:
				for j in _nbrs(i):
					if sheet[j] != null:
						_activate(ctx, j, true)
		"double":
			_push(ctx, i, "mul", cat, 2)
		"cash":
			_push(ctx, i, "cash", "", n)

func _roll_shop_discs() -> void:
	shop_discs.clear()
	for i in D.SHOP_DISCS:
		var d := _make_disc()
		shop_discs.append({"disc": d, "price": _buy_price(d), "sold": false})

func _reroll() -> void:
	if cash < reroll_cost:
		return
	cash -= reroll_cost
	reroll_cost += 1
	_roll_shop_discs()

func _place(d: Disc) -> bool:
	var open := _open_slots()
	if open.is_empty():
		return false
	_cur()[open[0]] = d
	_sfx("page_turn")
	var a := d.ability
	if not a.is_empty() and String(a["when"]) == "placed":
		match String(a["kind"]):
			"gen_cash":
				cash += int(a["n"])
				_float(_slot_rect(open[0]), "+$%d" % int(a["n"]), c_gold)
			"gen_pack":
				_queue_pack("bargain", "Free Bargain Bin from %s" % d.title)
	return true

func _on_sold(d: Disc) -> void:
	var a := d.ability
	if a.is_empty() or String(a["when"]) != "sold":
		return
	match String(a["kind"]):
		"sold_cash":
			cash += int(a["n"])
		"sold_rare":
			_queue_pack("", "Created by %s" % d.title, [_make_disc(2)])

func _buy_disc(i: int) -> void:
	var o := shop_discs[i]
	if bool(o["sold"]) or cash < int(o["price"]):
		return
	if _open_slots().is_empty():
		_say("No open slot on this sheet. Sell or trade a disc first.")
		return
	cash -= int(o["price"])
	_place(o["disc"])
	o["sold"] = true

func _buy_pack(i: int) -> void:
	var o := shop_packs[i]
	var p: Dictionary = D.PACKS[o["id"]]
	if bool(o["sold"]) or cash < int(p["price"]):
		return
	cash -= int(p["price"])
	o["sold"] = true
	_queue_pack(String(o["id"]), String(p["name"]))

func _queue_pack(id: String, title: String, items: Array = []) -> void:
	pack_queue.append({"id": id, "title": title, "items": items})
	if pack_items.is_empty():
		_next_pack()

func _next_pack() -> void:
	if pack_queue.is_empty():
		return
	var q: Dictionary = pack_queue.pop_front()
	pack_items.clear()
	pack_keep.clear()
	pack_cash = 0
	if (q["items"] as Array).is_empty():
		var p: Dictionary = D.PACKS[q["id"]]
		for k in int(p["discs"]):
			pack_items.append(_make_disc(_weighted(p["rarity"])))
		pack_cash = rng.randi_range(int(p["cash"][0]), int(p["cash"][1]))
	else:
		for x in q["items"]:
			pack_items.append(x)
	var free := _open_slots().size()
	for k in pack_items.size():
		pack_keep.append(k < free)
	pack_title = String(q["title"])
	_sfx("page_turn")

func _kept() -> int:
	var n := 0
	for k in pack_keep:
		if k:
			n += 1
	return n

func _toggle_keep(i: int) -> void:
	pack_keep[i] = not pack_keep[i]

func _close_pack() -> void:
	if _kept() > _open_slots().size():
		return
	var keep: Array[Disc] = []
	var gone: Array[Disc] = []
	for i in pack_items.size():
		if pack_keep[i]:
			keep.append(pack_items[i])
		else:
			gone.append(pack_items[i])
			cash += _sell_price(pack_items[i])
	cash += pack_cash
	pack_items.clear()
	pack_keep.clear()
	for d in keep:
		_place(d)
	for d in gone:
		_on_sold(d)
	if pack_items.is_empty():
		_next_pack()

func _start_sleeve(i: int) -> void:
	if cash < int(D.SLEEVES[shop_sleeves[i]["id"]]["price"]):
		return
	_cancel()
	mode = "sleeve"
	mode_i = i

func _sell_selected() -> void:
	if sel.x < 0:
		return
	var d: Disc = sheets[sel.x][sel.y]
	if d == null:
		return
	var price := _sell_price(d)
	cash += price
	sheets[sel.x][sel.y] = null
	_float(_slot_rect(sel.y), "+$%d" % price, c_gold)
	sel = Vector2i(-1, -1)
	_on_sold(d)

func _rand_cond(exclude: String = "") -> Dictionary:
	var attrs: Array = ["genre", "era", "label", "cond", "rarity"]
	attrs.erase(exclude)
	var attr: String = attrs[rng.randi_range(0, attrs.size() - 1)]
	var v := 0
	match attr:
		"genre":
			v = rng.randi_range(0, D.GENRES.size() - 1)
		"era":
			v = rng.randi_range(0, D.ERAS.size() - 1)
		"label":
			v = rng.randi_range(0, D.LABELS.size() - 1)
		"cond", "rarity":
			v = rng.randi_range(1, 2)
	return {"attr": attr, "v": v}

func _meets(d: Disc, c: Dictionary) -> bool:
	var v := int(c["v"])
	match String(c["attr"]):
		"genre":
			return d.genre == v
		"era":
			return d.era == v
		"label":
			return d.label == v
		"cond":
			return d.cond >= v
		"rarity":
			return d.rarity >= v
	return false

func _cond_text(c: Dictionary) -> String:
	var v := int(c["v"])
	match String(c["attr"]):
		"genre":
			return "1 %s" % D.GENRES[v]
		"era":
			return "1 %s" % D.ERAS[v]
		"label":
			return "1 %s" % D.LABELS[v]["short"]
		"cond":
			return "1 Mint" if v == 2 else "1 Good+"
		"rarity":
			return "1 Rare" if v == 2 else "1 Uncommon+"
	return ""

func _cost_text(cost: Array) -> String:
	var parts: Array[String] = []
	for c in cost:
		parts.append(_cond_text(c))
	return " + ".join(parts)

func _make_trader() -> void:
	var l1 := _rand_cond()
	var l2 := _rand_cond(String(l1["attr"]))
	var offers: Array = []
	for i in D.TRADER_OFFERS:
		var r := _weighted(D.TRADER_RARITY)
		var cost: Array = []
		if r == 2 or (r == 1 and rng.randf() < 0.5):
			cost = [l1, l2]
		else:
			cost = [l1 if rng.randf() < 0.5 else l2]
		offers.append({"disc": _make_disc(r), "cost": cost, "done": false})
	trader = {"name": D.TRADERS[rng.randi_range(0, D.TRADERS.size() - 1)], "likes": [l1, l2], "offers": offers}

func _unmet() -> Array:
	var out: Array = []
	if mode != "pay":
		return out
	for c in trader["offers"][mode_i]["cost"]:
		var ok := false
		for d in paid:
			if _meets(d, c):
				ok = true
		if not ok:
			out.append(c)
	return out

func _useful(d: Disc) -> bool:
	if d in paid:
		return false
	for c in _unmet():
		if _meets(d, c):
			return true
	return false

func _start_trade(i: int) -> void:
	_cancel()
	mode = "pay"
	mode_i = i

func _pay_with(d: Disc) -> void:
	if not _useful(d):
		_say("That disc doesn't meet the trader's terms.")
		return
	paid.append(d)
	if _unmet().is_empty():
		_finish_trade()

func _finish_trade() -> void:
	var cur := _cur()
	var freed := 0
	for d in paid:
		if d in cur:
			freed += 1
	if _open_slots().size() + freed == 0:
		_say("The new disc needs an open slot on this sheet.")
		_cancel()
		return
	for sh: Array in sheets:
		for i in 9:
			if sh[i] != null and sh[i] in paid:
				sh[i] = null
	var o: Dictionary = trader["offers"][mode_i]
	_place(o["disc"])
	o["done"] = true
	_cancel()

func _on_slot(si: int, slot: int) -> void:
	var d: Disc = sheets[si][slot]
	var current := si == sheets.size() - 1
	match mode:
		"sleeve":
			if not current:
				return
			var o := shop_sleeves[mode_i]
			var price := int(D.SLEEVES[o["id"]]["price"])
			if cash < price:
				return
			cash -= price
			sleeves[slot] = String(o["id"])
			o["sold"] = true
			_cancel()
			return
		"pay":
			if d != null:
				_pay_with(d)
			return
	if sel.x == si and sel.y == slot:
		sel = Vector2i(-1, -1)
		return
	if sel.x >= 0 and current and sel.x == si:
		var t = sheets[si][slot]
		sheets[si][slot] = sheets[si][sel.y]
		sheets[si][sel.y] = t
		sel = Vector2i(-1, -1)
		_sfx("page_turn")
		return
	sel = Vector2i(si, slot) if d != null else Vector2i(-1, -1)

func _go_trader() -> void:
	_cancel()
	view = sheets.size() - 1
	phase = Phase.TRADER

func _go_judge() -> void:
	_cancel()
	view = sheets.size() - 1
	phase = Phase.JUDGE
	shown = {}
	shown_cash = 0

func _start_judging() -> void:
	if judging or phase != Phase.JUDGE:
		return
	_cancel()
	view = sheets.size() - 1
	pending = _score(_cur(), sleeves, sheets)
	steps.assign(pending["steps"])
	shown = {}
	shown_cash = 0
	step_i = 0
	step_timer = 0.4
	judging = true

func _play_step(st: Dictionary) -> void:
	shown = st["cats"]
	shown_cash = int(st["cash"])
	var slot := int(st["slot"])
	slot_flash[slot] = 1.0
	var j := judges[round_n - 1]
	var cat := String(st["cat"])
	var n := int(st["n"])
	var cn := String(D.CAT[cat]["name"]) if cat != "" else ""
	var col := Color(0.75, 0.78, 0.82)
	if cat == j["a"]:
		col = Color("8fc1ff")
	elif cat == j["b"]:
		col = Color("ff9a86")
	var text := "Again!"
	match String(st["kind"]):
		"add":
			text = "%+d %s" % [n, cn]
		"mul":
			text = "x%d %s" % [n, cn]
		"cash":
			text = "+$%d" % n
			col = c_gold
	_float(_slot_rect(slot), text, col)
	_sfx("mouseover")

func _finish_judging() -> void:
	judging = false
	var j := judges[round_n - 1]
	var c: Dictionary = pending["cats"]
	var a := maxi(1, int(c[j["a"]]))
	var b := maxi(1, int(c[j["b"]]))
	var hit := a * b >= int(j["target"])
	var reward := D.CLEAR_REWARD[round_n - 1] if hit else 0
	cash += int(pending["cash"]) + reward
	result = {"a": a, "b": b, "total": a * b, "target": int(j["target"]), "cash": int(pending["cash"]), "hit": hit, "reward": reward}
	phase = Phase.RESULT

func _result_next() -> void:
	if not bool(result["hit"]):
		phase = Phase.GAMEOVER
	elif round_n >= D.ROUNDS:
		phase = Phase.WIN
	else:
		round_n += 1
		_begin_round()

func _view_step(dir: int) -> void:
	view = clampi(view + dir, 0, sheets.size() - 1)
	sel = Vector2i(-1, -1)

func _slot_rect(i: int) -> Rect2:
	return Rect2(r_grid.position.x + (i % 3) * (CARD_W + GAP), r_grid.position.y + (i / 3) * (CARD_H + GAP), CARD_W, CARD_H)

func _disc_count() -> int:
	var n := 0
	for sh: Array in sheets:
		for x in sh:
			if x != null:
				n += 1
	return n

func _disc_tip(d: Disc) -> String:
	var t := "%s\nby %s\n%s · %s · %s\n%s · %s · %d min" % [d.title, d.band, D.GENRES[d.genre], D.ERAS[d.era], D.LABELS[d.label]["name"], D.RARITIES[d.rarity], D.CONDITIONS[d.cond], d.runtime]
	if not d.ability.is_empty():
		t += "\n" + _ability_text(d.ability)
	return t + "\nSells for $%d" % _sell_price(d)

func _draw() -> void:
	_begin_draw()
	var modal := not pack_items.is_empty() or show_trader or phase in [Phase.RESULT, Phase.GAMEOVER, Phase.WIN]
	ui_live = not modal and not judging
	_draw_header()
	var old := view < sheets.size() - 1
	var shopping := phase == Phase.SHOP or phase == Phase.TRADER
	var left := "RECORD STORE" if phase == Phase.SHOP else ("TRADER" if phase == Phase.TRADER else "JUDGE")
	_draw_padfolio(left, "SHEET %d%s" % [view + 1, "  ·  LOCKED" if old else ""], "COUNTER" if shopping else "SCOREBOARD")
	match phase:
		Phase.SHOP:
			_draw_shop()
		Phase.TRADER:
			_draw_trader()
		_:
			_draw_judge_panel()
	_draw_binder()
	if shopping:
		_draw_counter()
	else:
		_draw_scoreboard()
	_draw_floaters()
	ui_live = true
	if not pack_items.is_empty():
		_draw_pack()
	elif show_trader:
		_draw_preview()
	match phase:
		Phase.RESULT:
			_draw_result()
		Phase.GAMEOVER:
			_draw_end("The judge walked away", "Your binder lasted %d of %d judges." % [round_n - 1, D.ROUNDS], c_bad)
		Phase.WIN:
			_draw_end("Collection complete!", "All %d judges were impressed." % D.ROUNDS, c_good)
	_end_draw()

func _draw_header() -> void:
	_foil(Vector2(p_left.position.x + 6.0, HEADER_Y + 80.0), "NINE POCKET", T_HERO)
	_text(Vector2(p_left.position.x + 8.0, HEADER_Y + 120.0), "Now: %s" % ["Store", "Trade", "Judge", "Judge", "Judge", "Judge"][phase], T_SM, Color("98a4b6"), true)
	var x0 := p_binder.position.x
	var w := (p_right.end.x - x0 - 80.0) / 5.0
	var y := HEADER_Y + 12.0
	var j := judges[round_n - 1]
	var boxes := [["ROUND", "%d / %d" % [round_n, D.ROUNDS], c_light], ["CASH", "$%d" % cash, c_gold], ["DISCS", str(_disc_count()), c_light], ["JUDGE", String(j["name"]), c_light], ["TARGET", "%s × %s ≥ %d" % [D.CAT[j["a"]]["name"], D.CAT[j["b"]]["name"], int(j["target"])], c_light]]
	for i in boxes.size():
		_stat_box(Rect2(x0 + i * (w + 20.0), y, w, 112.0), boxes[i][0], boxes[i][1], boxes[i][2])

func _draw_binder() -> void:
	var sheet: Array = sheets[view]
	var current := view == sheets.size() - 1
	var sr := _sheet_rect()
	_panel(sr.grow(6.0), Color("2b221d"), 14)
	var bar := Rect2(p_binder.position.x + 16.0, sr.position.y + 20.0, 18.0, sr.size.y - 40.0)
	_grad_panel(bar, 6.0, Color("d7dde3"), Color("8a939c"))
	_panel(sr, Color(Color("dfe7f1"), 0.09), 16, Color(1, 1, 1, 0.16), 2)
	_draw_rings()
	_ghost(Rect2(p_binder.end.x - 196.0, p_binder.position.y + 12.0, 80.0, 44.0), "<", _view_step.bind(-1), view > 0 and mode != "sleeve", c_light)
	_ghost(Rect2(p_binder.end.x - 108.0, p_binder.position.y + 12.0, 80.0, 44.0), ">", _view_step.bind(1), view < sheets.size() - 1, c_light)
	var live := phase == Phase.SHOP or phase == Phase.TRADER
	for i in 9:
		var r := _slot_rect(i)
		var pocket := r.grow(GAP * 0.5 - 1.0)
		var sl := sleeves[i] if current else ""
		if sl != "":
			_panel(pocket, Color(Color(D.SLEEVES[sl]["color"]), 0.22), 8, Color(D.SLEEVES[sl]["color"]), 4)
		else:
			_panel(pocket, Color(1, 1, 1, 0.025), 8, Color(1, 1, 1, 0.13), 2)
		_pocket_lip(pocket)
		var d: Disc = sheet[i]
		if d == null:
			var label := str(i + 1) if current else "HOLE"
			_heavy_center(r, label, 72 if current else T_XL, Color(1, 1, 1, 0.12))
		else:
			_draw_cd(r, d, not current)
			_tip(r, _disc_tip(d))
		if current and slot_flash[i] > 0.0:
			_panel(r.grow(5.0), Color(0, 0, 0, 0), 16, Color(c_gold, slot_flash[i]), 6)
		if mode == "sleeve" and current:
			_panel(r, Color(c_accent, 0.25 + 0.1 * sin(clock * 5.0)), 12, Color(c_accent.lightened(0.35), 0.9), 3)
		elif mode == "pay" and d != null and _useful(d):
			_panel(r.grow(4.0), Color(0, 0, 0, 0), 14, Color("7fe0a0", 0.8 + 0.2 * sin(clock * 5.0)), 6)
		elif mode == "pay" and d != null and d in paid:
			_panel(r.grow(4.0), Color(0, 0, 0, 0), 14, c_gold, 6)
		elif sel == Vector2i(view, i):
			_panel(r.grow(4.0), Color(0, 0, 0, 0), 14, c_gold, 6)
		elif sel.x == view and current and mode == "":
			_panel(r, Color(c_accent, 0.12), 12)
		if sl != "":
			var tag := String(D.SLEEVES[sl]["name"]).to_upper()
			var tw := _text_w(tag, T_XS, true) + 20.0
			var tr := Rect2(r.get_center().x - tw * 0.5, r.end.y - 6.0, tw, 24.0)
			_panel(tr, Color(D.SLEEVES[sl]["color"]).darkened(0.2), 12)
			_text_center(tr, tag, T_XS, Color.WHITE, true)
			_tip(tr, "%s sleeve: %s" % [D.SLEEVES[sl]["name"], D.SLEEVES[sl]["text"]])
		_sleeve_gloss(r)
		if live:
			_register(r, _on_slot.bind(view, i))

func _draw_cd(r: Rect2, d: Disc, dim: bool) -> void:
	var c := r.get_center()
	var rad := minf(r.size.x, r.size.y) * 0.5 - 8.0
	_cd_art(c, rad, _cover_tex(d.cover))
	if dim:
		draw_circle(c, rad, Color(0, 0, 0, 0.35))

func _draw_case(r: Rect2, d: Disc, price: int = -1) -> void:
	var k := r.size.y / 160.0
	var lab: Dictionary = D.LABELS[d.label]
	_shadow(r, int(6.0 * k), 5.0 * k)
	_panel(r, Color("c9d2db"), int(4.0 * k))
	var body := r.grow(-2.0 * k)
	_panel(body, Color("1b1e23"), int(3.0 * k))
	var pad := 5.0 * k
	var side := r.size.y - 2.0 * pad
	var cover := Rect2(r.end.x - side - pad, r.position.y + pad, side, side)
	var spine := Rect2(body.position.x, body.position.y, cover.position.x - body.position.x - 2.0 * k, body.size.y)
	_grad_panel(spine, 2.0 * k, Color("3a4048"), Color("23272d"))
	for j in 3:
		var sx := spine.position.x + spine.size.x * (0.3 + j * 0.2)
		draw_line(Vector2(sx, spine.position.y + 8.0 * k), Vector2(sx, spine.end.y - 8.0 * k), Color(1, 1, 1, 0.12), maxf(1.0, 1.5 * k))
	for y in [spine.position.y + 4.0 * k, spine.end.y - 14.0 * k]:
		_panel(Rect2(spine.position.x + 2.0 * k, y, spine.size.x - 4.0 * k, 10.0 * k), Color("8c96a1"), int(2.0 * k))
	var tex := _cover_tex(d.cover)
	if tex:
		draw_texture_rect(tex, cover, false)
	else:
		_draw_art(cover, d.seed, d.title, Color(lab["color"]), Color(lab["trim"]))
	_panel(cover, Color(0, 0, 0, 0), 0, Color(0, 0, 0, 0.55), maxi(1, int(1.5 * k)))
	var gloss := PackedVector2Array([r.position + Vector2(r.size.x * 0.35, 0), r.position + Vector2(r.size.x * 0.62, 0), r.position + Vector2(r.size.x * 0.3, r.size.y), r.position + Vector2(r.size.x * 0.03, r.size.y)])
	draw_colored_polygon(gloss, Color(1, 1, 1, 0.07))
	draw_line(r.position + Vector2(4.0 * k, 2.0 * k), Vector2(r.end.x - 4.0 * k, r.position.y + 2.0 * k), Color(1, 1, 1, 0.6), maxf(1.0, 1.5 * k))
	var era: String = D.ERAS[d.era]
	var ec := cover.position + Vector2(20.0, 20.0) * k
	draw_circle(ec + Vector2(1, 2) * k, 16.0 * k, Color(0, 0, 0, 0.3))
	draw_circle(ec, 16.0 * k, Color("fbfaf5"))
	draw_arc(ec, 13.0 * k, 0, TAU, 24, Color("c0392b"), maxf(1.0, 1.5 * k), true)
	_heavy_center(Rect2(ec - Vector2(16, 16) * k, Vector2(32, 32) * k), era, _fs(13.0, k), c_ink)
	if price >= 0:
		var pt := "$%d" % price
		var pfs := _fs(22.0, k)
		var pw := _heavy_w(pt, pfs) + 20.0 * k
		_rotated(Vector2(cover.end.x - pw * 0.5 - 2.0 * k, cover.position.y + 14.0 * k), 0.12)
		var pr := Rect2(-pw * 0.5, -15.0 * k, pw, 30.0 * k)
		_panel(Rect2(pr.position + Vector2(1, 2) * k, pr.size), Color(0, 0, 0, 0.3), int(3.0 * k))
		_panel(pr, Color("ffd23f"), int(3.0 * k))
		draw_line(Vector2(pr.position.x + 5.0 * k, pr.end.y - 5.0 * k), Vector2(pr.end.x - 5.0 * k, pr.end.y - 5.0 * k), Color(0, 0, 0, 0.2), maxf(1.0, k))
		_heavy_center(pr, pt, pfs, Color("8a1c12"))
		_unrotated()
	var g: String = D.GENRES[d.genre].to_upper()
	var gfs := _fs(12.0, k)
	var gw := _text_w(g, gfs, true) + 16.0 * k
	_rotated(Vector2(cover.position.x + gw * 0.5 + 6.0 * k, cover.end.y - 16.0 * k), -0.05)
	var gr := Rect2(-gw * 0.5, -11.0 * k, gw, 22.0 * k)
	_panel(Rect2(gr.position + Vector2(1, 2) * k, gr.size), Color(0, 0, 0, 0.3), int(11.0 * k))
	_panel(gr, Color(D.GENRE_COLORS[d.genre]), int(11.0 * k), Color(1, 1, 1, 0.85), maxi(1, int(1.5 * k)))
	_text_center(gr, g, gfs, Color.WHITE, true)
	_unrotated()
	if d.rarity > 0:
		_sticker_burst(Vector2(cover.end.x - 22.0 * k, cover.end.y - 22.0 * k), 21.0 * k, Color(D.RARITY_COLORS[d.rarity]).darkened(0.1), "RARE" if d.rarity == 2 else "UNC", _fs(11.0, k))

func _draw_pack_art(r: Rect2, id: String) -> void:
	var p: Dictionary = D.PACKS[id]
	var col := Color(p["color"])
	_panel(Rect2(r.position + Vector2(0, 6), r.size), Color(0, 0, 0, 0.35), 6)
	_grad_panel(r, 4.0, col.lightened(0.18), col.darkened(0.25))
	draw_rect(Rect2(r.position, Vector2(r.size.x, 12.0)), col.darkened(0.35))
	draw_rect(Rect2(r.position.x, r.end.y - 12.0, r.size.x, 12.0), col.darkened(0.35))
	_disc(Vector2(r.get_center().x, r.position.y + 104.0), 40.0)
	var pname := String(p["name"]).to_upper()
	_heavy_center(Rect2(r.position.x, r.position.y + 18.0, r.size.x, 40.0), pname, _fit(pname, r.size.x - 20.0, T_MD), Color(p["trim"]))
	_text_center(Rect2(r.position.x, r.end.y - 56.0, r.size.x, 30.0), "%d DISCS + CASH" % int(p["discs"]), T_XS, Color.WHITE, true)

func _pack_tip(id: String) -> String:
	var p: Dictionary = D.PACKS[id]
	var w: Array = p["rarity"]
	return "%s: %d discs (%d%% common, %d%% uncommon, %d%% rare) plus $%d–%d cash.\nKeep what fits on this sheet; the rest sell automatically." % [p["name"], int(p["discs"]), int(w[0]), int(w[1]), int(w[2]), int(p["cash"][0]), int(p["cash"][1])]

func _draw_shop() -> void:
	var x := r_left.position.x
	var w := r_left.size.x
	var y := r_left.position.y - 8.0
	_section(x, y, w - 190.0, "NEW ARRIVALS")
	_ghost(Rect2(x + w - 170.0, y - 6.0, 170.0, 44.0), "Reroll $%d" % reroll_cost, _reroll, cash >= reroll_cost, c_light)
	y += 48.0
	var cw := 230.0
	var ch := cw * CASE_RATIO
	var gx := (w - 3.0 * cw) / 2.0
	var open := _open_slots().size()
	for i in shop_discs.size():
		var r := Rect2(x + (i % 3) * (cw + gx), y + (i / 3) * (ch + 80.0), cw, ch)
		var o := shop_discs[i]
		if bool(o["sold"]):
			_panel(r, Color(0, 0, 0, 0.2), 14, Color(1, 1, 1, 0.08), 2)
			_heavy_center(r, "SOLD", T_LG, Color(1, 1, 1, 0.2))
			continue
		var d: Disc = o["disc"]
		var price := int(o["price"])
		_draw_case(r, d, price)
		_tip(r, _disc_tip(d))
		_brass_button(Rect2(r.position.x, r.end.y + 12.0, cw, 48.0), "Buy", _buy_disc.bind(i), cash >= price and open > 0)
	var info := Rect2(x + 2.0 * (cw + gx), y + ch + 80.0, cw, ch)
	_panel(info, Color(0, 0, 0, 0.18), 14)
	_wrap(info.position + Vector2(16, 16), "Open slots: %d\n\nDiscs you buy go straight onto this sheet. Click a disc on the sheet, then another slot, to move it." % open, cw - 32.0, T_XS, c_light_muted, true)
	y += 2.0 * (ch + 80.0) + 10.0
	_section(x, y, w, "BUNDLES & SLEEVES")
	y += 48.0
	var tw := (w - 3.0 * GAP) / 4.0
	var th := 200.0
	for i in shop_packs.size():
		var r := Rect2(x + i * (tw + GAP), y, tw, th)
		var o := shop_packs[i]
		if bool(o["sold"]):
			_panel(r, Color(0, 0, 0, 0.2), 8)
			_heavy_center(r, "SOLD", T_LG, Color(1, 1, 1, 0.2))
			continue
		_draw_pack_art(r, String(o["id"]))
		_tip(r, _pack_tip(String(o["id"])))
		var price := int(D.PACKS[o["id"]]["price"])
		_brass_button(Rect2(r.position.x, r.end.y + 12.0, tw, 48.0), "Buy  $%d" % price, _buy_pack.bind(i), cash >= price)
	for i in shop_sleeves.size():
		var r := Rect2(x + (i + 2) * (tw + GAP), y, tw, th)
		var o := shop_sleeves[i]
		var s: Dictionary = D.SLEEVES[o["id"]]
		_panel(Rect2(r.position + Vector2(0, 5), r.size), Color(0, 0, 0, 0.3), 14)
		_panel(r, Color("f4efe4"), 14)
		_panel(Rect2(r.position, Vector2(r.size.x, 12.0)), Color(s["color"]), 6)
		_heavy(r.position + Vector2(14, 50), String(s["name"]), _fit(String(s["name"]), r.size.x - 28.0, T_MD), c_ink)
		_wrap(r.position + Vector2(14, 64), String(s["text"]) + " This sheet only.", r.size.x - 28.0, T_XS, c_body, true, 5)
		if bool(o["sold"]):
			_heavy_center(Rect2(r.position.x, r.end.y + 12.0, tw, 48.0), "SOLD", T_MD, Color(1, 1, 1, 0.3))
		else:
			var price := int(s["price"])
			_brass_button(Rect2(r.position.x, r.end.y + 12.0, tw, 48.0), "Sleeve  $%d" % price, _start_sleeve.bind(i), cash >= price)

func _draw_offer_grid(area: Rect2, interactive: bool) -> void:
	var cw := 183.0
	var ch := cw * CASE_RATIO
	var gx := (area.size.x - 4.0 * cw) / 3.0
	var offers: Array = trader["offers"]
	for i in offers.size():
		var o: Dictionary = offers[i]
		var r := Rect2(area.position.x + (i % 4) * (cw + gx), area.position.y + (i / 4) * (ch + 96.0), cw, ch)
		if bool(o["done"]):
			_panel(r, Color(0, 0, 0, 0.2), 14, Color(1, 1, 1, 0.08), 2)
			_heavy_center(r, "TRADED", T_LG, Color(1, 1, 1, 0.25))
			continue
		var d: Disc = o["disc"]
		_draw_case(r, d)
		_tip(r, _disc_tip(d))
		if mode == "pay" and mode_i == i:
			_panel(r.grow(5.0), Color(0, 0, 0, 0), 16, Color("7fe0a0"), 5)
		var br := Rect2(r.position.x, r.end.y + 10.0, cw, 64.0)
		if interactive:
			_brass_button(br, "Trade", _start_trade.bind(i), true, _cost_text(o["cost"]))
		else:
			_panel(br, Color(0, 0, 0, 0.25), 12)
			_wrap(br.position + Vector2(10, 8), "Costs " + _cost_text(o["cost"]), cw - 20.0, T_XS, c_light, true, 2)

func _likes_text() -> String:
	var parts: Array[String] = []
	for c in trader["likes"]:
		parts.append(_cond_text(c).trim_prefix("1 "))
	return " and ".join(parts)

func _draw_trader() -> void:
	var x := r_left.position.x
	var y := r_left.position.y
	_heavy(Vector2(x, y + 30.0), String(trader["name"]), T_XL, c_light)
	_text(Vector2(x, y + 66.0), "Wants: %s albums. Pay with discs from any sheet." % _likes_text(), T_SM, c_light_muted, true)
	_draw_offer_grid(Rect2(x, y + 100.0, r_left.size.x, r_left.size.y - 100.0), phase == Phase.TRADER)

func _close_preview() -> void:
	show_trader = false

func _open_preview() -> void:
	show_trader = true

func _judge_card(r: Rect2, j: Dictionary, k: int) -> void:
	_panel(Rect2(r.position + Vector2(0, 6), r.size), Color(0, 0, 0, 0.35), 18)
	_panel(r, C_BOARD, 18, Color("0d1f16"), 4)
	var x := r.position.x
	var w := r.size.x
	_text_center(Rect2(x, r.position.y + 14.0, w, 36.0), "JUDGE %d OF %d" % [k + 1, D.ROUNDS], T_SM, Color("cfe3d4"), true)
	var c := Vector2(r.get_center().x, r.position.y + 120.0)
	var hue := float(absi(String(j["name"]).hash()) % 360) / 360.0
	draw_circle(c, 58.0, Color.from_hsv(hue, 0.35, 0.85))
	draw_arc(c, 58.0, 0, TAU, 40, Color.WHITE, 4.0, true)
	var words := String(j["name"]).split(" ")
	_heavy_center(Rect2(c - Vector2(58, 58), Vector2(116, 116)), words[1].left(1) + words[2].left(1), T_HERO, Color.WHITE)
	var jn := String(j["name"])
	_heavy_center(Rect2(x, r.position.y + 190.0, w, 56.0), jn, _fit(jn, w - 40.0, T_XL), c_light)
	var bw := (w - 48.0 - 56.0) * 0.5
	for side in 2:
		var cat := String(j["a"] if side == 0 else j["b"])
		var br := Rect2(x + 24.0 + side * (bw + 56.0), r.position.y + 262.0, bw, 70.0)
		_panel(br, C_VALUE if side == 0 else C_MULT, 14, Color(1, 1, 1, 0.2), 2)
		_heavy_center(br, String(D.CAT[cat]["name"]), _fit(String(D.CAT[cat]["name"]), bw - 16.0, T_LG), Color.WHITE)
	_heavy_center(Rect2(x + 24.0 + bw, r.position.y + 262.0, 56.0, 70.0), "×", T_XL, c_light)
	_text(Vector2(x + 28.0, r.position.y + 386.0), "TARGET", T_SM, Color("9fbfa9"), true)
	_heavy_right(x + w - 28.0, r.position.y + 392.0, _fmt(int(j["target"])), T_XL, c_gold)

func _relevant(d: Disc, j: Dictionary) -> bool:
	var a := d.ability
	if a.is_empty() or String(a["when"]) != "activated":
		return false
	var k := String(a["kind"])
	return k.begins_with("retrigger") or k == "cash" or a["cat"] == j["a"] or a["cat"] == j["b"]

func _draw_preview() -> void:
	var r := _modal(2200.0, 1120.0)
	var j := judges[round_n - 1]
	_heavy_center(Rect2(r.position.x, r.position.y + 20.0, r.size.x, 60.0), "Round %d preview" % round_n, T_XL, c_ink)
	_judge_card(Rect2(r.position.x + 60.0, r.position.y + 110.0, 520.0, 430.0), j, round_n - 1)
	var y := r.position.y + 580.0
	_text(Vector2(r.position.x + 60.0, y), "On your current sheet, these discs feed this judge:", T_SM, c_body, true)
	y += 34.0
	var n := 0
	for d in _cur():
		if d != null and _relevant(d, j):
			_text(Vector2(r.position.x + 60.0, y), "• %s" % d.title, T_SM, c_ink, true)
			y += 30.0
			n += 1
	if n == 0:
		_text(Vector2(r.position.x + 60.0, y), "None yet.", T_SM, c_muted, true)
	if round_n < judges.size():
		_text(Vector2(r.position.x + 60.0, r.end.y - 120.0), "Next round: %s (%s × %s)" % [judges[round_n]["name"], D.CAT[judges[round_n]["a"]]["name"], D.CAT[judges[round_n]["b"]]["name"]], T_SM, c_muted, true)
	var tx := r.position.x + 660.0
	_heavy(Vector2(tx, r.position.y + 150.0), String(trader["name"]), T_XL, c_ink)
	_text(Vector2(tx, r.position.y + 186.0), "Trader · wants %s albums" % _likes_text(), T_MD, c_muted, true)
	var c_save := c_light
	c_light = c_ink
	_draw_offer_grid(Rect2(tx, r.position.y + 220.0, r.end.x - tx - 60.0, 760.0), false)
	c_light = c_save
	_ghost(Rect2(r.get_center().x - 120.0, r.end.y - 84.0, 240.0, 60.0), "Close", _close_preview, true, c_ink)

func _draw_judge_panel() -> void:
	var j := judges[round_n - 1]
	_judge_card(Rect2(r_left.position.x, r_left.position.y, r_left.size.x, 430.0), j, round_n - 1)
	var x := r_left.position.x
	var y := r_left.position.y + 480.0
	_wrap(Vector2(x, y), "When you click Judge, each disc on this sheet activates in order, slot 1 to 9. Abilities that build %s and %s count; everything else is wasted. Each category counts as at least 1." % [D.CAT[j["a"]]["name"], D.CAT[j["b"]]["name"]], r_left.size.x, T_SM, c_light_muted, true)
	y += 130.0
	_foil(Vector2(x, y), "FEEDING THIS JUDGE", T_SM)
	y += 20.0
	for d in _cur():
		if d != null and _relevant(d, j):
			_wrap(Vector2(x, y), "%s — %s" % [d.title, _ability_text(d.ability)], r_left.size.x, T_XS, c_light, true, 2)
			y += 50.0

func _draw_counter() -> void:
	var x := r_right.position.x
	var w := r_right.size.x
	var y := r_right.position.y
	var card := Rect2(x, y, w, 200.0)
	_panel(Rect2(card.position + Vector2(0, 6), card.size), Color(0, 0, 0, 0.35), 18)
	_panel(card, C_BOARD, 18, Color("0d1f16"), 4)
	_text(Vector2(x + 28.0, y + 48.0), "WALLET", T_SM, Color("9fbfa9"), true)
	_heavy(Vector2(x + 28.0, y + 150.0), "$%d" % cash, 100, c_gold)
	y = card.end.y + 30.0
	var j := judges[round_n - 1]
	_text(Vector2(x, y + 20.0), "THIS ROUND'S JUDGE", T_XS, c_light_muted, true)
	_heavy(Vector2(x, y + 60.0), String(j["name"]), _fit(String(j["name"]), w, T_LG), c_light)
	_text(Vector2(x, y + 92.0), "%s × %s  ·  target %d" % [D.CAT[j["a"]]["name"], D.CAT[j["b"]]["name"], int(j["target"])], T_SM, c_light, true)
	y += 130.0
	if mode == "pay":
		var o: Dictionary = trader["offers"][mode_i]
		_wrap(Vector2(x, y), "Trading for %s. Still need: %s. Click matching discs on any sheet (use < > to flip sheets)." % [o["disc"].title, _cost_text(_unmet())], w, T_SM, c_light, true)
		y += 120.0
		_ghost(Rect2(x, y, w, 56.0), "Cancel trade", _cancel, true, c_light)
		y += 80.0
	elif mode == "sleeve":
		_wrap(Vector2(x, y), "Click a slot on this sheet for the %s sleeve." % D.SLEEVES[shop_sleeves[mode_i]["id"]]["name"], w, T_SM, c_light, true)
		y += 70.0
		_ghost(Rect2(x, y, w, 56.0), "Cancel", _cancel, true, c_light)
		y += 80.0
	elif sel.x >= 0:
		var d: Disc = sheets[sel.x][sel.y]
		if d != null:
			_heavy(Vector2(x, y + 30.0), d.title, _fit(d.title, w, T_LG), c_light)
			var hint := "Click another slot to move it." if sel.x == sheets.size() - 1 else "Locked sheet: sell or trade only. Selling leaves a hole."
			_wrap(Vector2(x, y + 44.0), hint, w, T_XS, c_light_muted, true)
			_brass_button(Rect2(x, y + 92.0, w, 60.0), "Sell for $%d" % _sell_price(d), _sell_selected, true)
			y += 180.0
	else:
		_wrap(Vector2(x, y), "Click a disc to move or sell it. Hover any disc to read it.", w, T_SM, c_light_muted, true)
		y += 70.0
	if message_t > 0.0:
		_wrap(Vector2(x, y), message, w, T_SM, Color("ff9a86"), true)
	_ghost(Rect2(x, r_right.end.y - 200.0, w, 60.0), "Preview judge & trader", _open_preview, true, c_light)
	if phase == Phase.SHOP:
		_brass_button(Rect2(x, r_right.end.y - 120.0, w, 110.0), "Go to the trader", _go_trader, true, "No coming back to the store this round", T_LG)
	else:
		_brass_button(Rect2(x, r_right.end.y - 120.0, w, 110.0), "Go to the judge", _go_judge, mode == "", "No more trading this round", T_LG)

func _draw_scoreboard() -> void:
	var x := r_right.position.x
	var w := r_right.size.x
	var y := r_right.position.y
	var j := judges[round_n - 1]
	var board := Rect2(x, y, w, 470.0)
	_panel(Rect2(board.position + Vector2(0, 6), board.size), Color(0, 0, 0, 0.35), 18)
	_panel(board, C_BOARD, 18, Color("0d1f16"), 4)
	_text_center(Rect2(x, y + 14.0, w, 36.0), "SCORE", T_SM, Color("cfe3d4"), true)
	var bw := (w - 48.0 - 56.0) * 0.5
	var vals := [maxi(1, int(shown.get(j["a"], 0))), maxi(1, int(shown.get(j["b"], 0)))]
	for side in 2:
		var cat := String(j["a"] if side == 0 else j["b"])
		var br := Rect2(x + 24.0 + side * (bw + 56.0), y + 60.0, bw, 160.0)
		_panel(br, C_VALUE if side == 0 else C_MULT, 14, Color(1, 1, 1, 0.2), 2)
		_text_center(Rect2(br.position.x, br.position.y + 10.0, br.size.x, 30.0), String(D.CAT[cat]["name"]).to_upper(), T_SM, Color(1, 1, 1, 0.85), true)
		var v := str(vals[side]) if not shown.is_empty() else "?"
		_heavy_center(Rect2(br.position.x, br.position.y + 50.0, br.size.x, 100.0), v, _fit(v, bw - 20.0, T_HERO), Color.WHITE)
	_heavy_center(Rect2(x + 24.0 + bw, y + 60.0, 56.0, 160.0), "×", T_XL, c_light)
	var total: int = vals[0] * vals[1]
	var target := int(j["target"])
	_text(Vector2(x + 28.0, y + 290.0), "TOTAL", T_SM, Color("9fbfa9"), true)
	_heavy_right(x + w - 28.0, y + 298.0, "%s / %s" % [_fmt(total) if not shown.is_empty() else "?", _fmt(target)], T_XL, Color("7fe0a0") if total >= target and not shown.is_empty() else c_gold)
	var bar := Rect2(x + 28.0, y + 326.0, w - 56.0, 22.0)
	_panel(bar, Color(0, 0, 0, 0.35), 11)
	var ratio := clampf(float(total) / maxf(1.0, target), 0.0, 1.0) if not shown.is_empty() else 0.0
	if ratio > 0.0:
		_panel(Rect2(bar.position, Vector2(maxf(22.0, bar.size.x * ratio), bar.size.y)), Color("7fe0a0") if ratio >= 1.0 else c_gold, 11)
	_text(Vector2(x + 28.0, y + 400.0), "Cash from discs: +$%d" % shown_cash, T_SM, Color("9fbfa9"), true)
	y = board.end.y + 30.0
	_foil(Vector2(x, y + 20.0), "OTHER CATEGORIES", T_SM)
	y += 44.0
	for cat in D.CATEGORIES:
		if cat == j["a"] or cat == j["b"]:
			continue
		_text(Vector2(x, y + 20.0), String(D.CAT[cat]["name"]), T_SM, c_light_muted, true)
		_text_right(x + w, y + 20.0, str(int(shown.get(cat, 0))), T_SM, c_light_muted, true)
		y += 34.0
	_brass_button(Rect2(x, r_right.end.y - 120.0, w, 110.0), "Judging..." if judging else "Judge!", _start_judging, phase == Phase.JUDGE and not judging, "Activate every disc, slot 1 to 9", T_LG)

func _draw_pack() -> void:
	var n := pack_items.size()
	var cw := minf(CARD_W, (2000.0 - (n - 1) * 24.0) / n)
	var ch := cw * CASE_RATIO
	var total_w := n * cw + (n - 1) * 24.0
	var r := _modal(maxf(1100.0, total_w + 140.0), ch + 380.0)
	var open := _open_slots().size()
	_heavy_center(Rect2(r.position.x, r.position.y + 26.0, r.size.x, 60.0), pack_title, T_XL, c_ink)
	_text_center(Rect2(r.position.x, r.position.y + 84.0, r.size.x, 30.0), "Click to keep or sell. Keeping %d of %d open slots. Bonus cash: +$%d" % [_kept(), open, pack_cash], T_MD, c_bad if _kept() > open else c_muted, true)
	var x := r.position.x + (r.size.x - total_w) * 0.5
	for i in n:
		var cr := Rect2(x + i * (cw + 24.0), r.position.y + 140.0, cw, ch)
		var d := pack_items[i]
		_draw_case(cr, d)
		_tip(cr, _disc_tip(d))
		var tag := Rect2(cr.position.x, cr.end.y + 12.0, cw, 44.0)
		if pack_keep[i]:
			_panel(cr.grow(5.0), Color(0, 0, 0, 0), 16, c_good, 5)
			_panel(tag, c_good, 12)
			_text_center(tag, "KEEP", T_MD, Color.WHITE, true)
		else:
			_panel(cr, Color(0, 0, 0, 0.35), 10)
			_panel(tag, Color("b28a3a"), 12)
			_text_center(tag, "SELL $%d" % _sell_price(d), T_MD, Color.WHITE, true)
		_register(cr, _toggle_keep.bind(i))
		_register(tag, _toggle_keep.bind(i))
	_brass_button(Rect2(r.get_center().x - 170.0, r.end.y - 104.0, 340.0, 76.0), "Done", _close_pack, _kept() <= open, "", T_LG)

func _draw_result() -> void:
	var r := _modal(900.0, 640.0)
	var j := judges[round_n - 1]
	var hit := bool(result["hit"])
	var x := r.position.x + 70.0
	var w := r.size.x - 140.0
	_heavy_center(Rect2(r.position.x, r.position.y + 30.0, r.size.x, 60.0), String(j["name"]), T_XL, c_ink)
	_text_center(Rect2(r.position.x, r.position.y + 92.0, r.size.x, 40.0), "Impressed!" if hit else "Not impressed.", T_LG, c_good if hit else c_bad, true)
	var y := r.position.y + 190.0
	_row(x, w, y, String(D.CAT[j["a"]]["name"]), str(result["a"]))
	y += 46.0
	_row(x, w, y, String(D.CAT[j["b"]]["name"]), "× %d" % int(result["b"]))
	y += 46.0
	_row(x, w, y, "Score", _fmt(int(result["total"])), c_good if hit else c_bad)
	y += 46.0
	_row(x, w, y, "Target", _fmt(int(result["target"])))
	y += 30.0
	draw_line(Vector2(x, y), Vector2(x + w, y), c_line, 2.0)
	y += 50.0
	_row(x, w, y, "Disc cash", "+$%d" % int(result["cash"]))
	y += 46.0
	_row(x, w, y, "Clear reward", "+$%d" % int(result["reward"]), Color("b28a3a"))
	var label := "Start a new sheet"
	if not hit:
		label = "Run over"
	elif round_n >= D.ROUNDS:
		label = "Finish"
	_brass_button(Rect2(r.get_center().x - 200.0, r.end.y - 110.0, 400.0, 76.0), label, _result_next, true, "", T_LG)

func _draw_end(title: String, sub: String, col: Color) -> void:
	var r := _modal(900.0, 420.0)
	_heavy_center(Rect2(r.position.x, r.position.y + 50.0, r.size.x, 70.0), title, T_HERO, col)
	_text_center(Rect2(r.position.x, r.position.y + 150.0, r.size.x, 40.0), sub, T_LG, c_body, true)
	_brass_button(Rect2(r.get_center().x - 180.0, r.end.y - 120.0, 360.0, 80.0), "New run", _new_run, true, "", T_LG)
