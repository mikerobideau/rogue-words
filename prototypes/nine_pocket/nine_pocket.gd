extends "res://prototypes/nine_pocket/nine_pocket_ui.gd"

const D := preload("res://prototypes/nine_pocket/nine_pocket_data.gd")

enum Phase { SHOP, WORKSHOP, JUDGE, RESULT, GAMEOVER, WIN }

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
	var edition := ""

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
var orders: Array[Dictionary] = []
var sel := Vector2i(-1, -1)
var mode := ""
var mode_i := -1
var pack_items: Array[Disc] = []
var pack_keep: Array[bool] = []
var pack_cash := 0
var pack_title := ""
var preview := ""
var sort_key := ""
var preview_j := 0
var phase_t := 0.0
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
	phase_t += delta
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
		preview = ""
		_cancel()

func _cancel() -> void:
	sel = Vector2i(-1, -1)
	mode = ""

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
	judges.clear()
	var names := {}
	while judges.size() < D.ROUNDS:
		var j := _make_judge()
		if names.has(j["name"]):
			continue
		names[j["name"]] = true
		judges.append(j)
	_calibrate()
	cash = D.START_CASH
	round_n = 1
	sheets.clear()
	var sheet: Array = []
	sheet.resize(9)
	sheets.append(sheet)
	view = 0
	result = {}
	pack_items.clear()
	pack_queue.clear()
	preview = ""
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
				sheet.append(_make_disc())
			totals.append(_total(_score(sheet, blank, j)))
		totals.sort()
		j["target"] = maxi(D.MIN_TARGET, int(round(float(totals[totals.size() / 2]) * D.ROUND_FACTOR[k])))

func _begin_round() -> void:
	view = 0
	sleeves.resize(9)
	sleeves.fill("")
	_cancel()
	reroll_cost = D.REROLL_BASE
	_roll_shop_discs()
	shop_packs.clear()
	var keys: Array = D.PACKS.keys()
	var pk: Array = keys.duplicate()
	while pk.size() < D.SHOP_PACKS:
		pk.append(keys[rng.randi_range(0, keys.size() - 1)])
	pk.sort_custom(func(x, y): return int(D.PACKS[x]["price"]) < int(D.PACKS[y]["price"]))
	for id in pk:
		shop_packs.append({"id": id, "sold": false})
	shop_sleeves.clear()
	var sk: Array = D.SLEEVES.keys()
	_shuffle(sk)
	for i in mini(D.SHOP_SLEEVES, sk.size()):
		shop_sleeves.append({"id": sk[i], "sold": false})
	_make_orders()
	slot_flash.fill(0.0)
	phase = Phase.SHOP
	phase_t = 0.0

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
	var mult := rng.randf() < 0.35
	var big := 2 if r == 2 else 1
	var a := {"kind": kind, "when": String(D.ABILITY_WHEN.get(kind, "activated")), "gain": "mult" if mult else "sound", "n": 0}
	var attr: String = D.MATCH_ATTRS[rng.randi_range(0, D.MATCH_ATTRS.size() - 1)]
	match kind:
		"flat":
			a["n"] = (1 + r) if mult else (3 + 3 * r)
		"row_match", "col_match":
			a["attr"] = attr
			a["n"] = big if mult else (3 + 2 * r)
		"nbr_match", "diag_match":
			a["attr"] = attr
			a["n"] = 1 if mult else (2 + r)
		"nbr_filter":
			a["f"] = _rand_cond()
			a["n"] = 1 if mult else (2 + r)
		"slot":
			a["slot"] = ["corner", "center", "edge"][rng.randi_range(0, 2)]
			var c: bool = a["slot"] == "center"
			a["n"] = ((3 if c else 1) + r) if mult else ((10 if c else 5) + 2 * r)
		"era_step", "row_distinct":
			a["n"] = 1 if mult else (3 + r)
		"line_all":
			a["attr"] = attr
			a["line"] = "row" if rng.randf() < 0.5 else "column"
			if r == 2 and rng.randf() < 0.5:
				a["gain"] = "xmult"
				a["n"] = 2
			else:
				a["gain"] = "mult"
				a["n"] = 3 + 2 * r
		"x_nbrs":
			a["attr"] = attr
			a["gain"] = "xmult"
			a["n"] = 2
		"boost_row", "boost_col":
			a["n"] = big if mult else (2 + r)
		"runtime":
			a["gain"] = "sound"
			a["n"] = 1
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
	var g := _gain_text(a)
	var n := int(a["n"])
	var at := String(D.ATTR_TEXT.get(String(a.get("attr", "")), ""))
	var t := ""
	match String(a["kind"]):
		"flat":
			t = "%s." % g
		"row_match":
			t = "%s per other disc in its row with the same %s." % [g, at]
		"col_match":
			t = "%s per other disc in its column with the same %s." % [g, at]
		"nbr_match":
			t = "%s per neighbor with the same %s." % [g, at]
		"diag_match":
			t = "%s per diagonal neighbor with the same %s." % [g, at]
		"nbr_filter":
			t = "%s per neighboring %s album." % [g, _filter_text(a["f"])]
		"slot":
			t = "%s if in %s." % [g, {"corner": "a corner", "center": "the center", "edge": "an edge slot"}[a["slot"]]]
		"era_step":
			t = "%s per neighbor one decade apart." % g
		"row_distinct":
			t = "%s per different genre in its row." % g
		"line_all":
			t = "%s if its whole %s shares its %s." % [g, a["line"], at]
		"x_nbrs":
			t = "%s if all its neighbors (at least 2) share its %s." % [g, at]
		"boost_row":
			t = "Other discs in its row get %s when they activate." % g
		"boost_col":
			t = "Other discs in its column get %s when they activate." % g
		"retrigger_left":
			t = "Retrigger the disc to its left."
		"retrigger_above":
			t = "Retrigger the disc above it."
		"retrigger_nbrs":
			t = "Retrigger all neighboring discs."
		"runtime":
			t = "+%d Sound per %d min of its runtime." % [n, D.RUNTIME_STEP]
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
	return D.SELL_BASE[d.rarity] + d.cond + (D.EDITION_SELL if d.edition != "" else 0)

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

func _score(sheet: Array, sl: Array, j: Dictionary) -> Dictionary:
	var ctx := {"sound": 0, "mult": 1, "cash": 0, "steps": [], "sheet": sheet, "sl": sl, "j": j}
	for i in 9:
		if sheet[i] != null:
			_activate(ctx, i, false)
	return ctx

func _push(ctx: Dictionary, slot: int, kind: String, n: int) -> void:
	if n == 0 and kind != "again":
		return
	match kind:
		"sound":
			ctx["sound"] += n
		"mult":
			ctx["mult"] += n
		"xmult":
			ctx["mult"] *= n
		"cash":
			ctx["cash"] += n
	ctx["steps"].append({"slot": slot, "kind": kind, "n": n, "sound": ctx["sound"], "mult": ctx["mult"], "cash": ctx["cash"]})

func _activate(ctx: Dictionary, i: int, again: bool) -> void:
	var s := _sl(ctx["sl"], i)
	var times := 2 if s == "echo" and not again else 1
	for t in times:
		if again or t > 0:
			_push(ctx, i, "again", 0)
		_fire(ctx, i, again)
		if s == "gold":
			_push(ctx, i, "cash", 2)

func _fire(ctx: Dictionary, i: int, again: bool) -> void:
	var sheet: Array = ctx["sheet"]
	var sl: Array = ctx["sl"]
	var d: Disc = sheet[i]
	var s := _sl(sl, i)
	_push(ctx, i, "sound", D.BASE_SOUND[_rar(d, s)])
	if d.edition != "":
		var ed: Dictionary = D.EDITIONS[d.edition]
		_push(ctx, i, String(ed["kind"]), int(ed["n"]))
	var j: Dictionary = ctx["j"]
	for gk in ["sound", "mult"]:
		var r: Dictionary = j[gk]
		_push(ctx, i, gk, int(r["n"]) * _rule_hits(sheet, sl, i, r))
	for k in 9:
		var e: Disc = sheet[k]
		if k == i or e == null or e.ability.is_empty():
			continue
		var b := e.ability
		if (b["kind"] == "boost_row" and k / 3 == i / 3) or (b["kind"] == "boost_col" and k % 3 == i % 3):
			_push(ctx, i, String(b["gain"]), int(b["n"]) + (D.AMP_BONUS if _sl(sl, k) == "amp" else 0))
	var a := d.ability
	if a.is_empty() or String(a["when"]) != "activated":
		return
	var g := String(a.get("gain", "sound"))
	var n := int(a["n"]) + (D.AMP_BONUS if s == "amp" and g != "xmult" else 0)
	var attr := String(a.get("attr", ""))
	var kind := String(a["kind"])
	match kind:
		"flat":
			_push(ctx, i, g, n)
		"row_match", "col_match", "nbr_match", "diag_match":
			var slots: Array[int] = _diags(i)
			if kind == "row_match":
				slots = _scope_slots(i, "row")
			elif kind == "col_match":
				slots = _scope_slots(i, "column")
			elif kind == "nbr_match":
				slots = _nbrs(i)
			var m := 0
			for k in slots:
				if k != i and sheet[k] != null and _same(sheet, sl, i, k, attr):
					m += 1
			_push(ctx, i, g, n * m)
		"nbr_filter":
			var m := 0
			for k in _nbrs(i):
				if sheet[k] != null and _meets_s(sheet[k], _sl(sl, k), a["f"]):
					m += 1
			_push(ctx, i, g, n * m)
		"slot":
			if _slot_is(i, String(a["slot"])):
				_push(ctx, i, g, n)
		"era_step":
			var m := 0
			for k in _nbrs(i):
				if sheet[k] != null and absi(sheet[k].era - d.era) == 1:
					m += 1
			_push(ctx, i, g, n * m)
		"row_distinct":
			var seen := {}
			for k in _scope_slots(i, "row"):
				if sheet[k] != null:
					seen[-1 - k if _sl(sl, k) == "wild" else sheet[k].genre] = true
			_push(ctx, i, g, n * seen.size())
		"line_all":
			var ok := true
			for k in _scope_slots(i, "row" if a["line"] == "row" else "column"):
				if sheet[k] == null or not _same(sheet, sl, i, k, attr):
					ok = false
			if ok:
				_push(ctx, i, g, n)
		"x_nbrs":
			var cnt := 0
			var ok := true
			for k in _nbrs(i):
				if sheet[k] == null:
					continue
				cnt += 1
				if not _same(sheet, sl, i, k, attr):
					ok = false
			if ok and cnt >= 2:
				_push(ctx, i, g, n)
		"retrigger_left":
			if not again and i % 3 > 0 and sheet[i - 1] != null:
				_activate(ctx, i - 1, true)
		"retrigger_above":
			if not again and i >= 3 and sheet[i - 3] != null:
				_activate(ctx, i - 3, true)
		"retrigger_nbrs":
			if not again:
				for k in _nbrs(i):
					if sheet[k] != null:
						_activate(ctx, k, true)
		"runtime":
			_push(ctx, i, "sound", n * (d.runtime / D.RUNTIME_STEP))
		"cash":
			_push(ctx, i, "cash", n)

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
		"job":
			if d != null:
				_apply_job(slot)
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

func _go_judge() -> void:
	_cancel()
	view = sheets.size() - 1
	phase = Phase.JUDGE
	phase_t = 0.0
	shown = {}
	shown_cash = 0

func _start_judging() -> void:
	if judging or phase != Phase.JUDGE:
		return
	_cancel()
	pending = _score(_cur(), sleeves, judges[round_n - 1])
	steps.assign(pending["steps"])
	shown = {}
	shown_cash = 0
	step_i = 0
	step_timer = 0.4
	judging = true

func _play_step(st: Dictionary) -> void:
	shown = {"sound": int(st["sound"]), "mult": int(st["mult"])}
	shown_cash = int(st["cash"])
	var slot := int(st["slot"])
	slot_flash[slot] = 1.0
	var n := int(st["n"])
	var text := "Again!"
	var col := Color(0.8, 0.82, 0.86)
	match String(st["kind"]):
		"sound":
			text = "+%d Sound" % n
			col = Color(D.SOUND_COLOR).lightened(0.25)
		"mult":
			text = "+%d Mult" % n
			col = Color(D.MULT_COLOR).lightened(0.3)
		"xmult":
			text = "×%d Mult" % n
			col = Color(D.MULT_COLOR).lightened(0.3)
		"cash":
			text = "+$%d" % n
			col = c_gold
	_float(_cd_rect(slot), text, col)
	_sfx("mouseover")

func _finish_judging() -> void:
	judging = false
	var j := judges[round_n - 1]
	var a := maxi(1, int(pending["sound"]))
	var b := maxi(1, int(pending["mult"]))
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

func _slot_rect(i: int) -> Rect2:
	return Rect2(r_grid.position.x + (i % 3) * (CARD_W + GAP), r_grid.position.y + (i / 3) * (CARD_H + GAP), CARD_W, CARD_H)

func _disc_count() -> int:
	var n := 0
	for sh: Array in sheets:
		for x in sh:
			if x != null:
				n += 1
	return n

func _draw() -> void:
	_begin_draw()
	var modal := not pack_items.is_empty() or preview != "" or phase in [Phase.RESULT, Phase.GAMEOVER, Phase.WIN]
	ui_live = not modal and not judging
	match phase:
		Phase.SHOP:
			_draw_store()
		Phase.WORKSHOP:
			_draw_workshop()
		_:
			_draw_office()
	_draw_binder()
	_draw_wallet()
	_draw_flyers()
	_draw_next_button()
	_draw_toast()
	_draw_floaters()
	ui_live = true
	if not pack_items.is_empty():
		_draw_pack()
	elif preview == "judge":
		_draw_judge_preview()
	match phase:
		Phase.RESULT:
			_draw_result()
		Phase.GAMEOVER:
			_draw_end("The judge walked away", "Your binder lasted %d of %d judges." % [round_n - 1, D.ROUNDS], c_bad)
		Phase.WIN:
			_draw_end("Collection complete!", "All %d judges were impressed." % D.ROUNDS, c_good)
	_end_draw()

func _draw_wallet() -> void:
	var r := Rect2(40.0, 34.0, 470.0, 104.0)
	_shadow(r, 52, 5.0)
	_panel(r, Color(Color("173404"), 0.94), 52, Color("3b6d11"), 3)
	_heavy(Vector2(r.position.x + 34.0, r.position.y + 76.0), "$%d" % cash, T_HERO, c_gold)
	for k in D.ROUNDS:
		var c := Vector2(r.end.x - 42.0 - (D.ROUNDS - 1 - k) * 32.0, r.get_center().y)
		var col := Color("97c459") if k < round_n - 1 else (c_gold if k == round_n - 1 else Color(1, 1, 1, 0.18))
		draw_circle(c, 11.0 if k == round_n - 1 else 9.0, col)
	_tip(r, "Cash: $%d\nRound %d of %d" % [cash, round_n, D.ROUNDS])

func _judge_chips(j: Dictionary) -> Array:
	return [[_filter_text(j["sound"]["f"]), Color(D.SOUND_COLOR)], [_filter_text(j["mult"]["f"]), Color(D.MULT_COLOR)]]

func _flyer(r: Rect2, ang: float, head: String, title: String, chips: Array, tip: String, cb: Callable) -> void:
	var hovered := ui_live and r.has_point(mouse)
	_rotated(r.get_center() + Vector2(0, -6.0 if hovered else 0.0), ang)
	var lr := Rect2(-r.size * 0.5, r.size)
	_panel(Rect2(lr.position + Vector2(4, 8), lr.size), Color(0, 0, 0, 0.35), 6)
	_panel(lr, Color("f4efe4"), 6)
	draw_circle(Vector2(0, lr.position.y + 14.0), 9.0, Color("c0392b"))
	_text(Vector2(lr.position.x + 18.0, lr.position.y + 44.0), head, T_XS, c_muted, true)
	_heavy(Vector2(lr.position.x + 18.0, lr.position.y + 86.0), title, mini(T_MD, _fit(title, lr.size.x - 36.0, T_MD)), c_ink)
	var x := lr.position.x + 18.0
	for ch: Array in chips:
		var t := String(ch[0])
		var col: Color = ch[1]
		var w := _text_w(t, T_XS, true) + 20.0
		var cr := Rect2(x, lr.end.y - 48.0, w, 30.0)
		_panel(cr, col, 15)
		_text_center(cr, t, T_XS, _ink_on(col), true)
		x += w + 8.0
	_unrotated()
	_tip(r, tip)
	_register(r, cb)

func _draw_flyers() -> void:
	var right := Rect2(p_binder.end.x - 300.0, 30.0, 300.0, 160.0)
	var left := Rect2(right.position.x - 330.0, 30.0, 300.0, 160.0)
	if phase == Phase.SHOP or phase == Phase.WORKSHOP:
		var j := judges[round_n - 1]
		_flyer(left, -0.03, "TONIGHT'S JUDGE", String(j["name"]), _judge_chips(j), _judge_tip(j) + "\nClick for details.", _open_preview.bind("judge", round_n - 1))
	if round_n < judges.size():
		var nj := judges[round_n]
		_flyer(right, 0.025, "NEXT JUDGE", String(nj["name"]), _judge_chips(nj), "Round %d: %s\nClick for details." % [round_n + 1, _judge_tip(nj)], _open_preview.bind("judge", round_n))

func _draw_next_button() -> void:
	var r := Rect2(p_binder.position.x - 40.0 - 460.0, UI_H - 150.0, 460.0, 110.0)
	match phase:
		Phase.SHOP:
			_brass_button(r, "Leave shop", _go_workshop, true, "Head to the pressing plant", T_LG)
		Phase.WORKSHOP:
			_brass_button(r, "To the judge", _go_judge, true, "No more jobs this round", T_LG)

func _draw_toast() -> void:
	var t := ""
	if message_t > 0.0:
		t = message
	elif mode == "job":
		t = "%s: click a disc in your binder. Right-click to cancel." % _order_title(orders[mode_i])
	elif mode == "sleeve":
		t = "Click a pocket for the %s sleeve. Right-click to cancel." % D.SLEEVES[shop_sleeves[mode_i]["id"]]["name"]
	if t == "":
		return
	var maxw := p_binder.position.x - 40.0 - 460.0 - 30.0 - 60.0
	var fs := mini(T_SM, _fit(t, maxw - 50.0, T_SM))
	var r := Rect2(60.0, UI_H - 134.0, minf(maxw, _text_w(t, fs, true) + 50.0), 76.0)
	_panel(r, Color(0.06, 0.07, 0.09, 0.88), 38, Color(1, 1, 1, 0.12), 2)
	_text_center(r, t, fs, Color("ffd9a0") if message_t > 0.0 else c_light, true)

func _backdrop(wall: Color, floor_y: float, floor_col: Color) -> void:
	draw_rect(Rect2(-800, -800, UI_W + 1600, UI_H + 1600), wall)
	var x := -40.0
	while x < UI_W:
		draw_line(Vector2(x, 0), Vector2(x, floor_y), Color(0, 0, 0, 0.12), 3.0)
		x += 120.0
	draw_rect(Rect2(-800, floor_y, UI_W + 1600, UI_H - floor_y + 800), floor_col)
	draw_rect(Rect2(-800, floor_y, UI_W + 1600, 8), floor_col.lightened(0.15))

func _draw_store() -> void:
	_backdrop(Color("3d3833"), 1250.0, Color("2a2420"))
	var bin := Rect2(60.0, 270.0, 1132.0, 844.0)
	var sign := Rect2(bin.get_center().x - 380.0, 150.0, 760.0, 96.0)
	for sx: float in [sign.position.x + 90.0, sign.end.x - 90.0]:
		draw_line(Vector2(sx, -40.0), Vector2(sx, sign.position.y), Color("5f5e5a"), 4.0)
	_panel(sign, Color("1d1a17"), 12, c_gold, 3)
	_panel(sign.grow(-10.0), Color(c_gold, 0.08), 8)
	_heavy_center(sign, "NEW ARRIVALS", T_XL, c_gold)
	_shadow(bin, 12, 10.0)
	_panel(bin, Color("15171a"), 12)
	var discs: Array = []
	var prices: Array = []
	for o in shop_discs:
		discs.append(o["disc"])
		prices.append(int(o["price"]))
	var order := _sort_order(discs, prices)
	var j := judges[round_n - 1]
	for i in 12:
		var row := i / 4
		var col := i % 4
		var cell := Rect2(bin.position.x + 12.0 + col * 280.0, bin.position.y + 12.0 + row * 275.0, 268.0, 263.0 if row < 2 else 270.0)
		_panel(cell, Color("262a30"), 6)
		draw_rect(Rect2(cell.position, Vector2(cell.size.x, 18.0)), Color(0, 0, 0, 0.35))
		if row < 2:
			var lip := Rect2(cell.position.x - 4.0, cell.end.y - 66.0, cell.size.x + 8.0, 70.0)
			_panel(lip, Color("0e1012"), 4)
			var k := row * 4 + col
			if k < order.size():
				_store_disc(int(order[k]), cell, lip, j)
		else:
			_store_box(col, cell)
			_panel(Rect2(cell.position.x - 4.0, cell.end.y - 26.0, cell.size.x + 8.0, 30.0), Color("0e1012"), 4)
	var rt := Rect2(60.0, 1132.0, 270.0, 76.0)
	var ok := cash >= reroll_cost
	_panel(rt, Color("f4efe4") if ok else Color("8f8a80"), 8, Color("8a6a45"), 2)
	if ok and ui_live and rt.has_point(mouse):
		_panel(rt, Color(1, 1, 1, 0.25), 8)
	_text_center(rt, "Restock  $%d" % reroll_cost, T_MD, c_ink, true)
	_tip(rt, "Replace the 8 new arrivals. The price goes up by $1 each time.")
	if ok:
		_register(rt, _reroll)
	_draw_sort_bar(Rect2(350.0, 1132.0, bin.end.x - 350.0, 76.0), 6, "Price")
	_draw_sleeve_rack(Rect2(bin.end.x + 22.0, 300.0, r_scene.end.x - bin.end.x - 22.0, 640.0))

func _store_disc(i: int, cell: Rect2, lip: Rect2, j: Dictionary) -> void:
	var o := shop_discs[i]
	if bool(o["sold"]):
		_heavy_center(Rect2(cell.position, Vector2(cell.size.x, cell.size.y - 66.0)), "SOLD", T_LG, Color(1, 1, 1, 0.12))
		return
	var d: Disc = o["disc"]
	var price := int(o["price"])
	var lift := 10.0 if ui_live and cell.has_point(mouse) else 0.0
	var r := Rect2(cell.position.x + 29.0, cell.position.y + 10.0 - lift, 210.0, 185.0)
	_draw_case(r, d, price)
	if cash < price:
		_panel(r, Color(0, 0, 0, 0.45), 6)
	_chip_rows(lip.grow(-6.0), _disc_rows(d, "", j, 2), sort_key)
	_tip_disc(cell, d, "Click to buy for $%d" % price)
	_register(cell, _buy_disc.bind(i))

func _store_box(i: int, cell: Rect2) -> void:
	if i >= shop_packs.size():
		return
	var o := shop_packs[i]
	if bool(o["sold"]):
		_heavy_center(cell, "SOLD", T_LG, Color(1, 1, 1, 0.12))
		return
	var id := String(o["id"])
	var price := int(D.PACKS[id]["price"])
	var lift := 10.0 if ui_live and cell.has_point(mouse) else 0.0
	var r := Rect2(cell.position.x + 24.0, cell.end.y - 20.0 - 230.0 - lift, 220.0, 230.0)
	_draw_box_set(r, id, price)
	if cash < price:
		_panel(r, Color(0, 0, 0, 0.45), 6)
	_tip(cell, _pack_tip(id) + "\nClick to buy for $%d" % price)
	_register(cell, _buy_pack.bind(i))

func _draw_box_set(r: Rect2, id: String, price: int) -> void:
	var p: Dictionary = D.PACKS[id]
	var col := Color(p["color"])
	var trim := Color(p["trim"])
	_shadow(r, 6, 6.0)
	_grad_panel(r, 6.0, col.lightened(0.12), col.darkened(0.2))
	draw_rect(Rect2(r.position + Vector2(3, 3), Vector2(r.size.x - 6.0, 10.0)), col.lightened(0.3))
	_text(Vector2(r.position.x + 14.0, r.position.y + 44.0), "%d CDs + CASH" % int(p["discs"]), T_XS, Color(1, 1, 1, 0.85), true)
	var band := Rect2(r.position.x, r.position.y + 62.0, r.size.x, 62.0)
	draw_rect(band, trim)
	var nm := String(p["name"]).to_upper()
	_heavy_center(band, nm, mini(T_MD, _fit(nm, band.size.x - 20.0, T_MD)), col.darkened(0.3) if trim.get_luminance() > 0.5 else Color.WHITE)
	var n := int(p["discs"])
	var sw := (r.size.x - 40.0) / n
	for j in n:
		var sp := Rect2(r.position.x + 20.0 + j * sw + 4.0, band.end.y + 22.0, sw - 8.0, r.end.y - band.end.y - 40.0)
		_panel(sp, col.darkened(0.45), 3)
		draw_line(sp.position + Vector2(3, 3), Vector2(sp.end.x - 3.0, sp.position.y + 3.0), Color(1, 1, 1, 0.25), 2.0)
	draw_colored_polygon(PackedVector2Array([r.position + Vector2(r.size.x * 0.45, 0), r.position + Vector2(r.size.x * 0.7, 0), r.position + Vector2(r.size.x * 0.25, r.size.y), r.position + Vector2(0, r.size.y)]), Color(1, 1, 1, 0.1))
	_price_sticker(Vector2(r.end.x - 34.0, r.position.y + 26.0), "$%d" % price, 1.1)

func _draw_sleeve_rack(rack: Rect2) -> void:
	_panel(rack, Color("c9a77a"), 6, Color("8a6a45"), 3)
	var y := rack.position.y + 60.0
	while y < rack.end.y - 10.0:
		var x := rack.position.x + 18.0
		while x < rack.end.x - 10.0:
			draw_circle(Vector2(x, y), 3.0, Color("8a6a45"))
			x += 28.0
		y += 28.0
	_text_center(Rect2(rack.position.x, rack.position.y + 10.0, rack.size.x, 36.0), "SLEEVES", T_SM, Color("4a3520"), true)
	for i in shop_sleeves.size():
		var o := shop_sleeves[i]
		var hook := Vector2(rack.get_center().x, rack.position.y + 70.0 + i * 290.0)
		draw_line(hook, hook + Vector2(0, 24), Color("5f5e5a"), 4.0)
		if bool(o["sold"]):
			continue
		var s: Dictionary = D.SLEEVES[o["id"]]
		var price := int(s["price"])
		var pr := Rect2(hook.x - 66.0, hook.y + 18.0, 132.0, 240.0)
		if ui_live and pr.has_point(mouse):
			pr.position.y -= 8.0
		_draw_sleeve_pack(pr, s, mode == "sleeve" and mode_i == i)
		if cash < price:
			_panel(pr, Color(0, 0, 0, 0.45), 6)
		_tip(pr, "%s sleeve: %s This sheet only.\nClick to buy for $%d, then click a pocket." % [s["name"], s["text"], price])
		_register(pr, _start_sleeve.bind(i))

func _draw_sleeve_pack(r: Rect2, s: Dictionary, selected: bool) -> void:
	var col := Color(s["color"])
	_shadow(r, 6, 5.0)
	_panel(r, Color(col, 0.35), 6, Color(1, 1, 1, 0.5), 2)
	var head := Rect2(r.position, Vector2(r.size.x, 70.0))
	_panel(head, Color("f4efe4"), 6)
	draw_circle(Vector2(head.get_center().x, head.position.y + 14.0), 7.0, Color("8a6a45"))
	var nm := String(s["name"])
	_heavy_center(Rect2(head.position + Vector2(0, 24), Vector2(head.size.x, 44.0)), nm, mini(T_SM, _fit(nm, head.size.x - 16.0, T_SM)), c_ink)
	var inner := Rect2(r.position.x + 14.0, head.end.y + 14.0, r.size.x - 28.0, r.end.y - head.end.y - 28.0)
	_panel(inner, Color(col, 0.6), 4)
	draw_circle(inner.get_center(), 40.0, Color(1, 1, 1, 0.22))
	draw_circle(inner.get_center(), 8.0, Color(col, 0.6))
	_price_sticker(Vector2(r.end.x - 28.0, head.end.y + 26.0), "$%d" % int(s["price"]), 1.0)
	if selected:
		_panel(r.grow(5.0), Color(0, 0, 0, 0), 10, c_gold, 5)

func _draw_office() -> void:
	_backdrop(Color("161a24"), 1250.0, Color("0f1219"))
	var j := judges[round_n - 1]
	var cx := r_scene.get_center().x
	var sign := Rect2(cx - 400.0, 166.0, 800.0, 136.0)
	var on := 1.0
	if phase_t < 0.6 and fmod(phase_t * 11.0, 1.0) < 0.45:
		on = 0.25
	var neon := Color("ff6ad5")
	for g in 3:
		_panel(sign.grow(8.0 + g * 8.0), Color(0, 0, 0, 0), 30, Color(neon, 0.07 * on), 8)
	_panel(sign, Color(neon, 0.05 * on), 24, Color(neon, 0.9 * on), 5)
	var jn := String(j["name"])
	var fs := mini(T_HERO, _fit(jn, sign.size.x - 80.0, T_HERO))
	for off: Vector2 in [Vector2(-3, 0), Vector2(3, 0), Vector2(0, -3), Vector2(0, 3)]:
		_heavy_center(Rect2(sign.position + off, sign.size), jn, fs, Color(neon, 0.22 * on))
	_heavy_center(sign, jn, fs, Color(Color("ffd6f3"), maxf(0.35, on)))
	var sil := Color("07090d")
	draw_circle(Vector2(cx, 420.0), 70.0, sil)
	_panel(Rect2(cx - 150.0, 490.0, 300.0, 330.0), sil, 90)
	var top := 770.0
	var desk := Rect2(40.0, top, r_scene.end.x - 20.0, 22.0)
	draw_rect(desk, Color("6f4a2c"))
	draw_rect(Rect2(desk.position.x, top + 22.0, desk.size.x, 1250.0 - top - 22.0), Color("3a2618"))
	for k in 4:
		var px := desk.position.x + desk.size.x * (k + 0.5) / 4.0
		draw_line(Vector2(px, top + 40.0), Vector2(px, 1230.0), Color(0, 0, 0, 0.18), 3.0)
	for side in 2:
		var gk := "sound" if side == 0 else "mult"
		var col := Color(D.SOUND_COLOR if side == 0 else D.MULT_COLOR)
		var r := Rect2(cx - 330.0 + side * 400.0, top - 230.0, 260.0, 230.0)
		_shadow(r, 12, 6.0)
		_grad_panel(r, 12.0, col.lightened(0.15), col.darkened(0.1))
		_text_center(Rect2(r.position.x, r.position.y + 14.0, r.size.x, 34.0), "SOUND" if side == 0 else "MULT", T_SM, Color.WHITE, true)
		var v := "–" if shown.is_empty() else str(int(shown.get(gk, 0)))
		_heavy_center(Rect2(r.position.x, r.position.y + 50.0, r.size.x, r.size.y - 60.0), v, mini(T_HERO + 20, _fit(v, r.size.x - 20.0, T_HERO + 20)), Color.WHITE)
		_tip(r, _rule_text(j[gk]))
	_heavy_center(Rect2(cx - 70.0, top - 160.0, 140.0, 90.0), "×", T_HERO, Color("e9d9c4"))
	var rules := Rect2(cx - 450.0, top + 44.0, 900.0, 130.0)
	_panel(rules, Color("e9e2d2"), 8)
	_text(Vector2(rules.position.x + 24.0, rules.position.y + 32.0), "JUDGING CRITERIA", T_XS, c_muted, true)
	for side in 2:
		var gk := "sound" if side == 0 else "mult"
		var col := Color(D.SOUND_COLOR if side == 0 else D.MULT_COLOR)
		var ly := rules.position.y + 66.0 + side * 40.0
		draw_circle(Vector2(rules.position.x + 34.0, ly - 7.0), 9.0, col)
		_text(Vector2(rules.position.x + 54.0, ly), _rule_text(j[gk]), T_SM, col.darkened(0.35), true)
	_draw_scorecard(Rect2(cx - 380.0, top + 196.0, 760.0, 200.0), j)
	_draw_bell(Vector2(r_scene.end.x - 100.0, top))

func _draw_scorecard(sc: Rect2, j: Dictionary) -> void:
	_shadow(sc, 8, 6.0)
	_panel(sc, Color("f4efe4"), 8)
	draw_circle(Vector2(sc.get_center().x, sc.position.y + 14.0), 8.0, Color("888780"))
	var known := not shown.is_empty()
	var a := maxi(1, int(shown.get("sound", 0)))
	var b := maxi(1, int(shown.get("mult", 0)))
	var total := a * b
	var target := int(j["target"])
	var line := "%d × %d = %s" % [a, b, _fmt(total)] if known else "? × ? = ?"
	_heavy(Vector2(sc.position.x + 30.0, sc.position.y + 84.0), line, T_XL, c_ink)
	_text_right(sc.end.x - 30.0, sc.position.y + 78.0, "Target %s" % _fmt(target), T_LG, c_good if known and total >= target else c_body, true)
	var bar := Rect2(sc.position.x + 30.0, sc.position.y + 112.0, sc.size.x - 60.0, 24.0)
	_panel(bar, Color(0, 0, 0, 0.12), 12)
	var ratio := clampf(float(total) / maxf(1.0, target), 0.0, 1.0) if known else 0.0
	if ratio > 0.0:
		_panel(Rect2(bar.position, Vector2(maxf(24.0, bar.size.x * ratio), bar.size.y)), c_good if ratio >= 1.0 else c_gold, 12)
	_text(Vector2(sc.position.x + 30.0, sc.position.y + 176.0), "Cash from discs: +$%d" % shown_cash, T_SM, c_body, true)
	if phase in [Phase.RESULT, Phase.GAMEOVER, Phase.WIN]:
		var hit := bool(result.get("hit", false))
		var col := c_good if hit else c_bad
		_rotated(sc.get_center() + Vector2(20, 10), -0.18)
		var st := Rect2(-170.0, -46.0, 340.0, 92.0)
		_panel(st, Color(0, 0, 0, 0), 10, Color(col, 0.85), 6)
		_heavy_center(st, "PASSED" if hit else "REJECTED", T_XL, Color(col, 0.85))
		_unrotated()

func _draw_bell(base: Vector2) -> void:
	var r := Rect2(base.x - 100.0, base.y - 150.0, 200.0, 150.0)
	var ok := phase == Phase.JUDGE and not judging
	var hovered := ok and ui_live and r.has_point(mouse)
	var dome := Color("e3e8ee") if hovered else Color("c9d2db")
	_panel(Rect2(base.x - 90.0, base.y - 26.0, 180.0, 26.0), Color("2b2f35"), 6)
	var pts := PackedVector2Array()
	for k in 21:
		var a := PI + PI * k / 20.0
		pts.append(Vector2(base.x + cos(a) * 72.0, base.y - 26.0 + sin(a) * 72.0))
	draw_colored_polygon(pts, dome)
	draw_arc(Vector2(base.x, base.y - 26.0), 56.0, PI + 0.5, PI + 1.2, 12, Color(1, 1, 1, 0.6), 5.0, true)
	draw_rect(Rect2(base.x - 6.0, base.y - 118.0, 12.0, 22.0), Color("888780"))
	draw_circle(Vector2(base.x, base.y - 122.0), 13.0, Color("888780"))
	var label := "Judging..." if judging else ("Ring to judge" if ok else "")
	_text_center(Rect2(r.position.x, base.y + 30.0, r.size.x, 40.0), label, T_MD, Color("e9d9c4"), true)
	if ok:
		_tip(r, "Every disc on this sheet activates in order, slot 1 to 9.")
		_register(r, _start_judging)

func _draw_binder() -> void:
	var b := p_binder
	var sheet: Array = _cur()
	var live := phase == Phase.SHOP or phase == Phase.WORKSHOP
	var j := judges[round_n - 1]
	_shadow(b, 20, 10.0)
	_grad_panel(b, 20.0, C_LEATHER.lightened(0.1), C_LEATHER.darkened(0.15))
	_grain(b, 19, 260.0)
	_stitch_rect(b.grow(-14.0), Color("aab3bf", 0.45))
	_text_center(Rect2(b.position.x, b.position.y + 2.0, b.size.x, BINDER_BORDER), "YOUR BINDER", T_XS, Color("c9ced6"), true)
	var strip := Rect2(b.position.x + BINDER_BORDER, b.position.y + BINDER_BORDER, BINDER_RINGS - 14.0, b.size.y - BINDER_BORDER * 2.0)
	_grad_panel(strip, 6.0, Color("2a2e34"), Color("1f2227"))
	var page := Rect2(r_grid.position.x - 22.0, r_grid.position.y - 12.0, r_grid.size.x + 34.0, r_grid.size.y + 24.0)
	_panel(page, Color(Color("dfe7f1"), 0.12), 8, Color(1, 1, 1, 0.18), 2)
	for k in 3:
		var hy := r_grid.position.y + r_grid.size.y * (0.17 + k * 0.33)
		var hx := page.position.x + 11.0
		draw_circle(Vector2(hx, hy), 7.0, Color(0, 0, 0, 0.6))
		var sx := strip.get_center().x
		var ecx := (sx + hx) * 0.5
		var rx := (hx - sx) * 0.5 + 4.0
		var pts := PackedVector2Array()
		for i in 41:
			var a := i / 40.0 * TAU
			pts.append(Vector2(ecx + cos(a) * rx, hy + sin(a) * 16.0))
		draw_polyline(pts, Color("5f676f"), 8.0, true)
		draw_polyline(pts, Color("c3cad1"), 5.0, true)
	for i in 9:
		var r := _cd_rect(i)
		var pocket := r.grow(GAP * 0.5 - 1.0)
		var sl := sleeves[i]
		if sl != "":
			_panel(pocket, Color(Color(D.SLEEVES[sl]["color"]), 0.22), 8, Color(D.SLEEVES[sl]["color"]), 4)
		else:
			_panel(pocket, Color(1, 1, 1, 0.025), 8, Color(1, 1, 1, 0.13), 2)
		_pocket_lip(pocket)
		var d: Disc = sheet[i]
		if d == null:
			_heavy_center(r, str(i + 1), 72, Color(1, 1, 1, 0.12))
		else:
			_draw_cd(r, d, false)
			_tip_disc(r, d, "", sl)
			var tags := Rect2(r.position.x, r.end.y + 12.0, r.size.x, CARD_H - CARD_W - 12.0)
			_chip_rows(tags, _disc_rows(d, sl, j, 2))
			_tip_disc(tags, d, "", sl)
		if slot_flash[i] > 0.0:
			_panel(r.grow(5.0), Color(0, 0, 0, 0), 16, Color(c_gold, slot_flash[i]), 6)
		if mode == "sleeve":
			_panel(r, Color(c_accent, 0.25 + 0.1 * sin(clock * 5.0)), 12, Color(c_accent.lightened(0.35), 0.9), 3)
		elif mode == "job" and d != null and _can_job(orders[mode_i], d):
			_panel(r.grow(4.0), Color(0, 0, 0, 0), 14, Color("7fe0a0", 0.8 + 0.2 * sin(clock * 5.0)), 6)
		elif mode == "job" and d != null:
			draw_circle(r.get_center(), r.size.x * 0.5 - 8.0, Color(0, 0, 0, 0.45))
		elif sel == Vector2i(0, i):
			_panel(r.grow(4.0), Color(0, 0, 0, 0), 14, c_gold, 6)
		elif sel.x >= 0 and mode == "":
			_panel(r, Color(c_accent, 0.12), 12)
		if sl != "":
			var tag := String(D.SLEEVES[sl]["name"]).to_upper()
			var tw := _text_w(tag, T_XS, true) + 20.0
			var tr := Rect2(r.get_center().x - tw * 0.5, r.position.y - 14.0, tw, 24.0)
			_panel(tr, Color(D.SLEEVES[sl]["color"]).darkened(0.2), 12)
			_text_center(tr, tag, T_XS, Color.WHITE, true)
			_tip(tr, "%s sleeve: %s" % [D.SLEEVES[sl]["name"], D.SLEEVES[sl]["text"]])
		_sleeve_gloss(r)
		if live:
			_register(r, _on_slot.bind(0, i))
	if live and mode == "" and sel.x >= 0:
		var d: Disc = sheet[sel.y]
		if d != null:
			var sr := _cd_rect(sel.y)
			_brass_button(Rect2(sr.get_center().x - 110.0, sr.end.y - 64.0, 220.0, 56.0), "Sell $%d" % _sell_price(d), _sell_selected, true)

func _draw_cd(r: Rect2, d: Disc, dim: bool) -> void:
	var c := r.get_center()
	var rad := minf(r.size.x, r.size.y) * 0.5 - 8.0
	_cd_art(c, rad, _cover_tex(d.cover))
	if d.edition != "":
		_edition_overlay(c, rad, d.edition)
	_ability_badge(Rect2(r.position.x + 28.0, r.end.y - 70.0, r.size.x - 56.0, 46.0), d.ability)
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
	if d.rarity > 0:
		_sticker_burst(cover.position + Vector2(22.0, 22.0) * k, 21.0 * k, Color(D.RARITY_COLORS[d.rarity]).darkened(0.1), "RARE" if d.rarity == 2 else "UNC", _fs(11.0, k))
	if price >= 0:
		_price_sticker(Vector2(cover.end.x - 30.0 * k, cover.position.y + 14.0 * k), "$%d" % price, k)
	_ability_badge(Rect2(cover.position.x + 5.0 * k, cover.end.y - 38.0 * k, cover.size.x - 10.0 * k, 32.0 * k), d.ability)

func _pack_tip(id: String) -> String:
	var p: Dictionary = D.PACKS[id]
	var w: Array = p["rarity"]
	return "%s: %d discs (%d%% common, %d%% uncommon, %d%% rare) plus $%d–%d cash.\nKeep what fits on this sheet; the rest sell automatically." % [p["name"], int(p["discs"]), int(w[0]), int(w[1]), int(w[2]), int(p["cash"][0]), int(p["cash"][1])]

func _close_preview() -> void:
	preview = ""

func _open_preview(kind: String = "judge", k: int = -1) -> void:
	preview = kind
	preview_j = round_n - 1 if k < 0 else k

func _judge_card(r: Rect2, j: Dictionary, k: int) -> void:
	_panel(Rect2(r.position + Vector2(0, 6), r.size), Color(0, 0, 0, 0.35), 18)
	_panel(r, Color("161a24"), 18, Color("ff6ad5", 0.7), 4)
	var x := r.position.x
	var w := r.size.x
	_text_center(Rect2(x, r.position.y + 14.0, w, 36.0), "JUDGE %d OF %d" % [k + 1, D.ROUNDS], T_SM, Color("ffb3ec"), true)
	var jn := String(j["name"])
	_heavy_center(Rect2(x, r.position.y + 56.0, w, 70.0), jn, mini(T_XL, _fit(jn, w - 40.0, T_XL)), Color("ffd6f3"))
	var y := r.position.y + 150.0
	for gk in ["sound", "mult"]:
		var col := Color(D.SOUND_COLOR if gk == "sound" else D.MULT_COLOR)
		var br := Rect2(x + 24.0, y, w - 48.0, 56.0)
		_panel(br, col, 12)
		var t := _rule_text(j[gk])
		_text_center(br, t, mini(T_SM, _fit(t, br.size.x - 20.0, T_SM)), Color.WHITE, true)
		y += 70.0
	_text(Vector2(x + 28.0, r.end.y - 30.0), "TARGET  (SOUND × MULT)", T_SM, Color("b4b2a9"), true)
	_heavy_right(x + w - 28.0, r.end.y - 24.0, _fmt(int(j["target"])), T_XL, c_gold)

func _relevant(d: Disc, j: Dictionary) -> bool:
	return _meets(d, j["sound"]["f"]) or _meets(d, j["mult"]["f"])

func _draw_judge_preview() -> void:
	var r := _modal(1400.0, 760.0)
	var j := judges[preview_j]
	_judge_card(Rect2(r.position.x + 60.0, r.position.y + 60.0, 640.0, 400.0), j, preview_j)
	var x := r.position.x + 760.0
	var y := r.position.y + 90.0
	var w := r.end.x - x - 60.0
	_wrap(Vector2(x, y), "Every disc on your sheet activates in order, slot 1 to 9. Each adds its base Sound, then this judge's rules, then its own ability. Score = Sound × Mult.", w, T_SM, c_body, true)
	y += 170.0
	for gk in ["sound", "mult"]:
		var f: Dictionary = j[gk]["f"]
		var n := 0
		for d in _cur():
			if d != null and _meets(d, f):
				n += 1
		var col := Color(D.SOUND_COLOR if gk == "sound" else D.MULT_COLOR)
		_text(Vector2(x, y), "%s rule: %d of your discs are %s" % ["Sound" if gk == "sound" else "Mult", n, _filter_text(f)], T_SM, col.darkened(0.2), true)
		y += 40.0
	_wrap(Vector2(x, y + 10.0), "Matching tags are outlined in green and purple on your binder. Where a disc sits can matter as much as what it is.", w, T_XS, c_muted, true)
	_ghost(Rect2(r.get_center().x - 120.0, r.end.y - 90.0, 240.0, 60.0), "Close", _close_preview, true, c_ink)

func _draw_pack() -> void:
	var n := pack_items.size()
	var cw := minf(CARD_W, (2000.0 - (n - 1) * 24.0) / n)
	var ch := cw * CASE_RATIO
	var total_w := n * cw + (n - 1) * 24.0
	var r := _modal(maxf(1100.0, total_w + 140.0), ch + 450.0)
	var open := _open_slots().size()
	_heavy_center(Rect2(r.position.x, r.position.y + 26.0, r.size.x, 60.0), pack_title, T_XL, c_ink)
	_text_center(Rect2(r.position.x, r.position.y + 84.0, r.size.x, 30.0), "Click to keep or sell. Keeping %d of %d open slots. Bonus cash: +$%d" % [_kept(), open, pack_cash], T_MD, c_bad if _kept() > open else c_muted, true)
	var x := r.position.x + (r.size.x - total_w) * 0.5
	for i in n:
		var cr := Rect2(x + i * (cw + 24.0), r.position.y + 140.0, cw, ch)
		var d := pack_items[i]
		_draw_case(cr, d)
		_tip_disc(cr, d, "Keep it, or sell it for $%d." % _sell_price(d))
		_chip_rows(Rect2(cr.position.x, cr.end.y + 8.0, cw, 56.0), _disc_rows(d, "", judges[round_n - 1], 2))
		var tag := Rect2(cr.position.x, cr.end.y + 76.0, cw, 44.0)
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
	var r := Rect2(p_binder.position.x + 90.0, 470.0, p_binder.size.x - 180.0, 560.0)
	_panel(Rect2(r.position + Vector2(0, 10), r.size), Color(0, 0, 0, 0.5), 28)
	_panel(r, Color("f4efe4"), 28)
	var j := judges[round_n - 1]
	var hit := bool(result["hit"])
	var x := r.position.x + 60.0
	var w := r.size.x - 120.0
	_heavy_center(Rect2(r.position.x, r.position.y + 24.0, r.size.x, 60.0), "Impressed!" if hit else "Not impressed.", T_XL, c_good if hit else c_bad)
	var y := r.position.y + 140.0
	_row(x, w, y, "Score", "%s / %s" % [_fmt(int(result["total"])), _fmt(int(result["target"]))], c_good if hit else c_bad)
	y += 56.0
	_row(x, w, y, "Disc cash", "+$%d" % int(result["cash"]))
	y += 56.0
	_row(x, w, y, "Clear reward", "+$%d" % int(result["reward"]), Color("b28a3a"))
	y += 40.0
	draw_line(Vector2(x, y), Vector2(x + w, y), c_line, 2.0)
	_text_center(Rect2(r.position.x, y + 20.0, r.size.x, 40.0), String(j["name"]), T_SM, c_muted, true)
	var label := "Back to the shop"
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

func _total(c: Dictionary) -> int:
	return maxi(1, int(c["sound"])) * maxi(1, int(c["mult"]))

func _tag_key(c: Dictionary) -> String:
	return "%s:%d" % [c["attr"], int(c["v"])]

func _make_rule(gain: String) -> Dictionary:
	var f := _rand_cond()
	var where: String = D.ZONES[_weighted(D.ZONE_WEIGHTS)]
	var group := where.left(3) if where.begins_with("row") or where.begins_with("col") else where
	return {"gain": gain, "f": f, "where": where, "n": int(D.RULE_N[gain][group])}

func _make_judge() -> Dictionary:
	var s := _make_rule("sound")
	var m := _make_rule("mult")
	return {"sound": s, "mult": m, "name": "The %s %s" % [D.JUDGE_ADJ[_tag_key(s["f"])], D.JUDGE_NOUN[_tag_key(m["f"])]], "target": 0}

func _rule_text(r: Dictionary) -> String:
	var g := "Sound" if r["gain"] == "sound" else "Mult"
	var f := _filter_text(r["f"])
	if r["where"] == "pair":
		return "+%d %s per %s album next to another %s album" % [int(r["n"]), g, f, f]
	return "+%d %s per %s album%s" % [int(r["n"]), g, f, D.ZONE_TEXT[r["where"]]]

func _zone_has(where: String, i: int) -> bool:
	match where:
		"any":
			return true
		"corner", "center", "edge":
			return _slot_is(i, where)
	if where.begins_with("row"):
		return i / 3 == int(where.right(1))
	return i % 3 == int(where.right(1))

func _rule_hits(sheet: Array, sl: Array, i: int, r: Dictionary) -> int:
	if not _meets_s(sheet[i], _sl(sl, i), r["f"]):
		return 0
	if r["where"] == "pair":
		for k in _nbrs(i):
			if sheet[k] != null and _meets_s(sheet[k], _sl(sl, k), r["f"]):
				return 1
		return 0
	return 1 if _zone_has(String(r["where"]), i) else 0

func _gain_text(a: Dictionary) -> String:
	match String(a.get("gain", "sound")):
		"mult":
			return "+%d Mult" % int(a["n"])
		"xmult":
			return "×%d Mult" % int(a["n"])
	return "+%d Sound" % int(a["n"])

func _rar(d: Disc, s: String) -> int:
	return mini(2, d.rarity + (1 if s == "grade" else 0))

func _attr_s(d: Disc, s: String, attr: String) -> int:
	match attr:
		"cond":
			return 2 if s == "polish" else d.cond
		"rarity":
			return _rar(d, s)
	return _attr(d, attr)

func _same(sheet: Array, sl: Array, i: int, k: int, attr: String) -> bool:
	if attr == "genre" and (_sl(sl, i) == "wild" or _sl(sl, k) == "wild"):
		return true
	return _attr_s(sheet[i], _sl(sl, i), attr) == _attr_s(sheet[k], _sl(sl, k), attr)

func _diags(i: int) -> Array[int]:
	var out: Array[int] = []
	for dy in [-1, 1]:
		for dx in [-1, 1]:
			var x: int = i % 3 + dx
			var y: int = i / 3 + dy
			if x >= 0 and x < 3 and y >= 0 and y < 3:
				out.append(y * 3 + x)
	return out

func _cd_rect(i: int) -> Rect2:
	var r := _slot_rect(i)
	return Rect2(r.position, Vector2(CARD_W, CARD_W))

func _set_sort(k: String) -> void:
	sort_key = "" if sort_key == k else k

func _sort_val(d: Disc, price: int) -> int:
	match sort_key:
		"price":
			return price
		"genre":
			return d.genre
		"era":
			return d.era
		"label":
			return d.label
		"rarity":
			return -d.rarity
		"cond":
			return -d.cond
	return 0

func _sort_order(discs: Array, prices: Array) -> Array:
	var idx: Array = range(discs.size())
	if sort_key == "":
		return idx
	idx.sort_custom(func(x, y):
		var va := _sort_val(discs[x], int(prices[x]))
		var vb := _sort_val(discs[y], int(prices[y]))
		return va < vb if va != vb else x < y)
	return idx

func _draw_sort_bar(r: Rect2, cols: int, price_text: String) -> void:
	_panel(r, Color(0.06, 0.07, 0.09, 0.78), 14, Color(1, 1, 1, 0.1), 2)
	var keys := D.SORT_KEYS
	var rows := int(ceil(keys.size() / float(cols)))
	var head := 150.0 if rows == 1 else 0.0
	var top := 0.0 if rows == 1 else 40.0
	_text(Vector2(r.position.x + 18.0, r.position.y + (r.size.y * 0.5 + 6.0 if rows == 1 else 30.0)), "ORGANIZE BY", T_XS, Color("c9ced6"), true)
	var area := Rect2(r.position.x + 12.0 + head, r.position.y + 10.0 + top, r.size.x - 24.0 - head, r.size.y - 20.0 - top)
	var cw := (area.size.x - (cols - 1) * 8.0) / cols
	var ch := (area.size.y - (rows - 1) * 8.0) / rows
	for k in keys.size():
		var key: String = keys[k]
		var cr := Rect2(area.position.x + (k % cols) * (cw + 8.0), area.position.y + (k / cols) * (ch + 8.0), cw, ch)
		var on := sort_key == key
		var hovered := ui_live and cr.has_point(mouse)
		_panel(cr, c_gold if on else Color(1, 1, 1, 0.16 if hovered else 0.08), 10)
		var label: String = price_text if key == "price" else String(D.SORT_TEXT[key])
		_text_center(cr, label, mini(T_XS, _fit(label, cw - 10.0, T_XS)), c_ink if on else c_light, true)
		_register(cr, _set_sort.bind(key))

func _chip_rows(r: Rect2, rows: Array, emph: String = "", left: bool = false) -> void:
	var rh := r.size.y / rows.size()
	for ri in rows.size():
		var row: Array = rows[ri]
		var fs := T_XS
		var total := -5.0
		for c in row:
			total += _text_w(String(c[1]), fs, true) + 19.0
		if total > r.size.x:
			fs = maxi(10, int(fs * r.size.x / total))
		total = -5.0
		for c in row:
			total += _text_w(String(c[1]), fs, true) + 19.0
		var x := r.position.x + (0.0 if left else (r.size.x - total) * 0.5)
		for c in row:
			var t := String(c[1])
			var w := _text_w(t, fs, true) + 14.0
			var cr := Rect2(x, r.position.y + ri * rh + 2.0, w, rh - 4.0)
			var rings: Array = c[4]
			for k in rings.size():
				_panel(cr.grow(2.0 + k * 3.0), Color(0, 0, 0, 0), 12, rings[k], 3)
			var em: bool = emph != "" and c[0] == emph
			_panel(cr, c[2], 10, c_gold if em else Color(0, 0, 0, 0.25), 3 if em else 1)
			_text_center(cr, t, fs, c[3], true)
			x += w + 5.0

func _disc_rows(d: Disc, s: String, j: Dictionary, layout: int) -> Array:
	var rings := {}
	for gk in ["sound", "mult"]:
		var f: Dictionary = j[gk]["f"]
		if _meets_s(d, s, f):
			var key := String(f["attr"])
			if not rings.has(key):
				rings[key] = []
			rings[key].append(Color(D.SOUND_COLOR if gk == "sound" else D.MULT_COLOR))
	var era := ["era", D.ERAS[d.era], Color("fbfaf5"), c_ink, rings.get("era", [])]
	var genre := ["genre", D.GENRES[d.genre].to_upper(), Color("fbfaf5"), Color(D.GENRE_COLORS[d.genre]).darkened(0.15), rings.get("genre", [])]
	var label := ["label", String(D.LABELS[d.label]["short"]).to_upper(), Color("e6e1d6"), c_ink, rings.get("label", [])]
	var rar := ["rarity", D.RARITY_SHORT[d.rarity], Color(D.RARITY_COLORS[d.rarity]), c_ink, rings.get("rarity", [])]
	var cond := ["cond", D.CONDITIONS[d.cond].to_upper(), Color(D.CONDITION_COLORS[d.cond]), c_ink, rings.get("cond", [])]
	var low: Array = [rar, cond]
	if d.edition != "":
		var ec := Color(D.EDITIONS[d.edition]["color"])
		low.append(["edition", String(D.EDITIONS[d.edition]["name"]).to_upper(), ec, _ink_on(ec), []])
	return [[era, genre, label], low]

func _judge_tip(j: Dictionary) -> String:
	return "%s\n%s\n%s\nTarget: %s" % [j["name"], _rule_text(j["sound"]), _rule_text(j["mult"]), _fmt(int(j["target"]))]

func _tip_disc(r: Rect2, d: Disc, extra: String = "", sleeve: String = "") -> void:
	if ui_live and r.has_point(mouse):
		hover_obj = d
		hover_extra = extra
		hover_sleeve = sleeve
		hover_tip = ""

func _when_label(a: Dictionary) -> String:
	return {"activated": "WHEN JUDGED", "placed": "WHEN PLACED", "sold": "WHEN SOLD"}[a["when"]]

func _ability_chip(a: Dictionary) -> Array:
	var n := int(a["n"])
	match String(a["kind"]):
		"retrigger_left", "retrigger_above", "retrigger_nbrs":
			return ["RETRIGGER", Color("3fa7a0")]
		"cash", "gen_cash", "sold_cash":
			return ["+$%d" % n, c_gold]
		"gen_pack":
			return ["FREE BUNDLE", c_gold]
		"sold_rare":
			return ["RARE ALBUM", Color(D.RARITY_COLORS[2])]
	var g := String(a.get("gain", "sound"))
	return [_gain_text(a), Color(D.SOUND_COLOR if g == "sound" else D.MULT_COLOR)]

func _ability_body(a: Dictionary) -> String:
	match String(a["kind"]):
		"cash":
			return "Every time it activates."
		"gen_cash":
			return "When you put it in your binder."
		"sold_cash":
			return "Extra cash when you sell it."
		"gen_pack":
			return "Opens a free Bargain Bin bundle when you put it in your binder."
		"sold_rare":
			return "Creates a random Rare album when you sell it."
	var pre: String = {"activated": "Activated: ", "placed": "Placed: ", "sold": "Sold: "}[a["when"]]
	var t := _ability_text(a).trim_prefix(pre)
	var g := _gain_text(a)
	if t == g + ".":
		return "Always."
	if t.begins_with(g + " "):
		t = t.substr(g.length() + 1)
		t = t.left(1).to_upper() + t.substr(1)
	return t

func _rule_hint(r: Dictionary) -> String:
	if r["where"] == "pair":
		return "next to another %s album" % _filter_text(r["f"])
	if r["where"] == "any":
		return "anywhere on the sheet"
	return String(D.ZONE_TEXT[r["where"]]).strip_edges()

func _draw_rich_tip() -> bool:
	if hover_obj == null:
		return false
	var d: Disc = hover_obj
	var w := 620.0
	var h := _disc_tip_body(d, Vector2.ZERO, w, false)
	var box := Rect2(mouse + Vector2(28.0, 28.0), Vector2(w, h))
	if box.end.x > UI_W - 12.0:
		box.position.x = mouse.x - w - 20.0
	if box.end.y > UI_H - 12.0:
		box.position.y = maxf(12.0, UI_H - 12.0 - h)
	_panel(Rect2(box.position + Vector2(0, 8), box.size), Color(0, 0, 0, 0.4), 18)
	_panel(box, Color("161b24"), 18, Color(1, 1, 1, 0.14), 2)
	_disc_tip_body(d, box.position, w, true)
	return true

func _disc_tip_body(d: Disc, o: Vector2, w: float, paint: bool) -> float:
	var pad := 24.0
	var x := o.x + pad
	var iw := w - pad * 2.0
	var y := o.y + pad
	var j := judges[round_n - 1]
	var tfs := mini(T_LG, _fit(d.title, iw, T_LG))
	if paint:
		_heavy(Vector2(x, y + 30.0), d.title, tfs, Color.WHITE)
		_text_i(Vector2(x, y + 66.0), "by %s" % d.band, T_SM, Color("b8c0cc"))
	y += 84.0
	if paint:
		_chip_rows(Rect2(x, y, iw, 64.0), _disc_rows(d, hover_sleeve, j, 2), "", true)
	y += 78.0
	var a := d.ability
	if not a.is_empty():
		if paint:
			draw_line(Vector2(x, y), Vector2(x + iw, y), Color(1, 1, 1, 0.12), 2.0)
			_text(Vector2(x, y + 34.0), _when_label(a), T_XS, c_gold, true)
		y += 48.0
		var chip := _ability_chip(a)
		var ct := String(chip[0])
		var ccol: Color = chip[1]
		var cw := _text_w(ct, T_SM, true) + 28.0
		var body := _ability_body(a)
		var bw := iw - cw - 16.0
		var bh := font.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, bw, T_SM).y
		if paint:
			var cr := Rect2(x, y, cw, 38.0)
			_panel(cr, ccol, 19)
			_text_center(cr, ct, T_SM, _ink_on(ccol), true)
			_wrap(Vector2(x + cw + 16.0, y + 4.0), body, bw, T_SM, Color("e8ecf2"))
		y += maxf(38.0, bh + 4.0) + 18.0
	if d.edition != "":
		var ed: Dictionary = D.EDITIONS[d.edition]
		var ecol := Color(ed["color"])
		if paint:
			draw_line(Vector2(x, y), Vector2(x + iw, y), Color(1, 1, 1, 0.12), 2.0)
			_text(Vector2(x, y + 34.0), "%s EDITION" % String(ed["name"]).to_upper(), T_XS, ecol.lightened(0.3), true)
			_text(Vector2(x, y + 72.0), String(ed["text"]), T_SM, Color("e8ecf2"))
		y += 92.0
	if paint:
		draw_line(Vector2(x, y), Vector2(x + iw, y), Color(1, 1, 1, 0.12), 2.0)
		_text(Vector2(x, y + 34.0), "TONIGHT'S JUDGE", T_XS, Color("ffb3ec"), true)
	y += 48.0
	var any := false
	for gk in ["sound", "mult"]:
		var r: Dictionary = j[gk]
		if not _meets_s(d, hover_sleeve, r["f"]):
			continue
		any = true
		var col := Color(D.SOUND_COLOR if gk == "sound" else D.MULT_COLOR)
		if paint:
			draw_circle(Vector2(x + 9.0, y + 12.0), 8.0, col)
			var head := "+%d %s" % [int(r["n"]), "Sound" if gk == "sound" else "Mult"]
			_text(Vector2(x + 28.0, y + 20.0), head, T_SM, col.lightened(0.35), true)
			_text_i(Vector2(x + 34.0 + _text_w(head, T_SM, true), y + 20.0), _rule_hint(r), T_SM, Color("c9ced6"))
		y += 34.0
	if not any:
		if paint:
			_text_i(Vector2(x, y + 20.0), "No tags this judge rewards.", T_SM, Color("8a93a0"))
		y += 34.0
	y += 8.0
	if hover_sleeve != "":
		var s: Dictionary = D.SLEEVES[hover_sleeve]
		if paint:
			draw_line(Vector2(x, y), Vector2(x + iw, y), Color(1, 1, 1, 0.12), 2.0)
			_text(Vector2(x, y + 34.0), "%s SLEEVE" % String(s["name"]).to_upper(), T_XS, Color(s["color"]).lightened(0.3), true)
			_wrap(Vector2(x, y + 46.0), String(s["text"]) + " This round only.", iw, T_SM, Color("e8ecf2"))
		y += 46.0 + font.get_multiline_string_size(String(s["text"]) + " This round only.", HORIZONTAL_ALIGNMENT_LEFT, iw, T_SM).y + 10.0
	if paint:
		draw_line(Vector2(x, y), Vector2(x + iw, y), Color(1, 1, 1, 0.12), 2.0)
		_text_i(Vector2(x, y + 32.0), "%s  ·  %d min" % [D.LABELS[d.label]["name"], d.runtime], T_XS, Color("8a93a0"))
		_text_right(x + iw, y + 32.0, "Sells for $%d" % _sell_price(d), T_XS, Color("8a93a0"), true)
	y += 44.0
	if hover_extra != "":
		var eh := font_bold.get_multiline_string_size(hover_extra, HORIZONTAL_ALIGNMENT_LEFT, iw, T_SM).y
		if paint:
			_wrap(Vector2(x, y + 2.0), hover_extra, iw, T_SM, c_gold, true)
		y += eh + 10.0
	return y - o.y + pad - 8.0

func _make_orders() -> void:
	orders.clear()
	var keys: Array = D.JOBS.keys()
	var w: Array = []
	for k in keys:
		w.append(int(D.JOBS[k]["weight"]))
	for i in D.WORKSHOP_ORDERS:
		var id: String = keys[_weighted(w)]
		var o := {"id": id, "done": false, "v": 0}
		match id:
			"remix":
				o["v"] = rng.randi_range(0, D.GENRES.size() - 1)
			"remaster":
				o["v"] = 1 if rng.randf() < 0.5 else -1
			"relabel":
				o["v"] = rng.randi_range(0, D.LABELS.size() - 1)
		orders.append(o)

func _order_title(o: Dictionary) -> String:
	var v := int(o["v"])
	match String(o["id"]):
		"remix":
			return "→ %s" % D.GENRES[v]
		"remaster":
			return "%+d decade" % v
		"relabel":
			return "→ %s" % D.LABELS[v]["short"]
		"repress":
			return "+1 condition"
	var ed: Dictionary = D.EDITIONS[o["id"]]
	return ("×%d Mult" if ed["kind"] == "xmult" else ("+%d Mult" if ed["kind"] == "mult" else "+%d Sound")) % int(ed["n"])

func _order_text(o: Dictionary) -> String:
	var v := int(o["v"])
	match String(o["id"]):
		"remix":
			return "Change a disc's genre to %s." % D.GENRES[v]
		"remaster":
			return "Make a disc one decade %s." % ("newer" if v > 0 else "older")
		"relabel":
			return "Move a disc to %s." % D.LABELS[v]["name"]
		"repress":
			return "Raise a disc's condition one step: Worn → Good → Mint."
	return "%s Permanent; replaces any edition it already has." % D.EDITIONS[o["id"]]["text"]

func _can_job(o: Dictionary, d: Disc) -> bool:
	var v := int(o["v"])
	match String(o["id"]):
		"remix":
			return d.genre != v
		"remaster":
			return d.era + v >= 0 and d.era + v < D.ERAS.size()
		"relabel":
			return d.label != v
		"repress":
			return d.cond < 2
	return d.edition != String(o["id"])

func _start_job(i: int) -> void:
	var o: Dictionary = orders[i]
	if bool(o["done"]):
		return
	if cash < int(D.JOBS[o["id"]]["price"]):
		_say("Not enough cash for that job.")
		return
	_cancel()
	mode = "job"
	mode_i = i

func _apply_job(slot: int) -> void:
	var d: Disc = _cur()[slot]
	var o: Dictionary = orders[mode_i]
	if not _can_job(o, d):
		_say("That disc can't take this job.")
		return
	var v := int(o["v"])
	var id := String(o["id"])
	match id:
		"remix":
			d.genre = v
		"remaster":
			d.era += v
		"relabel":
			d.label = v
		"repress":
			d.cond += 1
		_:
			d.edition = id
	cash -= int(D.JOBS[id]["price"])
	o["done"] = true
	_float(_cd_rect(slot), String(D.JOBS[id]["name"]) if D.EDITIONS.has(id) else _order_title(o), c_gold)
	_sfx("page_turn")
	_cancel()

func _go_workshop() -> void:
	_cancel()
	view = 0
	phase = Phase.WORKSHOP
	phase_t = 0.0

func _draw_workshop() -> void:
	_backdrop(Color("454a50"), 1250.0, Color("2b2e33"))
	var y := 60.0
	while y < 1250.0:
		draw_line(Vector2(-40, y), Vector2(UI_W, y), Color(0, 0, 0, 0.1), 2.0)
		y += 64.0
	var sign := Rect2(r_scene.get_center().x - 380.0, 150.0, 760.0, 96.0)
	_panel(sign, Color("1d1f22"), 8, Color("f2c14e"), 4)
	_heavy_center(sign, "PRESSING PLANT", T_XL, Color("f2c14e"))
	_draw_press(Rect2(70.0, 300.0, 380.0, 820.0))
	var board := Rect2(480.0, 280.0, r_scene.end.x - 480.0, 840.0)
	_shadow(board, 10, 8.0)
	_panel(board, Color("b08850"), 10, Color("6f4a2c"), 8)
	_grain(board, 7, 300.0)
	_text(Vector2(board.position.x + 28.0, board.position.y + 48.0), "WORK ORDERS", T_SM, Color("3a2412"), true)
	_text_right(board.end.x - 28.0, board.position.y + 48.0, "Pick a job, then a disc in your binder", T_XS, Color("4a3520"), true)
	var cw := (board.size.x - 56.0 - 48.0) / 3.0
	var ch := 340.0
	for i in orders.size():
		var row := i / 3
		var in_row := mini(3, orders.size() - row * 3)
		var x0 := board.position.x + 28.0 + (3 - in_row) * (cw + 24.0) * 0.5
		var r := Rect2(x0 + (i % 3) * (cw + 24.0), board.position.y + 80.0 + row * (ch + 30.0), cw, ch)
		_draw_order(r, orders[i], i)

func _draw_press(r: Rect2) -> void:
	_shadow(r, 10, 8.0)
	_grad_panel(r, 10.0, Color("8a939c"), Color("5f676f"))
	var head := Rect2(r.position.x + 20.0, r.position.y + 20.0, r.size.x - 40.0, 160.0)
	_panel(head, Color("3a3f46"), 8)
	_panel(Rect2(head.position.x + 24.0, head.position.y + 24.0, 150.0, 50.0), Color("0f1a12"), 6)
	_text(Vector2(head.position.x + 38.0, head.position.y + 58.0), "PRESS 01", T_SM, Color("7fe0a0"), true)
	draw_circle(Vector2(head.end.x - 50.0, head.position.y + 50.0), 18.0, Color("c0392b") if mode == "job" else Color("5a2a24"))
	var ram := Rect2(r.get_center().x - 50.0, head.end.y, 100.0, 120.0 + (20.0 * sin(clock * 6.0) if mode == "job" else 0.0))
	_grad_panel(ram, 4.0, Color("c3cad1"), Color("8a939c"))
	var platter := Vector2(r.get_center().x, r.position.y + 470.0)
	draw_circle(platter, 150.0, Color("2b2f35"))
	_disc(platter, 120.0)
	var base := Rect2(r.position.x, r.end.y - 120.0, r.size.x, 120.0)
	draw_rect(base, Color("1d1f22"))
	var sx := base.position.x + 10.0
	while sx + 100.0 < base.end.x:
		draw_colored_polygon(PackedVector2Array([Vector2(sx, base.end.y - 10.0), Vector2(sx + 40.0, base.end.y - 10.0), Vector2(sx + 100.0, base.position.y + 10.0), Vector2(sx + 60.0, base.position.y + 10.0)]), Color("f2c14e"))
		sx += 80.0

func _draw_order(r: Rect2, o: Dictionary, i: int) -> void:
	var job: Dictionary = D.JOBS[o["id"]]
	var col := Color(job["color"])
	var price := int(job["price"])
	var done := bool(o["done"])
	var active := mode == "job" and mode_i == i
	var rr := r
	if not done and (active or (ui_live and r.has_point(mouse))):
		rr.position.y -= 8.0
	_shadow(rr, 6, 5.0)
	_panel(rr, Color("f4efe4"), 6)
	draw_circle(Vector2(rr.get_center().x, rr.position.y + 14.0), 9.0, Color("c0392b"))
	var band := Rect2(rr.position.x, rr.position.y + 30.0, rr.size.x, 52.0)
	draw_rect(band, col)
	var nm := String(job["name"]).to_upper()
	_heavy_center(band, nm, mini(T_MD, _fit(nm, band.size.x - 20.0, T_MD)), _ink_on(col))
	var title := _order_title(o)
	_heavy_center(Rect2(rr.position.x, band.end.y + 10.0, rr.size.x, 70.0), title, mini(T_XL, _fit(title, rr.size.x - 24.0, T_XL)), c_ink)
	_wrap(Vector2(rr.position.x + 20.0, band.end.y + 92.0), _order_text(o), rr.size.x - 40.0, T_XS, c_body, true, 5)
	var n := 0
	for d in _cur():
		if d != null and _can_job(o, d):
			n += 1
	_text(Vector2(rr.position.x + 20.0, rr.end.y - 26.0), "%d disc%s can take it" % [n, "" if n == 1 else "s"], T_XS, c_muted, true)
	_price_sticker(Vector2(rr.end.x - 46.0, rr.end.y - 64.0), "$%d" % price, 1.4)
	if done:
		_panel(rr, Color(0, 0, 0, 0.35), 6)
		_rotated(rr.get_center(), -0.2)
		var st := Rect2(-110.0, -40.0, 220.0, 80.0)
		_panel(st, Color(0, 0, 0, 0), 8, Color(c_bad, 0.9), 6)
		_heavy_center(st, "DONE", T_XL, Color(c_bad, 0.9))
		_unrotated()
		return
	if cash < price:
		_panel(rr, Color(0, 0, 0, 0.3), 6)
	if active:
		_panel(rr.grow(5.0), Color(0, 0, 0, 0), 10, c_gold, 5)
	_tip(r, "%s: %s\nCosts $%d. Click it, then click a disc in your binder." % [job["name"], _order_text(o), price])
	_register(r, _start_job.bind(i))

func _edition_overlay(c: Vector2, rad: float, ed: String) -> void:
	match ed:
		"signed":
			var pts := PackedVector2Array()
			for k in 25:
				var t := k / 24.0
				pts.append(c + Vector2(-rad * 0.6 + t * rad * 1.2, rad * 0.5 + sin(t * TAU * 2.0) * rad * 0.08 - t * rad * 0.15))
			draw_polyline(pts, Color(1, 1, 1, 0.9), maxf(2.0, rad * 0.035), true)
		"picture":
			var hues := [Color("ff9ec4"), Color("ffe08a"), Color("9effa8"), Color("8fe9ff"), Color("c3a8ff")]
			for k in hues.size():
				draw_arc(c, rad * (0.4 + k * 0.12), 0, TAU, 48, Color(hues[k], 0.28), maxf(2.0, rad * 0.06), true)
		"platinum":
			draw_circle(c, rad, Color(0.85, 0.9, 0.95, 0.25))
			draw_arc(c, rad - 4.0, 0, TAU, 72, Color("e8eef4"), maxf(3.0, rad * 0.06), true)

func _badge_spec(a: Dictionary) -> Dictionary:
	var g := String(a.get("gain", "sound"))
	var n := int(a["n"])
	var at := String(D.ATTR_TEXT.get(String(a.get("attr", "")), "")).capitalize()
	var nb: Array = [1, 3, 5, 7]
	var sp := {"grid": true, "self": 4, "cells": [], "token": at, "gain": ("×%d" if g == "xmult" else "+%d") % n, "gcol": Color(D.SOUND_COLOR if g == "sound" else D.MULT_COLOR)}
	match String(a["kind"]):
		"flat":
			sp["grid"] = false
			sp["token"] = "Always"
		"row_match":
			sp["cells"] = [3, 5]
		"col_match":
			sp["cells"] = [1, 7]
		"nbr_match":
			sp["cells"] = nb
		"diag_match":
			sp["cells"] = [0, 2, 6, 8]
		"nbr_filter":
			sp["cells"] = nb
			sp["token"] = _filter_text(a["f"])
		"slot":
			sp["self"] = -1
			sp["cells"] = {"corner": [0, 2, 6, 8], "center": [4], "edge": nb}[a["slot"]]
			sp["token"] = String(a["slot"]).capitalize()
		"era_step":
			sp["cells"] = nb
			sp["token"] = "±1 decade"
		"row_distinct":
			sp["cells"] = [3, 5]
			sp["token"] = "Mixed genre"
		"line_all":
			sp["cells"] = [3, 5] if a["line"] == "row" else [1, 7]
			sp["token"] = "All " + at
		"x_nbrs":
			sp["cells"] = nb
			sp["token"] = "All " + at
		"boost_row":
			sp["cells"] = [3, 5]
			sp["token"] = "Boost"
		"boost_col":
			sp["cells"] = [1, 7]
			sp["token"] = "Boost"
		"retrigger_left", "retrigger_above", "retrigger_nbrs":
			sp["cells"] = {"retrigger_left": [3], "retrigger_above": [1], "retrigger_nbrs": nb}[a["kind"]]
			sp["token"] = "Retrigger"
			sp["gain"] = "AGAIN"
			sp["gcol"] = Color("3fa7a0")
		"runtime":
			sp["grid"] = false
			sp["token"] = "Per 20 min"
		"cash", "gen_cash", "sold_cash":
			sp["grid"] = false
			sp["token"] = {"cash": "Each time", "gen_cash": "On place", "sold_cash": "On sell"}[a["kind"]]
			sp["gain"] = "$%d" % n
			sp["gcol"] = c_gold
		"gen_pack":
			sp["grid"] = false
			sp["token"] = "On place"
			sp["gain"] = "BUNDLE"
			sp["gcol"] = c_gold
		"sold_rare":
			sp["grid"] = false
			sp["token"] = "On sell"
			sp["gain"] = "RARE"
			sp["gcol"] = Color(D.RARITY_COLORS[2])
	return sp

func _mini_grid(r: Rect2, sp: Dictionary) -> void:
	var c := r.size.x / 3.0
	var cells: Array = sp["cells"]
	for k in 9:
		var cell := Rect2(r.position.x + (k % 3) * c + 1.0, r.position.y + (k / 3) * c + 1.0, c - 2.0, c - 2.0)
		var col := Color(1, 1, 1, 0.16)
		if k in cells:
			col = sp["gcol"]
		elif k == int(sp["self"]):
			col = Color.WHITE
		draw_rect(cell, col)

func _ability_badge(area: Rect2, a: Dictionary) -> void:
	if a.is_empty():
		return
	var sp := _badge_spec(a)
	var h := area.size.y
	var pad := h * 0.2
	var gw := h * 0.74 if bool(sp["grid"]) else 0.0
	var token := String(sp["token"])
	var gain := String(sp["gain"])
	var fs := maxi(10, int(h * 0.44))
	var total := 0.0
	while true:
		var tw := _text_w(token, fs, true) if token != "" else 0.0
		total = pad + (gw + pad * 0.7 if gw > 0.0 else 0.0) + (tw + pad * 0.7 if tw > 0.0 else 0.0) + _text_w(gain, fs, true) + h * 0.5 + pad * 0.6
		if total <= area.size.x or fs <= 9:
			break
		fs -= 1
	var r := Rect2(area.get_center().x - total * 0.5, area.position.y, total, h)
	_panel(r, Color(0.06, 0.07, 0.09, 0.88), int(h * 0.5), Color(1, 1, 1, 0.35), 1)
	var x := r.position.x + pad
	if gw > 0.0:
		_mini_grid(Rect2(x, r.position.y + (h - gw) * 0.5, gw, gw), sp)
		x += gw + pad * 0.7
	if token != "":
		_text(Vector2(x, r.get_center().y + _vc(font_bold, fs)), token, fs, Color.WHITE, true)
		x += _text_w(token, fs, true) + pad * 0.7
	var gcol: Color = sp["gcol"]
	var cr := Rect2(x, r.position.y + h * 0.14, _text_w(gain, fs, true) + h * 0.5, h * 0.72)
	_panel(cr, gcol, int(h * 0.36))
	_text_center(cr, gain, fs, _ink_on(gcol), true)
