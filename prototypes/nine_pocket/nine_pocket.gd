extends "res://prototypes/nine_pocket/nine_pocket_ui.gd"

const D := preload("res://prototypes/nine_pocket/nine_pocket_data.gd")

const DRAG_MIN := 24.0
const WELL_R := 138.0
const DISC_R := 124.0
const CELL := 270.0
const CELL_GAP := 18.0
const SPINE := 70.0
const WALLET_BORDER := 34.0
const STEP_TIME := 0.32
const SCORE_TIME := 0.5
const BINDER_SPREAD := 18

class Disc:
	var uid := 0
	var title := ""
	var band := ""
	var cover := ""
	var genre := 0
	var era := 0
	var label := 0
	var sound := 3
	var ability := ""
	var edition := ""

var rng := RandomNumberGenerator.new()
var albums: Array = []
var collection: Array[Disc] = []
var draw_pile: Array[int] = []
var discard: Array[int] = []
var wallet: Array[int] = []
var tray: Array[int] = []
var held := -1
var held_from := -1
var press_pos := Vector2.ZERO
var gig_n := 1
var cash := 0
var rack: Array = []
var shop_items: Array = []
var pack := {}
var pack_sel: Array[int] = []
var install_queue: Array = []
var install_price := 0
var install_src := -1
var reward := {}
var next_uid := 1
var binder_open := false
var binder_pick := -1
var services: Array = []
var bench := -1
var binder_page := 0
var digs := 0
var dig_mode := false
var dig_marks: Array[int] = []
var gig_score := 0
var target := 0
var plays := {}
var phase := "gig"
var playing := false
var result := {}
var steps: Array = []
var step_i := 0
var step_t := 0.0
var now_slot := -1
var readout: Array = []
var comp_flash: Array[float] = [0.0, 0.0, 0.0, 0.0]
var slot_flash: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
var spin := 0.0
var xfade_pos := 0.5
var set_total := 0
var set_sound := 0.0
var sort_key := ""
var live_energy := 1
var floats: Array = []
var message := ""
var message_t := 0.0
var hover_disc: Disc = null
var covers := {}
var textures := {}

var r_changer := Rect2(60.0, 40.0, 1780.0, 490.0)
var r_wallet := Rect2(60.0, 570.0, 1254.0, 722.0)
var r_side := Rect2(1350.0, 570.0, 490.0, 722.0)
var r_rack := Rect2(1880.0, 40.0, 620.0, 1360.0)
var r_display := Rect2(1912.0, 76.0, 556.0, 250.0)
var r_bin := Rect2(70.0, 200.0, 1000.0, 420.0)
var r_counter := Rect2(70.0, 690.0, 1000.0, 690.0)
var r_shelf := Rect2(1110.0, 180.0, 730.0, 1200.0)

func _ready() -> void:
	_ui_ready()
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	rng.randomize()
	_load_albums()
	_new_run()

func _process(delta: float) -> void:
	message_t = maxf(0.0, message_t - delta)
	for i in comp_flash.size():
		comp_flash[i] = maxf(0.0, comp_flash[i] - delta * 2.2)
	for i in D.SETLIST:
		slot_flash[i] = maxf(0.0, slot_flash[i] - delta * 3.0)
	for i in range(floats.size() - 1, -1, -1):
		var f: Dictionary = floats[i]
		f["life"] = float(f["life"]) - delta
		f["pos"] = Vector2(f["pos"]) + Vector2(0.0, -50.0 * delta)
		if float(f["life"]) <= 0.0:
			floats.remove_at(i)
	if playing:
		spin += delta * 5.0
		xfade_pos = lerpf(xfade_pos, 0.15 if now_slot % 2 == 0 else 0.85, minf(1.0, delta * 3.0))
		step_t -= delta
		if step_t <= 0.0:
			if step_i < steps.size():
				_play_step(steps[step_i])
				step_i += 1
				var nxt := String(steps[step_i]["src"]) if step_i < steps.size() else ""
				step_t = SCORE_TIME if nxt == "song" or nxt == "final" else STEP_TIME
			elif step_i == steps.size():
				step_i += 1
				step_t = 1.6
			else:
				_finish_set()
	_ui_process(delta)

func _unhandled_input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton:
		var mb := ev as InputEventMouseButton
		if binder_open and mb.pressed and (mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			_flip_binder(-1 if mb.button_index == MOUSE_BUTTON_WHEEL_UP else 1)
		elif mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			press_pos = _ui_mouse()
			_ui_click(press_pos)
		elif mb.button_index == MOUSE_BUTTON_LEFT and held >= 0 and press_pos.distance_to(_ui_mouse()) > DRAG_MIN:
			_ui_click(_ui_mouse())
		elif mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			_cancel()
	elif ev is InputEventKey and ev.pressed and not ev.echo:
		var key := (ev as InputEventKey).keycode
		if key == KEY_ESCAPE:
			_cancel()
		elif key == KEY_B:
			_toggle_binder()
		elif binder_open and key == KEY_LEFT:
			_flip_binder(-1)
		elif binder_open and key == KEY_RIGHT:
			_flip_binder(1)

func _cancel() -> void:
	if binder_open:
		binder_open = false
		binder_pick = -1
		return
	if bench >= 0:
		bench = -1
		return
	if not install_queue.is_empty():
		install_queue.pop_front()
		install_price = 0
		install_src = -1
	_return_held()
	dig_mode = false
	dig_marks.clear()

func _say(msg: String) -> void:
	message = msg
	message_t = 3.0

func _shuffle(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = arr[i]
		arr[i] = arr[j]
		arr[j] = t

func _load_albums() -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string(D.CATALOG))
	if not data is Array:
		push_error("Missing %s: run tools/make_covers.gd" % D.CATALOG)
		return
	for a in data:
		var g := D.GENRES.find(String(a["genre"]))
		if g < 0:
			continue
		var h := absi(String(a["band"]).hash())
		albums.append({"title": a["album"], "band": a["band"], "cover": a["cover"], "genre": g, "era": h % D.ERAS.size(), "label": (h / 7) % D.LABELS.size()})

func _cover_tex(path: String) -> Texture2D:
	if path == "":
		return null
	if not covers.has(path):
		var img := Image.load_from_file(ProjectSettings.globalize_path(path))
		if img:
			img.generate_mipmaps()
			covers[path] = ImageTexture.create_from_image(img)
		else:
			covers[path] = null
	return covers[path]

func _tex(name: String) -> Texture2D:
	if not textures.has(name):
		textures[name] = null
		for ext in ["png", "jpg", "jpeg", "webp"]:
			var path := ProjectSettings.globalize_path(D.TEXTURES + name + "." + ext)
			if FileAccess.file_exists(path):
				var img := Image.load_from_file(path)
				if img:
					img.generate_mipmaps()
					textures[name] = ImageTexture.create_from_image(img)
				break
	return textures[name]

func _make_disc(a: Dictionary) -> Disc:
	var d := Disc.new()
	d.uid = next_uid
	next_uid += 1
	d.title = a["title"]
	d.band = a["band"]
	d.cover = a["cover"]
	d.genre = a["genre"]
	d.era = a["era"]
	d.label = a["label"]
	d.sound = rng.randi_range(D.BASE_SOUND[0], D.BASE_SOUND[1])
	if rng.randf() < D.ABILITY_CHANCE:
		var abilities: Array = D.ABILITIES.keys()
		d.ability = abilities[rng.randi_range(0, abilities.size() - 1)]
		d.sound = maxi(D.BASE_SOUND[0], d.sound - 1)
	if rng.randf() < D.EDITION_CHANCE:
		var eds: Array = D.EDITIONS.keys()
		d.edition = eds[rng.randi_range(0, eds.size() - 1)]
	return d

func _fresh_albums(n: int, exclude: Array = []) -> Array:
	var owned := {}
	for d in collection:
		owned[d.cover] = true
	for c in exclude:
		owned[c] = true
	var pool: Array = albums.filter(func(a): return not owned.has(a["cover"]))
	_shuffle(pool)
	if pool.size() < n:
		var extra := albums.duplicate()
		_shuffle(extra)
		pool.append_array(extra)
	return pool.slice(0, n)

func _common(key: String, count: int) -> Array:
	var counts := {}
	for d in collection:
		var v: int = d.genre if key == "genre" else d.era
		counts[v] = int(counts.get(v, 0)) + 1
	var out: Array = counts.keys().filter(func(v): return int(counts[v]) >= count)
	return out if not out.is_empty() else counts.keys()

func _make_gear(id: String) -> Dictionary:
	var g := {"id": id, "level": 0}
	match id:
		"eq":
			var lv: Array = D.EQ_START.duplicate()
			_shuffle(lv)
			g["levels"] = lv
		"gain":
			var c := _common("genre", 3)
			g["genre"] = int(c[rng.randi_range(0, c.size() - 1)])
		"exciter":
			var c := _common("era", 3)
			g["era"] = int(c[rng.randi_range(0, c.size() - 1)])
	return g

func _gear_n(g: Dictionary) -> int:
	var ns: Array = D.GEAR[g["id"]]["n"]
	return int(ns[mini(int(g.get("level", 0)), ns.size() - 1)])

func _gear_text(g: Dictionary) -> String:
	var t := String(D.GEAR[g["id"]]["text"])
	return t % _gear_n(g) if t.contains("%d") else t

func _gear_max(g: Dictionary) -> int:
	return (D.GEAR[g["id"]]["n"] as Array).size() - 1

func _owned_gear() -> Array:
	var out: Array = []
	for g: Dictionary in rack:
		if not g.is_empty():
			out.append(g["id"])
	for g: Dictionary in install_queue:
		out.append(g["id"])
	return out

func _random_gear_ids(n: int, exclude: Array = []) -> Array:
	var owned := _owned_gear()
	var ids: Array = D.GEAR.keys().filter(func(id): return not id in owned and not id in exclude)
	_shuffle(ids)
	return ids.slice(0, n)

func _new_run() -> void:
	collection.clear()
	next_uid = 1
	for a in _fresh_albums(D.COLLECTION):
		collection.append(_make_disc(a))
	rack.clear()
	for k in D.RACK_SLOTS:
		rack.append({})
	for k in D.START_RACK.size():
		rack[k] = _make_gear(D.START_RACK[k])
	cash = D.START_CASH
	gig_n = 1
	plays = {}
	pack = {}
	install_queue.clear()
	_start_gig()

func _start_gig() -> void:
	target = D.TARGETS[gig_n - 1]
	draw_pile.clear()
	for i in collection.size():
		draw_pile.append(i)
	_shuffle(draw_pile)
	discard.clear()
	wallet.clear()
	for i in D.HAND:
		wallet.append(-1)
	tray.clear()
	for i in D.SETLIST:
		tray.append(-1)
	readout.clear()
	for i in D.SETLIST:
		readout.append({})
	held = -1
	digs = D.DIGS
	dig_mode = false
	dig_marks.clear()
	gig_score = 0
	set_total = 0
	set_sound = 0.0
	live_energy = 1
	phase = "gig"
	_refill()

func _refill() -> void:
	for p in wallet.size():
		if wallet[p] >= 0:
			continue
		if draw_pile.is_empty():
			draw_pile = discard.duplicate()
			discard.clear()
			_shuffle(draw_pile)
		if draw_pile.is_empty():
			break
		wallet[p] = draw_pile.pop_back()
	_apply_sort()

func _score(ids: Array, plays_in: Dictionary) -> Dictionary:
	var pl := plays_in.duplicate()
	var out: Array = []
	var energy := 1
	var pool := 0.0
	var cash_gain := 0
	var list: Array[Disc] = []
	for i in ids:
		list.append(collection[int(i)])
	for k in list.size():
		var d := list[k]
		var prev: Disc = list[k - 1] if k > 0 else null
		var next: Disc = list[k + 1] if k + 1 < list.size() else null
		var e0 := energy
		var c := {"sound": float(d.sound), "energy": energy, "drop": false}
		out.append(_st(k, "base", "", "sound", c["sound"], pool, energy, e0))
		for t in (2 if d.edition == "remaster" else 1):
			var fired := _ability(d, k, list, prev, next, pl, c)
			if fired != "":
				out.append(_st(k, "disc", fired, "energy" if fired.ends_with("Energy") else "sound", c["sound"], pool, c["energy"], e0))
		if d.edition != "":
			var ed: Dictionary = D.EDITIONS[d.edition]
			var en := int(ed["n"])
			var txt := ""
			match d.edition:
				"signed":
					c["sound"] = float(c["sound"]) + en
					txt = "+%d Signed" % en
				"limited":
					c["sound"] = float(c["sound"]) * en
					txt = "×%d Limited" % en
				"holo":
					c["energy"] = int(c["energy"]) + en
					txt = "+%d Energy" % en
				"mint":
					cash_gain += en
					txt = "+$%d" % en
			if txt != "":
				out.append(_st(k, "disc", txt, "cash" if d.edition == "mint" else String(ed["gain"]), c["sound"], pool, c["energy"], e0))
		var sound := float(c["sound"])
		energy = int(c["energy"])
		for ci in rack.size():
			var g: Dictionary = rack[ci]
			if g.is_empty():
				continue
			var n := _gear_n(g)
			var st := {}
			match String(g["id"]):
				"eq":
					var lv := int(g["levels"][d.genre])
					if lv != 0:
						sound = maxf(0.0, sound + lv)
						st = _st(k, "rack", "%+d" % lv, "sound", sound, pool, energy, e0)
				"xfade":
					if prev != null and (prev.genre == d.genre or prev.era == d.era):
						energy += n
						st = _st(k, "rack", "+%d Energy" % n, "energy", sound, pool, energy, e0)
				"gain":
					if d.genre == int(g["genre"]):
						sound *= n
						st = _st(k, "rack", "×%d" % n, "sound", sound, pool, energy, e0)
				"comp":
					sound += n
					st = _st(k, "rack", "+%d" % n, "sound", sound, pool, energy, e0)
				"exciter":
					if d.era == int(g["era"]):
						energy += n
						st = _st(k, "rack", "+%d Energy" % n, "energy", sound, pool, energy, e0)
				"tube":
					if d.ability == "":
						sound += n
						st = _st(k, "rack", "+%d" % n, "sound", sound, pool, energy, e0)
			if not st.is_empty():
				st["ci"] = ci
				out.append(st)
		if bool(c["drop"]):
			energy = maxi(1, energy - 1)
			out.append(_st(k, "disc", "−1 Energy", "energy", sound, pool, energy, e0))
		pool += sound
		out.append(_st(k, "song", "", "sound", sound, pool, energy, e0))
		var before := int(pl.get(d.uid, 0))
		for o in collection:
			if o.band == d.band and o.uid != d.uid:
				pl[o.uid] = 0
		pl[d.uid] = before + 1
	var total := int(round(pool * energy))
	out.append({"k": -1, "src": "final", "text": "%s × %d = %s" % [_num(pool), energy, _fmt_int(total)], "col": "score", "pool": pool, "energy": energy, "total": total})
	return {"total": total, "steps": out, "plays": pl, "cash": cash_gain}

func _ability(d: Disc, k: int, list: Array[Disc], prev: Disc, next: Disc, pl: Dictionary, c: Dictionary) -> String:
	match d.ability:
		"doubleshot":
			if prev != null and prev.era == d.era:
				c["sound"] = float(c["sound"]) * 2.0
				return "×2"
		"one_hit":
			var p := int(pl.get(d.uid, 0))
			if p > 0:
				c["sound"] = float(c["sound"]) * pow(1.1, p)
				return "×%s" % String.num(pow(1.1, p), 2)
		"opener":
			if k == 0:
				c["energy"] = int(c["energy"]) + 2
				return "+2 Energy"
		"closer":
			if k == list.size() - 1:
				c["sound"] = float(c["sound"]) * 2.0
				return "×2"
		"crowd":
			c["energy"] = int(c["energy"]) + 1
			return "+1 Energy"
		"segue":
			if next != null and next.genre == d.genre:
				c["sound"] = float(c["sound"]) + 4.0
				return "+4"
		"slow_jam":
			c["sound"] = float(c["sound"]) + 8.0
			c["drop"] = true
			return "+8"
		"deep_cut":
			if int(c["energy"]) <= 2:
				c["sound"] = float(c["sound"]) + 6.0
				return "+6"
		"bandmates":
			if list.any(func(o): return o != d and o.band == d.band):
				c["energy"] = int(c["energy"]) + 1
				return "+1 Energy"
	return ""

func _st(k: int, src: String, text: String, col: String, sound: float, pool: float, energy: int, e0: int) -> Dictionary:
	return {"k": k, "src": src, "text": text, "col": col, "sound": sound, "pool": pool, "energy": energy, "egain": energy - e0}

func _num(x: float) -> String:
	if is_equal_approx(x, roundf(x)):
		return str(int(roundf(x)))
	return String.num(x, 1)

func _fmt_int(n: int) -> String:
	var s := str(absi(n))
	var out := ""
	while s.length() > 3:
		out = "," + s.right(3) + out
		s = s.left(s.length() - 3)
	return ("-" if n < 0 else "") + s + out

func _setlist() -> Array:
	var ids: Array = []
	var slots: Array = []
	for s in tray.size():
		if tray[s] >= 0:
			ids.append(tray[s])
			slots.append(s)
	return [ids, slots]

func _play() -> void:
	_return_held()
	dig_mode = false
	dig_marks.clear()
	var sl := _setlist()
	if (sl[0] as Array).is_empty():
		_say("Load at least one album into the changer.")
		return
	result = _score(sl[0], plays)
	steps = result["steps"]
	var slots: Array = sl[1]
	for st: Dictionary in steps:
		st["slot"] = slots[int(st["k"])] if int(st["k"]) >= 0 else -1
	for i in D.SETLIST:
		readout[i] = {}
	step_i = 0
	step_t = 0.4
	set_total = 0
	set_sound = 0.0
	live_energy = 1
	now_slot = -1
	playing = true

func _play_step(st: Dictionary) -> void:
	if st["src"] == "final":
		now_slot = -1
		set_sound = float(st["pool"])
		live_energy = int(st["energy"])
		set_total = int(st["total"])
		_sfx("page_turn")
		floats.append({"slot": -1, "pos": Vector2(r_changer.get_center().x - 90.0, r_changer.get_center().y + 20.0), "text": String(st["text"]), "col": c_gold, "life": 1.8, "big": true})
		return
	var slot := int(st["slot"])
	if slot != now_slot:
		now_slot = slot
		slot_flash[slot] = 1.0
		_sfx("click")
	readout[slot] = {"sound": float(st["sound"]), "egain": int(st["egain"]), "done": st["src"] == "song"}
	set_sound = float(st["pool"])
	live_energy = int(st["energy"])
	set_total = int(round(set_sound * live_energy))
	if st["src"] == "rack":
		comp_flash[int(st["ci"])] = 1.0
	if st["src"] == "base" or st["src"] == "song":
		return
	var col := c_gold if st["col"] == "cash" else (Color(D.SOUND_COLOR).lightened(0.25) if st["col"] == "sound" else Color(D.ENERGY_COLOR).lightened(0.35))
	for f: Dictionary in floats:
		if int(f["slot"]) == slot:
			f["pos"] = Vector2(f["pos"]) + Vector2(0.0, -46.0)
	floats.append({"slot": slot, "pos": _well_center(slot) + Vector2(0.0, 20.0), "text": String(st["text"]), "col": col, "life": 1.1})

func _finish_set() -> void:
	playing = false
	now_slot = -1
	plays = result["plays"]
	gig_score = int(result["total"])
	for s in tray.size():
		tray[s] = -1
	for i in D.SETLIST:
		readout[i] = {}
	if gig_score < target:
		phase = "over"
		return
	var over := float(gig_score) / maxf(1.0, target) - 1.0
	var bonus := mini(D.BONUS_MAX, int(over / D.BONUS_STEP))
	var pay := D.REWARD_BASE + gig_n - 1
	var mint := int(result.get("cash", 0))
	reward = {"pay": pay, "bonus": bonus, "mint": mint}
	cash += pay + bonus + mint
	phase = "won" if gig_n >= D.GIGS else "result"

func _return_held() -> void:
	if held < 0:
		return
	var p := held_from if held_from >= 0 and wallet[held_from] < 0 else wallet.find(-1)
	wallet[p] = held
	held = -1

func _on_pocket(p: int) -> void:
	if dig_mode:
		if wallet[p] >= 0:
			if p in dig_marks:
				dig_marks.erase(p)
			elif dig_marks.size() < D.DIG_MAX:
				dig_marks.append(p)
		return
	if held >= 0:
		var occ := wallet[p]
		wallet[p] = held
		held = occ
		held_from = p
		_sfx("page_turn")
	elif wallet[p] >= 0:
		held = wallet[p]
		held_from = p
		wallet[p] = -1

func _on_slot(s: int) -> void:
	if held >= 0:
		var occ := tray[s]
		tray[s] = held
		held = occ
		slot_flash[s] = 1.0
		_sfx("page_turn")
	elif tray[s] >= 0:
		held = tray[s]
		held_from = -1
		tray[s] = -1

func _set_sort(k: String) -> void:
	sort_key = "" if sort_key == k else k
	_apply_sort()

func _apply_sort() -> void:
	if sort_key == "":
		return
	var ids: Array = wallet.filter(func(x): return x >= 0)
	ids.sort_custom(func(a, b): return _sort_less(collection[a], collection[b]))
	for p in wallet.size():
		wallet[p] = int(ids[p]) if p < ids.size() else -1

func _sort_vals(d: Disc) -> Array:
	match sort_key:
		"genre":
			return [d.genre, d.era, d.title]
		"era":
			return [d.era, d.genre, d.title]
		"sound":
			return [-d.sound, d.genre, d.title]
		"ability":
			var g := 2 if d.ability == "" else (0 if D.ABILITIES[d.ability]["gain"] == "sound" else 1)
			return [g, d.ability, d.title]
		"band":
			return [d.band, d.title, d.title]
	return [d.title, d.title, d.title]

func _sort_less(a: Disc, b: Disc) -> bool:
	var ka := _sort_vals(a)
	var kb := _sort_vals(b)
	for i in ka.size():
		if ka[i] != kb[i]:
			return ka[i] < kb[i]
	return false

func _start_dig() -> void:
	_return_held()
	dig_mode = true
	dig_marks.clear()

func _confirm_dig() -> void:
	for p in dig_marks:
		discard.append(wallet[p])
		wallet[p] = -1
	_refill()
	digs -= 1
	dig_mode = false
	dig_marks.clear()

func _well_center(s: int) -> Vector2:
	return Vector2(r_changer.position.x + 196.0 + s * 296.0, r_changer.position.y + 200.0)

func _pocket_rect(p: int) -> Rect2:
	var col := p % 4
	var row := p / 4
	var x := r_wallet.position.x + WALLET_BORDER + col * (CELL + CELL_GAP) + (SPINE - CELL_GAP if col >= 2 else 0.0)
	var y := r_wallet.position.y + WALLET_BORDER + row * (CELL + 48.0 + CELL_GAP)
	return Rect2(x, y, CELL, CELL)

func _draw() -> void:
	_begin_draw()
	var modal := phase in ["result", "over", "won"] or not pack.is_empty() or binder_open
	ui_live = not modal and not playing
	hover_disc = null
	if phase == "shop":
		_draw_shop()
	else:
		_draw_room()
		_register(Rect2(-800.0, -800.0, UI_W + 1600.0, UI_H + 1600.0), _return_held)
		_draw_changer()
		_draw_wallet()
		_draw_side()
	_draw_rack()
	_draw_floats()
	_draw_toast()
	_draw_held()
	ui_live = true
	if not pack.is_empty():
		_draw_pack()
	match phase:
		"result":
			_draw_result()
		"over":
			_draw_run_end(false)
		"won":
			_draw_run_end(true)
	if binder_open:
		_draw_binder_overlay()
	else:
		_draw_binder_button()
	if held < 0 and hover_disc != null:
		_draw_disc_tip(hover_disc)
	_end_draw()

func _uvs(pts: PackedVector2Array, tile: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(p / tile)
	return out

func _surface(r: Rect2, radius: float, mat: String, top: Color, bottom: Color, tile: float = 512.0) -> void:
	var tex := _tex(mat)
	if tex == null:
		_grad_panel(r, radius, top, bottom)
		return
	var pts := _round_points(r, radius)
	draw_colored_polygon(pts, top.lerp(bottom, 0.5).lightened(0.2), _uvs(pts, tile), tex)
	_grad_panel(r, radius, Color(1, 1, 1, 0.08), Color(0, 0, 0, 0.25))

func _brushed(r: Rect2, radius: float, base: Color, seed_n: int) -> void:
	if _tex("metal_brushed") != null:
		_surface(r, radius, "metal_brushed", base.lightened(0.1), base.darkened(0.1), 400.0)
	else:
		_grad_panel(r, radius, base.lightened(0.1), base.darkened(0.12))
		var g := RandomNumberGenerator.new()
		g.seed = seed_n
		var y := r.position.y + 3.0
		while y < r.end.y - 3.0:
			var a := g.randf_range(0.0, 0.07)
			draw_line(Vector2(r.position.x + radius * 0.3, y), Vector2(r.end.x - radius * 0.3, y), Color(1, 1, 1, a) if g.randf() < 0.55 else Color(0, 0, 0, a * 0.8), 1.0)
			y += g.randf_range(1.0, 3.0)
	draw_line(Vector2(r.position.x + radius, r.position.y + 1.0), Vector2(r.end.x - radius, r.position.y + 1.0), Color(1, 1, 1, 0.45), 2.0)
	draw_line(Vector2(r.position.x + radius, r.end.y - 1.0), Vector2(r.end.x - radius, r.end.y - 1.0), Color(0, 0, 0, 0.45), 2.0)
	_panel(r, Color(0, 0, 0, 0), int(radius), Color(0, 0, 0, 0.55), 1)

func _inset(r: Rect2, radius: float, col: Color) -> void:
	_panel(r, col, int(radius))
	_grad_panel(Rect2(r.position, Vector2(r.size.x, minf(r.size.y, 18.0))), radius, Color(0, 0, 0, 0.45), Color(0, 0, 0, 0.0))
	_panel(r, Color(0, 0, 0, 0), int(radius), Color(0, 0, 0, 0.7), 2)
	draw_line(Vector2(r.position.x + radius, r.end.y + 1.0), Vector2(r.end.x - radius, r.end.y + 1.0), Color(1, 1, 1, 0.18), 1.5)

func _screw(c: Vector2, rad: float) -> void:
	draw_circle(c + Vector2(0.0, 1.5), rad, Color(0, 0, 0, 0.4))
	draw_circle(c, rad, Color("7d838a"))
	draw_circle(c - Vector2(rad, rad) * 0.18, rad * 0.75, Color("c3c8ce"))
	draw_arc(c, rad, 0.0, TAU, 20, Color(0, 0, 0, 0.5), 1.0, true)
	var a := fmod(c.x * 0.37 + c.y * 0.11, PI)
	var d := Vector2.from_angle(a) * rad * 0.7
	draw_line(c - d, c + d, Color("3a3d42"), maxf(1.5, rad * 0.28))

func _led(c: Vector2, rad: float, col: Color, on: float) -> void:
	draw_circle(c, rad * 1.45, Color("111214"))
	draw_arc(c, rad * 1.45, 0.0, TAU, 20, Color(1, 1, 1, 0.12), 1.0, true)
	if on > 0.0:
		for k in 4:
			draw_circle(c, rad * (1.6 + k * 0.9), Color(col, 0.13 * on / (k + 1)))
	draw_circle(c, rad, col.darkened(0.78).lerp(col.lightened(0.2), on))
	draw_circle(c - Vector2(rad, rad) * 0.3, rad * 0.35, Color(1, 1, 1, 0.18 + 0.45 * on))

func _lcd(r: Rect2, text: String, col: Color, size: int, ghost: String = "") -> void:
	_panel(r.grow(5.0), Color("0a0b0d"), 9)
	_grad_panel(r, 6.0, col.darkened(0.9).lerp(Color("0d1210"), 0.4), Color("06080a"))
	var g := ghost if ghost != "" else "8".repeat(text.length())
	_text_right(r.end.x - 14.0, r.get_center().y + _vc(font_bold, size), g, size, Color(col, 0.04), true)
	_text_right(r.end.x - 14.0, r.get_center().y + _vc(font_bold, size), text, size, col, true)
	draw_colored_polygon(PackedVector2Array([r.position + Vector2(6, 4), r.position + Vector2(r.size.x * 0.45, 4), r.position + Vector2(r.size.x * 0.3, r.size.y * 0.5), r.position + Vector2(6, r.size.y * 0.5)]), Color(1, 1, 1, 0.04))

func _silk(pos: Vector2, s: String, size: int, col: Color = Color("d9dde2")) -> void:
	_text(pos, s, size, col, true)

func _knob(c: Vector2, rad: float, ang: float, cap: Color) -> void:
	draw_circle(c + Vector2(0.0, rad * 0.14), rad * 1.04, Color(0, 0, 0, 0.35))
	draw_circle(c + Vector2(0.0, rad * 0.06), rad * 1.0, Color(0, 0, 0, 0.3))
	draw_circle(c, rad, Color("1c1e22"))
	for i in 60:
		var d := Vector2.from_angle(TAU * i / 60.0)
		draw_line(c + d * rad * 0.8, c + d * rad * 0.98, Color(1, 1, 1, 0.1) if i % 2 == 0 else Color(0, 0, 0, 0.35), 2.0)
	draw_arc(c, rad - 1.0, PI * 1.1, PI * 1.9, 32, Color(1, 1, 1, 0.22), 2.0, true)
	var cr := rad * 0.74
	draw_circle(c, cr, cap)
	var g := RandomNumberGenerator.new()
	g.seed = int(c.x * 13.0 + c.y)
	var rr := cr * 0.08
	while rr < cr:
		draw_arc(c, rr, 0.0, TAU, 48, Color(1, 1, 1, g.randf_range(0.0, 0.07)) if g.randf() < 0.6 else Color(0, 0, 0, g.randf_range(0.0, 0.06)), 1.2, true)
		rr += g.randf_range(1.2, 2.6)
	draw_arc(c, cr * 0.6, -2.5, -1.7, 24, Color(1, 1, 1, 0.16), cr * 0.75, true)
	draw_arc(c, cr * 0.6, 0.65, 1.45, 24, Color(1, 1, 1, 0.09), cr * 0.75, true)
	draw_arc(c, cr, PI, TAU, 40, Color(1, 1, 1, 0.4), 2.0, true)
	draw_arc(c, cr, 0.0, PI, 40, Color(0, 0, 0, 0.45), 2.0, true)
	var pd := Vector2.from_angle(ang)
	draw_line(c + pd * cr * 0.3, c + pd * cr * 0.92, Color("b03a2e"), maxf(3.0, rad * 0.08))

func _fader_cap(r: Rect2, col: Color, lit: float) -> void:
	_panel(Rect2(r.position + Vector2(0.0, 5.0), r.size), Color(0, 0, 0, 0.45), 4)
	_grad_panel(r, 4.0, col.lightened(0.3), col.darkened(0.35))
	var mid := r.get_center()
	if r.size.x > r.size.y:
		draw_line(Vector2(r.position.x + 5.0, mid.y - 1.0), Vector2(r.end.x - 5.0, mid.y - 1.0), Color(0, 0, 0, 0.6), 2.0)
		draw_line(Vector2(r.position.x + 5.0, mid.y + 1.0), Vector2(r.end.x - 5.0, mid.y + 1.0), Color(1, 1, 1, 0.35), 1.0)
	else:
		draw_line(Vector2(mid.x - 1.0, r.position.y + 5.0), Vector2(mid.x - 1.0, r.end.y - 5.0), Color(0, 0, 0, 0.6), 2.0)
		draw_line(Vector2(mid.x + 1.0, r.position.y + 5.0), Vector2(mid.x + 1.0, r.end.y - 5.0), Color(1, 1, 1, 0.35), 1.0)
	draw_line(r.position + Vector2(3.0, 1.0), Vector2(r.end.x - 3.0, r.position.y + 1.0), Color(1, 1, 1, 0.5), 1.5)
	if lit > 0.0:
		_panel(r.grow(3.0), Color(0, 0, 0, 0), 6, Color(Color(D.SOUND_COLOR).lightened(0.3), lit), 3)
	_panel(r, Color(0, 0, 0, 0), 4, Color(0, 0, 0, 0.6), 1)

func _hw_button(r: Rect2, label: String, cb: Callable, enabled: bool, col: Color, size: int = T_LG) -> void:
	var hovered := enabled and ui_live and r.has_point(mouse)
	var down := 3.0 if hovered and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) else 0.0
	_panel(Rect2(r.position + Vector2(-4.0, -4.0), r.size + Vector2(8.0, 12.0)), Color("0d0e10"), 12)
	var body := Rect2(r.position + Vector2(0.0, down), r.size)
	_panel(Rect2(body.position + Vector2(0.0, 6.0 - down), body.size), col.darkened(0.6), 9)
	var c := col if enabled else col.lerp(Color("5a5d63"), 0.75)
	_grad_panel(body, 9.0, c.lightened(0.28 if hovered else 0.18), c.darkened(0.22))
	draw_line(body.position + Vector2(9.0, 2.0), Vector2(body.end.x - 9.0, body.position.y + 2.0), Color(1, 1, 1, 0.5 if enabled else 0.15), 2.0)
	_panel(body, Color(0, 0, 0, 0), 9, Color(0, 0, 0, 0.55), 1)
	var ink := Color.WHITE if c.get_luminance() < 0.55 else Color("1e2633")
	_text_center(body, label, size, Color(ink, 1.0 if enabled else 0.45), true)
	if enabled:
		_register(r, cb)

func _draw_room() -> void:
	draw_rect(Rect2(-800, -800, UI_W + 1600, UI_H + 1600), Color("2f2b28"))
	var x := -40.0
	while x < UI_W:
		draw_line(Vector2(x, -800.0), Vector2(x, UI_H + 800.0), Color(0, 0, 0, 0.1), 3.0)
		x += 120.0
	var desk := Rect2(-800.0, r_changer.end.y + 6.0, r_rack.position.x + 790.0, UI_H + 800.0)
	_surface(desk, 0.0, "wood", Color("6b4a32"), Color("4a3222"), 700.0)
	if _tex("wood") == null:
		_grain(Rect2(0.0, desk.position.y, r_rack.position.x - 20.0, UI_H - desk.position.y), 7, 900.0)
	draw_rect(Rect2(desk.position, Vector2(desk.size.x, 6.0)), Color("8a6446"))
	draw_rect(Rect2(desk.position + Vector2(0.0, 6.0), Vector2(desk.size.x, 14.0)), Color(0, 0, 0, 0.18))

func _draw_changer() -> void:
	var r := r_changer
	_shadow(r, 16, 12.0)
	_surface(r, 16.0, "metal_dark", Color("2b2e33"), Color("1a1c20"))
	draw_line(r.position + Vector2(16.0, 2.0), Vector2(r.end.x - 16.0, r.position.y + 2.0), Color(1, 1, 1, 0.25), 2.0)
	_panel(r, Color(0, 0, 0, 0), 16, Color(0, 0, 0, 0.6), 2)
	for p in [r.position + Vector2(22, 22), Vector2(r.end.x - 22, r.position.y + 22), Vector2(r.position.x + 22, r.end.y - 22), r.end - Vector2(22, 22)]:
		_screw(p, 7.0)
	var tray_r := Rect2(r.position.x + 44.0, r.position.y + 30.0, 1500.0 - 12.0, r.size.y - 60.0)
	_inset(tray_r, 14.0, Color("141518"))
	for s in D.SETLIST:
		_draw_well(s)
	var panel := Rect2(tray_r.end.x + 24.0, tray_r.position.y, r.end.x - tray_r.end.x - 52.0, tray_r.size.y)
	_brushed(panel, 10.0, Color("aab0b7"), 31)
	_text_center(Rect2(panel.position.x, panel.position.y + 10.0, panel.size.x, 34.0), "DISC ENGINE", T_SM, Color("2b2e33"), true)
	_text_center(Rect2(panel.position.x, panel.position.y + 38.0, panel.size.x, 24.0), "COMPACT DISC CHANGER", 13, Color("4c5058"), true)
	var tr_text := "--" if now_slot < 0 else "%02d" % (now_slot + 1)
	_lcd(Rect2(panel.position.x + 20.0, panel.position.y + 86.0, panel.size.x - 40.0, 66.0), tr_text, Color("7fe0a0"), T_XL, "88")
	_silk(Vector2(panel.position.x + 26.0, panel.position.y + 176.0), "TRACK", 13, Color("2b2e33"))
	_text_right(panel.end.x - 24.0, panel.position.y + 176.0, "GIG %d/%d" % [gig_n, D.GIGS], 13, Color("2b2e33"), true)
	_led(Vector2(panel.get_center().x, panel.position.y + 220.0), 7.0, Color("7fe0a0"), 1.0 if playing else 0.15)
	var pr := Rect2(panel.position.x + 20.0, panel.end.y - 150.0, panel.size.x - 40.0, 120.0)
	var loaded := tray.any(func(t): return t >= 0)
	_hw_button(pr, "PLAY" if not playing else "PLAYING", _play, ui_live and loaded, Color("3f9b5a"), T_XL if not playing else T_MD)

func _draw_well(s: int) -> void:
	var c := _well_center(s)
	draw_circle(c, WELL_R + 8.0, Color(1, 1, 1, 0.05))
	draw_circle(c, WELL_R + 2.0, Color("0b0c0e"))
	var rub := _tex("rubber")
	if rub != null:
		var pts := PackedVector2Array()
		for i in 64:
			pts.append(c + Vector2.from_angle(TAU * i / 64.0) * WELL_R)
		draw_colored_polygon(pts, Color("3a3d42"), _uvs(pts, 300.0), rub)
	else:
		draw_circle(c, WELL_R, Color("1d1f23"))
		for k in 6:
			draw_arc(c, WELL_R * (0.3 + k * 0.12), 0.0, TAU, 64, Color(1, 1, 1, 0.025), 2.0, true)
	draw_arc(c, WELL_R - 4.0, PI * 1.05, PI * 1.95, 48, Color(0, 0, 0, 0.6), 8.0, true)
	draw_arc(c, WELL_R, PI * 0.1, PI * 0.9, 48, Color(1, 1, 1, 0.14), 2.0, true)
	draw_circle(c, 22.0, Color("2a2c31"))
	draw_circle(c, 14.0, Color("8d939a"))
	draw_circle(c - Vector2(3, 3), 7.0, Color("c3c8ce"))
	var num_r := Rect2(c.x - 40.0, c.y - WELL_R - 38.0, 50.0, 30.0)
	_text_center(num_r, str(s + 1), T_SM, Color("8d939b"), true)
	_led(Vector2(c.x + 24.0, c.y - WELL_R - 23.0), 5.0, Color("7fe0a0"), 1.0 if now_slot == s else slot_flash[s] * 0.6)
	var pocket := Rect2(c - Vector2(WELL_R, WELL_R), Vector2(WELL_R, WELL_R) * 2.0)
	var over := ui_live and held >= 0 and pocket.has_point(mouse)
	if over:
		draw_arc(c, WELL_R + 6.0, 0.0, TAU, 64, c_gold, 4.0, true)
	var i := tray[s]
	if i >= 0:
		var d := collection[i]
		_cd_art(c, DISC_R, _cover_tex(d.cover), spin if now_slot == s else 0.0)
		_disc_marks(c, DISC_R, d)
		if playing and now_slot != s and not readout[s].is_empty():
			draw_circle(c, DISC_R, Color(0, 0, 0, 0.35))
		_tip_disc(pocket, d)
	if slot_flash[s] > 0.0:
		draw_arc(c, DISC_R + 4.0, 0.0, TAU, 64, Color(c_gold, slot_flash[s]), 5.0, true)
	if i >= 0:
		_chip_row(Rect2(c.x - 130.0, c.y + WELL_R + 6.0, 260.0, 32.0), collection[i])
	var ro: Dictionary = readout[s]
	var lr := Rect2(c.x - 130.0, c.y + WELL_R + 46.0, 260.0, 42.0)
	_panel(lr.grow(4.0), Color("0a0b0d"), 8)
	_grad_panel(lr, 6.0, Color("0d1210"), Color("06080a"))
	if ro.is_empty():
		_text_center(lr, "- - -", T_SM, Color(1, 1, 1, 0.08), true)
	else:
		var a := 1.0 if bool(ro["done"]) else 0.55
		var sc := Color(Color(D.SOUND_COLOR).lightened(0.3), a)
		var ec := Color(Color(D.ENERGY_COLOR).lightened(0.45), a)
		var y := lr.get_center().y + _vc(font_bold, T_SM)
		_text(Vector2(lr.position.x + 12.0, y), "+%s SOUND" % _num(float(ro["sound"])), T_SM, sc, true)
		var eg := int(ro["egain"])
		if eg != 0:
			_text_right(lr.end.x - 12.0, y, "%+d ENERGY" % eg, T_SM, ec, true)
	if ui_live and not dig_mode:
		_register(pocket, _on_slot.bind(s))

func _disc_marks(c: Vector2, rad: float, d: Disc) -> void:
	var sc := Color(D.SOUND_COLOR)
	var tc := c + Vector2(-rad * 0.72, -rad * 0.72)
	draw_circle(tc + Vector2(0, 3), rad * 0.2, Color(0, 0, 0, 0.4))
	draw_circle(tc, rad * 0.2, sc.darkened(0.15))
	draw_arc(tc, rad * 0.2, 0.0, TAU, 32, Color(1, 1, 1, 0.75), 2.0, true)
	_heavy_center(Rect2(tc - Vector2(rad, rad) * 0.2, Vector2(rad, rad) * 0.4), str(d.sound), int(rad * 0.24), Color.WHITE)
	if d.edition != "":
		_edition_marks(c, rad, d.edition)
	if d.ability == "":
		return
	var a: Dictionary = D.ABILITIES[d.ability]
	var name := String(a["name"])
	var chip := String(a["chip"])
	var gc := Color(D.SOUND_COLOR if a["gain"] == "sound" else D.ENERGY_COLOR)
	var fs := int(rad * 0.15)
	var h := rad * 0.27
	var cw := _text_w(chip, fs, true) + h * 0.6
	var w := _text_w(name, fs, true) + cw + h * 0.9
	var pr := Rect2(c.x - w * 0.5, c.y + rad * 0.5, w, h)
	_panel(pr, Color(0.06, 0.07, 0.09, 0.9), int(h * 0.5), Color(1, 1, 1, 0.35), 1)
	_text(Vector2(pr.position.x + h * 0.4, pr.get_center().y + _vc(font_bold, fs)), name, fs, Color.WHITE, true)
	var cr := Rect2(pr.end.x - cw - h * 0.14, pr.position.y + h * 0.13, cw, h * 0.74)
	_panel(cr, gc, int(h * 0.37))
	_text_center(cr, chip, fs, Color.WHITE, true)

func _draw_wallet() -> void:
	var b := r_wallet
	_shadow(b, 22, 12.0)
	_surface(b, 22.0, "leather", C_LEATHER.lightened(0.1), C_LEATHER.darkened(0.15), 600.0)
	if _tex("leather") == null:
		_grain(b, 19, 260.0)
	_stitch_rect(b.grow(-12.0), Color("aab3bf", 0.45))
	var spine_x := _pocket_rect(1).end.x + (SPINE - CELL_GAP) * 0.5 + CELL_GAP * 0.5
	var spine := Rect2(spine_x - SPINE * 0.5 + 8.0, b.position.y + 18.0, SPINE - 16.0, b.size.y - 36.0)
	_grad_panel(spine, 8.0, Color("23262b"), Color("15171a"))
	draw_line(Vector2(spine.get_center().x, spine.position.y + 10.0), Vector2(spine.get_center().x, spine.end.y - 10.0), Color(0, 0, 0, 0.5), 3.0)
	for side in [-1.0, 1.0]:
		var px: float = spine_x + side * (SPINE * 0.5 + 2.0)
		var pg := Rect2(px if side > 0 else b.position.x + WALLET_BORDER - 16.0, b.position.y + WALLET_BORDER - 14.0, (b.end.x - WALLET_BORDER + 16.0 - px) if side > 0 else (px - b.position.x - WALLET_BORDER + 16.0), b.size.y - 2.0 * WALLET_BORDER + 28.0)
		_surface(pg, 8.0, "fabric", Color("2a2d33"), Color("1f2227"), 300.0)
	_text_center(Rect2(b.position.x, b.position.y + 2.0, b.size.x * 0.5, 30.0), "CD WALLET", T_XS, Color("c9ced6"), true)
	var left := draw_pile.size() + discard.size()
	_text_center(Rect2(b.position.x + b.size.x * 0.5, b.position.y + 2.0, b.size.x * 0.5, 30.0), "%d MORE IN YOUR BINDER" % left, T_XS, Color("c9ced6"), true)
	for p in D.HAND:
		var r := _pocket_rect(p)
		var pocket := Rect2(r.position - Vector2(6.0, 6.0), Vector2(r.size.x + 12.0, r.size.y + 54.0))
		var over := ui_live and held >= 0 and pocket.has_point(mouse)
		_panel(pocket, Color(1, 1, 1, 0.07 if over else 0.03), 8, Color(c_gold, 0.8) if over else Color(1, 1, 1, 0.13), 3 if over else 2)
		_pocket_lip(pocket)
		var i := wallet[p]
		if i >= 0:
			var d := collection[i]
			_cd_art(r.get_center(), r.size.x * 0.5 - 8.0, _cover_tex(d.cover))
			_disc_marks(r.get_center(), r.size.x * 0.5 - 8.0, d)
			_chip_row(Rect2(r.position.x, r.end.y + 6.0, r.size.x, 34.0), d)
			_tip_disc(pocket, d)
			if dig_mode and p in dig_marks:
				draw_circle(r.get_center(), r.size.x * 0.5 - 8.0, Color(0, 0, 0, 0.55))
				_heavy_center(r, "DIG", T_XL, c_gold)
				draw_arc(r.get_center(), r.size.x * 0.5 - 4.0, 0.0, TAU, 64, c_gold, 5.0, true)
			elif dig_mode:
				draw_arc(r.get_center(), r.size.x * 0.5 - 4.0, 0.0, TAU, 64, Color(c_gold, 0.35 + 0.2 * sin(clock * 5.0)), 3.0, true)
		_sleeve_gloss(r)
		if ui_live:
			_register(pocket, _on_pocket.bind(p))

func _chip_row(r: Rect2, d: Disc) -> void:
	var chips := [[D.GENRES[d.genre].to_upper(), Color(D.GENRE_COLORS[d.genre]), Color.WHITE], [D.ERAS[d.era], Color("fbfaf5"), c_ink]]
	var fs := T_XS
	var total := -6.0
	for c in chips:
		total += _text_w(String(c[0]), fs, true) + 22.0
	var x := r.get_center().x - total * 0.5
	for ci in chips.size():
		var c: Array = chips[ci]
		var w := _text_w(String(c[0]), fs, true) + 16.0
		var cr := Rect2(x, r.position.y + 2.0, w, r.size.y - 4.0)
		var bo := _boosts("genre", d.genre) if ci == 0 else _boosts("era", d.era)
		if bo != 0:
			_panel(cr.grow(3.0), Color(0, 0, 0, 0), 12, c_gold if bo > 0 else c_bad, 3)
		_panel(cr, c[1], 10, Color(0, 0, 0, 0.25), 1)
		_text_center(cr, String(c[0]), fs, c[2], true)
		x += w + 6.0

func _boosts(key: String, v: int) -> int:
	var best := 0
	for g: Dictionary in rack:
		if g.is_empty():
			continue
		if key == "genre" and g["id"] == "eq":
			var lv := int(g["levels"][v])
			if lv < 0:
				return -1
			if lv > 0:
				best = 1
		if key == "genre" and g["id"] == "gain" and int(g["genre"]) == v:
			best = 1
		if key == "era" and g["id"] == "exciter" and int(g["era"]) == v:
			best = 1
	return best

func _draw_side() -> void:
	var r := r_side
	_shadow(r, 12, 10.0)
	_brushed(r, 12.0, Color("aab0b7"), 77)
	for p in [r.position + Vector2(20, 20), Vector2(r.end.x - 20, r.position.y + 20), Vector2(r.position.x + 20, r.end.y - 20), r.end - Vector2(20, 20)]:
		_screw(p, 7.0)
	var x := r.position.x + 36.0
	var w := r.size.x - 72.0
	_silk(Vector2(x, r.position.y + 64.0), "SORT WALLET", T_MD, Color("23262b"))
	var keys: Array = D.SORT_KEYS
	var bw := (w - 16.0) / 2.0
	for k in keys.size():
		var key := String(keys[k])
		var br := Rect2(x + (k % 2) * (bw + 16.0), r.position.y + 90.0 + (k / 2) * 84.0, bw, 64.0)
		var on := sort_key == key
		_hw_button(br, String(D.SORT_TEXT[key]), _set_sort.bind(key), ui_live and not dig_mode, Color("3f9b5a") if on else Color("3d4148"), T_MD)
		_led(Vector2(br.end.x - 18.0, br.position.y + 16.0), 4.0, Color("7fe0a0"), 1.0 if on else 0.0)
	var dy := r.position.y + 90.0 + ((keys.size() + 1) / 2) * 84.0 + 10.0
	draw_line(Vector2(x, dy), Vector2(x + w, dy), Color(0, 0, 0, 0.35), 2.0)
	draw_line(Vector2(x, dy + 2.0), Vector2(x + w, dy + 2.0), Color(1, 1, 1, 0.4), 1.0)
	_silk(Vector2(x, dy + 52.0), "DIG", T_MD, Color("23262b"))
	for k in D.DIGS:
		_led(Vector2(x + w - 10.0 - (D.DIGS - 1 - k) * 30.0, dy + 44.0), 7.0, Color("ffb347"), 1.0 if k < digs else 0.0)
	var left := draw_pile.size() + discard.size()
	var help := "Pick up to %d albums to swap for new ones." % D.DIG_MAX if dig_mode else "Swap up to %d wallet albums for new ones from your binder (%d left)." % [D.DIG_MAX, left]
	_wrap(Vector2(x, dy + 70.0), help, w, T_SM, Color("2b2e33"))
	var by := r.end.y - 116.0
	if dig_mode:
		var n := dig_marks.size()
		_hw_button(Rect2(x, by, w * 0.55, 76.0), "Dig %d" % n if n > 0 else "Dig", _confirm_dig, n > 0, Color("c9a227"), T_LG)
		_hw_button(Rect2(x + w * 0.6, by, w * 0.4, 76.0), "Cancel", _cancel, true, Color("8a8f98"), T_MD)
	else:
		_hw_button(Rect2(x, by, w, 76.0), "Dig through the binder", _start_dig, digs > 0 and ui_live, Color("c9a227"), T_LG)

func _rack_unit(r: Rect2, title: String, sub: String, seed_n: int, flash: float) -> void:
	_shadow(r, 6, 6.0)
	_brushed(r, 6.0, Color("b4b9bf"), seed_n)
	for ex in [r.position.x + 18.0, r.end.x - 18.0]:
		for ey in [r.position.y + 24.0, r.end.y - 24.0]:
			_screw(Vector2(ex, ey), 7.0)
	_silk(Vector2(r.position.x + 44.0, r.position.y + 44.0), title.to_upper(), T_MD, Color("23262b"))
	_wrap(Vector2(r.position.x + 44.0, r.position.y + 58.0), sub, 226.0, 17, Color("3d4148"))
	_led(Vector2(r.position.x + 54.0, r.end.y - 34.0), 7.0, Color("ffb347"), flash)
	_silk(Vector2(r.position.x + 72.0, r.end.y - 28.0), "ACTIVE", 12, Color("3d4148"))

func _bay_rect(k: int) -> Rect2:
	return Rect2(1912.0, 346.0 + k * 256.0, 556.0, 236.0)

func _draw_rack() -> void:
	var r := r_rack
	_shadow(r, 10, 14.0)
	_surface(r, 10.0, "metal_dark", Color("1d1f23"), Color("121316"))
	for rx in [r.position.x + 12.0, r.end.x - 26.0]:
		draw_rect(Rect2(rx, r.position.y + 14.0, 14.0, r.size.y - 28.0), Color("2a2d32"))
		var yy := r.position.y + 30.0
		while yy < r.end.y - 20.0:
			draw_rect(Rect2(rx + 4.0, yy, 6.0, 6.0), Color("0b0c0e"))
			yy += 30.0
	_draw_display(r_display)
	var installing := phase == "shop" and not install_queue.is_empty() and ui_live
	for k in rack.size():
		var br := _bay_rect(k)
		var g: Dictionary = rack[k]
		if g.is_empty():
			_draw_empty_bay(br)
		else:
			_draw_gear(br, g, comp_flash[k], k)
		var bk := _bench_kind()
		if bk != "" and ui_live and phase == "shop" and not g.is_empty():
			var ok: bool = (bk == "upgrade" and g["id"] != "eq" and int(g.get("level", 0)) < _gear_max(g)) or (bk == "tweak" and g["id"] in ["eq", "gain", "exciter"])
			_panel(br.grow(6.0), Color(0, 0, 0, 0), 10, Color(c_gold, 0.45 + 0.25 * sin(clock * 5.0)) if ok else Color(0, 0, 0, 0), 3)
			if not ok:
				_panel(br, Color(0, 0, 0, 0.45), 6)
			elif bk == "upgrade":
				if br.has_point(mouse):
					var nxt := int(g.get("level", 0)) + 1
					var lab := "Upgrade to %s" % D.LEVEL_NAMES[nxt]
					var lw := _text_w(lab, T_MD, true) + 40.0
					var lr := Rect2(br.get_center().x - lw * 0.5, br.get_center().y - 28.0, lw, 56.0)
					_panel(lr, Color(0.06, 0.07, 0.09, 0.92), 28)
					_text_center(lr, lab, T_MD, c_gold, true)
				_register(br, _bench_apply.bind(k, -1))
		if installing:
			var hot := br.has_point(mouse)
			_panel(br.grow(6.0), Color(c_gold, 0.12 if hot else 0.0), 10, Color(c_gold, 0.95 if hot else 0.45 + 0.25 * sin(clock * 5.0)), 5 if hot else 3)
			if hot:
				var label := "Install here" if g.is_empty() else "Replace %s" % D.GEAR[g["id"]]["name"]
				var lw := _text_w(label, T_MD, true) + 40.0
				var lr := Rect2(br.get_center().x - lw * 0.5, br.get_center().y - 28.0, lw, 56.0)
				_panel(lr, Color(0.06, 0.07, 0.09, 0.92), 28)
				_text_center(lr, label, T_MD, c_gold, true)
			_register(br, _install.bind(k))

func _draw_display(r: Rect2) -> void:
	_shadow(r, 6, 6.0)
	_surface(r, 6.0, "metal_dark", Color("2c2f34"), Color("1e2024"))
	_panel(r, Color(0, 0, 0, 0), 6, Color(0, 0, 0, 0.6), 1)
	draw_line(r.position + Vector2(6.0, 1.0), Vector2(r.end.x - 6.0, r.position.y + 1.0), Color(1, 1, 1, 0.2), 2.0)
	for ex in [r.position.x + 18.0, r.end.x - 18.0]:
		for ey in [r.position.y + 24.0, r.end.y - 24.0]:
			_screw(Vector2(ex, ey), 7.0)
	var x := r.position.x + 44.0
	var w := r.size.x - 88.0
	var cw := (w - 40.0) / 3.0
	var sc := Color(D.SOUND_COLOR).lightened(0.3)
	var ec := Color(D.ENERGY_COLOR).lightened(0.45)
	var cols := [["SOUND", _num(set_sound) if playing else "0", sc, "8888"], ["ENERGY", str(live_energy if playing else 1), ec, "88"], ["SET", _fmt_int(set_total) if playing else "0", c_gold, "88,888"]]
	for k in 3:
		var lx := x + k * (cw + 20.0)
		_silk(Vector2(lx, r.position.y + 40.0), String(cols[k][0]), 14, Color("8d939b"))
		_lcd(Rect2(lx, r.position.y + 52.0, cw, 64.0), String(cols[k][1]), cols[k][2], T_LG, String(cols[k][3]))
		if k < 2:
			_text_center(Rect2(lx + cw, r.position.y + 52.0, 20.0, 64.0), "×" if k == 0 else "=", T_MD, Color("8d939b"), true)
	var meter := Rect2(x, r.position.y + 140.0, w, 56.0)
	_inset(meter, 6.0, Color("0b0c0e"))
	var now := gig_score + (set_total if playing else 0)
	var frac := clampf(float(now) / maxf(1.0, target), 0.0, 1.0)
	var bars := 28
	var bw := (meter.size.x - 24.0) / bars
	for k in bars:
		var on := float(k) / bars < frac
		var col := Color("7fe0a0") if k < bars * 0.7 else (Color("f2c14e") if k < bars * 0.9 else Color("ff6b5a"))
		var br := Rect2(meter.position.x + 12.0 + k * bw, meter.position.y + 12.0, bw - 4.0, meter.size.y - 24.0)
		_panel(br, col if on else Color(col, 0.08), 2)
	_silk(Vector2(x, r.end.y - 18.0), "CROWD", T_SM, Color("8d939b"))
	_text_right(x + w, r.end.y - 18.0, "%s / %s" % [_fmt_int(now), _fmt_int(target)], T_SM, Color("e6e9ed"), true)

func _draw_empty_bay(r: Rect2) -> void:
	_shadow(r, 6, 4.0)
	_surface(r, 6.0, "metal_dark", Color("26292e"), Color("1a1c20"))
	_panel(r, Color(0, 0, 0, 0), 6, Color(0, 0, 0, 0.6), 1)
	for ex in [r.position.x + 18.0, r.end.x - 18.0]:
		for ey in [r.position.y + 24.0, r.end.y - 24.0]:
			_screw(Vector2(ex, ey), 7.0)
	for row in 3:
		for col in 6:
			var v := Rect2(r.position.x + 80.0 + col * 68.0, r.position.y + 70.0 + row * 36.0, 52.0, 12.0)
			_inset(v, 6.0, Color("0b0c0e"))
	_text_center(Rect2(r.position.x, r.end.y - 58.0, r.size.x, 30.0), "EMPTY BAY", T_SM, Color("6f747c"), true)

func _draw_gear(r: Rect2, g: Dictionary, flash: float, bay: int = -1) -> void:
	var def: Dictionary = D.GEAR[g["id"]]
	_rack_unit(r, String(def["name"]), _gear_text(g), int(r.position.y) + 41, flash)
	var lvl := int(g.get("level", 0))
	if lvl > 0:
		var tag := String(D.LEVEL_NAMES[lvl])
		var tx := r.position.x + 52.0 + _text_w(String(def["name"]).to_upper(), T_MD, true)
		var tr := Rect2(tx, r.position.y + 22.0, _text_w(tag, 13, true) + 16.0, 26.0)
		_panel(tr, Color("23262b"), 4)
		_text_center(tr, tag, 13, c_gold, true)
	var ctl := Rect2(r.position.x + 290.0, r.position.y + 20.0, r.size.x - 330.0, r.size.y - 40.0)
	var tweak := bay >= 0 and _bench_kind() == "tweak"
	match String(def["look"]):
		"faders":
			_ctl_faders(ctl, g["levels"], flash, bay if tweak else -1)
		"xfader":
			_ctl_xfader(ctl, flash)
		"genre_knob":
			_ctl_dial(ctl, D.GENRE_SHORT, int(g["genre"]), flash, bay if tweak else -1)
		"era_knob":
			_ctl_dial(ctl, D.ERAS, int(g["era"]), flash, bay if tweak else -1)
		"knobs":
			_ctl_knobs(ctl, flash)
		"tube":
			_ctl_tube(ctl, flash)

func _playing_disc() -> Disc:
	if now_slot >= 0 and tray[now_slot] >= 0:
		return collection[tray[now_slot]]
	return null

func _ctl_faders(ctl: Rect2, levels: Array, flash: float, bay: int = -1) -> void:
	var n := D.GENRES.size()
	var cw := ctl.size.x / n
	var cur := _playing_disc()
	for gi in n:
		var cx := ctl.position.x + cw * (gi + 0.5)
		var lv := int(levels[gi])
		var track := Rect2(cx - 4.0, ctl.position.y + 26.0, 8.0, ctl.size.y - 66.0)
		for t in D.EQ_MAX - D.EQ_MIN + 1:
			var ty := track.end.y - track.size.y * t / float(D.EQ_MAX - D.EQ_MIN)
			var zero := t == -D.EQ_MIN
			draw_line(Vector2(cx - (17.0 if zero else 15.0), ty), Vector2(cx - 9.0, ty), Color(0, 0, 0, 0.7 if zero else 0.4), 2.0 if zero else 1.5)
		_inset(track, 4.0, Color("0b0c0e"))
		var v := float(lv - D.EQ_MIN) / float(D.EQ_MAX - D.EQ_MIN)
		var cap := Rect2(cx - 13.0, track.end.y - track.size.y * v - 9.0, 26.0, 18.0)
		var hit := flash > 0.0 and cur != null and cur.genre == gi
		var cc := Color("2b2e33")
		if lv > 0:
			cc = Color(D.SOUND_COLOR).darkened(0.25)
		elif lv < 0:
			cc = c_bad.darkened(0.2)
		_fader_cap(cap, cc, flash if hit else 0.0)
		if lv != 0:
			_text_center(cap, "%+d" % lv, 11, Color.WHITE, true)
		var lc := Color(D.SOUND_COLOR).lightened(0.2) if lv > 0 else c_bad.lightened(0.2)
		_led(Vector2(cx, ctl.position.y + 10.0), 4.0, lc, 0.0 if lv == 0 else 1.0)
		_text_center(Rect2(cx - cw, ctl.end.y - 30.0 + (gi % 2) * 16.0, cw * 2.0, 18.0), D.GENRE_SHORT[gi], 11, Color("23262b") if lv != 0 else Color("6a6f77"), true)
		if bay >= 0 and lv < D.EQ_MAX:
			var col_r := Rect2(cx - cw * 0.5, ctl.position.y, cw, ctl.size.y - 30.0)
			if col_r.has_point(mouse):
				_panel(col_r, Color(c_gold, 0.18), 6, c_gold, 2)
				_tip(col_r, "Raise %s to %+d" % [D.GENRES[gi], lv + 1])
			_register(col_r, _bench_apply.bind(bay, gi))

func _ctl_xfader(ctl: Rect2, flash: float) -> void:
	var track := Rect2(ctl.position.x + 34.0, ctl.get_center().y + 10.0, ctl.size.x - 68.0, 10.0)
	for t in 11:
		var tx := track.position.x + track.size.x * t / 10.0
		draw_line(Vector2(tx, track.position.y - 18.0), Vector2(tx, track.position.y - (24.0 if t % 5 == 0 else 12.0)), Color(0, 0, 0, 0.45), 1.5)
	_inset(track, 5.0, Color("0b0c0e"))
	_silk(Vector2(track.position.x - 28.0, track.get_center().y + 8.0), "A", T_SM, Color("23262b"))
	_silk(Vector2(track.end.x + 14.0, track.get_center().y + 8.0), "B", T_SM, Color("23262b"))
	var cx := track.position.x + track.size.x * xfade_pos
	_fader_cap(Rect2(cx - 16.0, track.get_center().y - 24.0, 32.0, 48.0), Color("2b2e33"), 0.0)
	_led(Vector2(ctl.end.x - 14.0, ctl.position.y + 16.0), 6.0, Color(D.ENERGY_COLOR).lightened(0.3), flash)
	_silk(Vector2(ctl.end.x - 72.0, ctl.position.y + 22.0), "LINK", 12, Color("3d4148"))

func _ctl_dial(ctl: Rect2, labels: Array, sel: int, flash: float, bay: int = -1) -> void:
	var kc := ctl.get_center() + Vector2(0.0, 10.0)
	var kr := 36.0
	var n := labels.size()
	var a0 := deg_to_rad(150.0)
	var a1 := deg_to_rad(390.0)
	for k in n:
		var d := Vector2.from_angle(lerpf(a0, a1, float(k) / (n - 1)))
		draw_line(kc + d * (kr + 6.0), kc + d * (kr + 16.0), Color("23262b"), 2.0)
		var on := k == sel
		var lr := Rect2(kc + d * (kr + 40.0) - Vector2(40.0, 12.0), Vector2(80.0, 24.0))
		if bay >= 0 and not on:
			if lr.has_point(mouse):
				_panel(lr, Color(c_gold, 0.25), 6, c_gold, 2)
			_register(lr, _bench_apply.bind(bay, k))
		_text_center(lr, String(labels[k]), 13 if on else 11, Color("b03a2e") if on else Color("4c5058"), true)
	var ang := lerpf(a0, a1, float(sel) / (n - 1)) + sin(clock * 40.0) * 0.05 * flash
	_knob(kc, kr, ang, Color("c3c8ce"))

func _ctl_knobs(ctl: Rect2, flash: float) -> void:
	var leds := 8
	for k in leds:
		var lc := Color("7fe0a0") if k < 5 else (Color("f2c14e") if k < 7 else Color("ff6b5a"))
		_led(Vector2(ctl.position.x + 20.0 + k * (ctl.size.x - 40.0) / (leds - 1), ctl.position.y + 14.0), 4.0, lc, 1.0 if flash * leds > k else 0.0)
	for k in 2:
		var kc := Vector2(ctl.position.x + ctl.size.x * (0.27 + k * 0.46), ctl.get_center().y + 8.0)
		_knob(kc, 32.0, deg_to_rad(200.0 + k * 70.0), Color("c3c8ce"))
		_text_center(Rect2(kc.x - 50.0, kc.y + 40.0, 100.0, 22.0), ["THRESH", "RATIO"][k], 11, Color("3d4148"), true)

func _ctl_tube(ctl: Rect2, flash: float) -> void:
	var win := Rect2(ctl.position.x + 10.0, ctl.position.y + 14.0, 96.0, ctl.size.y - 28.0)
	_inset(win, 8.0, Color("120c08"))
	var c := win.get_center() + Vector2(0.0, 18.0)
	var glow := 0.35 + 0.6 * flash
	for k in 5:
		draw_circle(c, 14.0 + k * 9.0, Color(Color("ff9a3c"), 0.1 * glow))
	var glass := Rect2(c.x - 24.0, win.position.y + 14.0, 48.0, win.size.y - 26.0)
	_panel(glass, Color(1, 1, 1, 0.05), 22, Color(1, 1, 1, 0.22), 2)
	for k in 3:
		var fx := c.x - 8.0 + k * 8.0
		draw_line(Vector2(fx, c.y - 26.0), Vector2(fx, c.y + 18.0), Color(Color("ffb35c"), 0.5 + 0.5 * glow), 2.0)
	draw_line(Vector2(glass.position.x + 8.0, glass.position.y + 10.0), Vector2(glass.position.x + 8.0, glass.end.y - 20.0), Color(1, 1, 1, 0.25), 2.0)
	var kc := Vector2(ctl.position.x + ctl.size.x * 0.7, ctl.get_center().y)
	_knob(kc, 34.0, deg_to_rad(250.0 + flash * 30.0), Color("c3c8ce"))
	_text_center(Rect2(kc.x - 50.0, kc.y + 42.0, 100.0, 22.0), "DRIVE", 11, Color("3d4148"), true)

func _draw_floats() -> void:
	for f: Dictionary in floats:
		var a := clampf(float(f["life"]) / 0.4, 0.0, 1.0)
		var t := String(f["text"])
		var fs := T_HERO if f.get("big", false) else T_LG
		var w := _heavy_w(t, fs)
		var p: Vector2 = f["pos"]
		var col: Color = f["col"]
		var h := fs * 1.6
		_panel(Rect2(p + Vector2(-w * 0.5 - 18.0, -h * 0.75), Vector2(w + 36.0, h)), Color(0.06, 0.07, 0.09, 0.88 * a), int(h * 0.5))
		_heavy(p + Vector2(-w * 0.5, 0.0), t, fs, Color(col, a))

func _draw_toast() -> void:
	if message_t <= 0.0:
		return
	var a := clampf(message_t / 0.4, 0.0, 1.0)
	var w := _text_w(message, T_LG, true) + 60.0
	var cx := r_bin.get_center().x if phase == "shop" else r_wallet.get_center().x
	var cy := r_bin.end.y + 30.0 if phase == "shop" else r_wallet.position.y - 30.0
	var r := Rect2(cx - w * 0.5, cy, w, 60.0)
	_panel(r, Color(0.08, 0.1, 0.14, 0.92 * a), 30)
	_text_center(r, message, T_LG, Color(1, 1, 1, a), true)

func _draw_held() -> void:
	if held < 0:
		return
	var d := collection[held]
	_cd_art(mouse + Vector2(0.0, 6.0), DISC_R, _cover_tex(d.cover))
	_disc_marks(mouse + Vector2(0.0, 6.0), DISC_R, d)

func _tip_disc(r: Rect2, d: Disc) -> void:
	if ui_live and r.has_point(mouse):
		hover_disc = d

func _draw_disc_tip(d: Disc) -> void:
	var w := 560.0
	var pad := 24.0
	var iw := w - pad * 2.0
	var body := ""
	var head := ""
	var gc := Color.WHITE
	if d.ability != "":
		var a: Dictionary = D.ABILITIES[d.ability]
		head = String(a["name"]).to_upper()
		body = String(a["text"])
		gc = Color(D.SOUND_COLOR if a["gain"] == "sound" else D.ENERGY_COLOR).lightened(0.35)
		if d.ability == "one_hit" and int(plays.get(d.uid, 0)) > 0:
			body += " (Played %d×.)" % int(plays[d.uid])
	var bh := font.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, iw, T_SM).y if body != "" else 0.0
	var h := pad + 84.0 + 44.0 + (52.0 + bh + 10.0 if body != "" else 0.0) + (84.0 if d.edition != "" else 0.0) + pad - 6.0
	var box := Rect2(mouse + Vector2(28.0, 28.0), Vector2(w, h))
	if box.end.x > UI_W - 12.0:
		box.position.x = mouse.x - w - 20.0
	if box.end.y > UI_H - 12.0:
		box.position.y = maxf(12.0, UI_H - 12.0 - h)
	_panel(Rect2(box.position + Vector2(0, 8), box.size), Color(0, 0, 0, 0.4), 18)
	_panel(box, Color("161b24"), 18, Color(1, 1, 1, 0.14), 2)
	var x := box.position.x + pad
	var y := box.position.y + pad
	_heavy(Vector2(x, y + 30.0), d.title, T_LG, Color.WHITE)
	_text_i(Vector2(x, y + 64.0), "by %s  ·  %s" % [d.band, D.LABELS[d.label]["name"]], T_SM, Color("b8c0cc"))
	y += 84.0
	var chips := [[D.GENRES[d.genre].to_upper(), Color(D.GENRE_COLORS[d.genre])], [D.ERAS[d.era], Color("5d626a")], ["%d SOUND" % d.sound, Color(D.SOUND_COLOR)]]
	var cx := x
	for c in chips:
		var cw := _text_w(String(c[0]), T_XS, true) + 18.0
		var cr := Rect2(cx, y, cw, 32.0)
		_panel(cr, c[1], 12)
		_text_center(cr, String(c[0]), T_XS, Color.WHITE, true)
		cx += cw + 8.0
	y += 44.0
	if body != "":
		draw_line(Vector2(x, y), Vector2(x + iw, y), Color(1, 1, 1, 0.12), 2.0)
		_text(Vector2(x, y + 34.0), head, T_XS, gc, true)
		_wrap(Vector2(x, y + 46.0), body, iw, T_SM, Color("e8ecf2"))
		y += 52.0 + bh + 10.0
	if d.edition != "":
		var ed: Dictionary = D.EDITIONS[d.edition]
		draw_line(Vector2(x, y), Vector2(x + iw, y), Color(1, 1, 1, 0.12), 2.0)
		_text(Vector2(x, y + 34.0), "%s EDITION" % String(ed["name"]).to_upper(), T_XS, Color(ed["color"]).lightened(0.3), true)
		_text(Vector2(x, y + 68.0), String(ed["text"]), T_SM, Color("e8ecf2"))

func _modal_panel(w: float, h: float) -> Rect2:
	draw_rect(Rect2(Vector2(-800, -800), Vector2(UI_W, UI_H) + Vector2(1600, 1600)), Color(0.05, 0.06, 0.08, 0.72))
	var r := Rect2(UI_W * 0.5 - w * 0.5, UI_H * 0.5 - h * 0.5, w, h)
	_panel(Rect2(r.position + Vector2(0, 10), r.size), Color(0, 0, 0, 0.4), 24)
	_panel(r, Color("f4efe4"), 24)
	return r

func _draw_result() -> void:
	var r := _modal_panel(900.0, 560.0)
	_heavy_center(Rect2(r.position.x, r.position.y + 40.0, r.size.x, 90.0), "Gig %d cleared!" % gig_n, T_HERO, c_good)
	_text_center(Rect2(r.position.x, r.position.y + 140.0, r.size.x, 40.0), "Crowd score %s of %s" % [_fmt_int(gig_score), _fmt_int(target)], T_LG, c_ink, true)
	var x := r.position.x + 220.0
	var w := r.size.x - 440.0
	var y := r.position.y + 230.0
	_text(Vector2(x, y), "Gig pay", T_MD, c_muted, true)
	_heavy_right(x + w, y, "$%d" % int(reward["pay"]), T_LG, c_ink)
	_text(Vector2(x, y + 48.0), "Crowd bonus", T_MD, c_muted, true)
	_heavy_right(x + w, y + 48.0, "$%d" % int(reward["bonus"]), T_LG, c_ink)
	if int(reward.get("mint", 0)) > 0:
		_text(Vector2(x + w + 30.0, y + 48.0), "+$%d mint" % int(reward["mint"]), T_SM, c_good, true)
	draw_line(Vector2(x, y + 70.0), Vector2(x + w, y + 70.0), Color(c_ink, 0.2), 2.0)
	_text(Vector2(x, y + 110.0), "Cash", T_MD, c_muted, true)
	_heavy_right(x + w, y + 112.0, "$%d" % cash, T_XL, c_good)
	_hw_button(Rect2(r.get_center().x - 220.0, r.end.y - 120.0, 440.0, 84.0), "Visit the record shop", _to_shop, true, Color("3f9b5a"), T_LG)

func _draw_run_end(won: bool) -> void:
	var r := _modal_panel(900.0, 440.0)
	_heavy_center(Rect2(r.position.x, r.position.y + 50.0, r.size.x, 90.0), "Tour complete!" if won else "The crowd went home", T_HERO, c_good if won else c_bad)
	_text_center(Rect2(r.position.x, r.position.y + 160.0, r.size.x, 40.0), "Crowd score %s of %s" % [_fmt_int(gig_score), _fmt_int(target)], T_LG, c_ink, true)
	_text_center(Rect2(r.position.x, r.position.y + 205.0, r.size.x, 40.0), "You played all %d gigs." % D.GIGS if won else "Your tour ended at gig %d of %d." % [gig_n, D.GIGS], T_MD, c_body)
	_hw_button(Rect2(r.get_center().x - 160.0, r.end.y - 130.0, 320.0, 86.0), "New tour", _new_run, true, Color("3f9b5a"), T_LG)

func _to_shop() -> void:
	_make_shop()
	phase = "shop"

func _next_gig() -> void:
	install_queue.clear()
	install_price = 0
	install_src = -1
	pack = {}
	bench = -1
	services.clear()
	message_t = 0.0
	gig_n += 1
	_start_gig()

func _album_price(d: Disc) -> int:
	return D.ALBUM_PRICE + (D.ABILITY_PREMIUM if d.ability != "" else 0) + (1 if d.sound >= 4 else 0)

func _make_shop() -> void:
	shop_items.clear()
	for a in _fresh_albums(D.SHOP_ALBUMS):
		var d := _make_disc(a)
		shop_items.append({"kind": "album", "disc": d, "price": _album_price(d), "sold": false})
	var ap: Dictionary = D.ALBUM_PACKS[rng.randi_range(0, D.ALBUM_PACKS.size() - 1)]
	shop_items.append({"kind": "album_pack", "pack": ap, "price": int(ap["price"]), "sold": false})
	var gear_ids := _random_gear_ids(D.SHOP_GEAR)
	for k in D.SHOP_GEAR:
		if k < gear_ids.size():
			shop_items.append({"kind": "gear", "gear": _make_gear(gear_ids[k]), "price": int(D.GEAR[gear_ids[k]]["price"]), "sold": false})
		else:
			shop_items.append({"kind": "gear", "gear": {}, "price": 0, "sold": true})
	var gp: Dictionary = D.GEAR_PACKS[rng.randi_range(0, D.GEAR_PACKS.size() - 1)]
	shop_items.append({"kind": "gear_pack", "pack": gp, "price": int(gp["price"]), "sold": false})
	_make_services()

func _buy(i: int) -> void:
	var it: Dictionary = shop_items[i]
	if bool(it["sold"]) or cash < int(it["price"]):
		return
	match String(it["kind"]):
		"album":
			cash -= int(it["price"])
			it["sold"] = true
			collection.append(it["disc"])
			_say("%s added to your binder." % (it["disc"] as Disc).title)
		"album_pack":
			cash -= int(it["price"])
			it["sold"] = true
			var ap: Dictionary = it["pack"]
			var items: Array = []
			var taken: Array = shop_items.filter(func(o): return o["kind"] == "album").map(func(o): return (o["disc"] as Disc).cover)
			for a in _fresh_albums(int(ap["show"]), taken):
				items.append(_make_disc(a))
			pack = {"kind": "album", "title": ap["name"], "pick": int(ap["pick"]), "items": items}
			pack_sel.clear()
		"gear":
			install_queue = [it["gear"]]
			install_price = int(it["price"])
			install_src = i
			_say("Pick a bay in your rack. Right-click to cancel.")
		"gear_pack":
			cash -= int(it["price"])
			it["sold"] = true
			var gp: Dictionary = it["pack"]
			var items: Array = []
			var shelf: Array = shop_items.filter(func(o): return o["kind"] == "gear" and not bool(o["sold"])).map(func(o): return o["gear"]["id"])
			var ids := _random_gear_ids(int(gp["show"]), shelf)
			if ids.size() < int(gp["show"]):
				ids = _random_gear_ids(int(gp["show"]))
			for id in ids:
				items.append(_make_gear(id))
			if items.is_empty():
				cash += int(it["price"])
				it["sold"] = false
				_say("You already own every kind of gear.")
				return
			pack = {"kind": "gear", "title": gp["name"], "pick": mini(int(gp["pick"]), items.size()), "items": items}
			pack_sel.clear()

func _toggle_pick(k: int) -> void:
	if k in pack_sel:
		pack_sel.erase(k)
	elif pack_sel.size() < int(pack["pick"]):
		pack_sel.append(k)

func _take_pack() -> void:
	var items: Array = pack["items"]
	if pack["kind"] == "album":
		for k in pack_sel:
			collection.append(items[k])
		_say("Added %d album%s to your binder." % [pack_sel.size(), "" if pack_sel.size() == 1 else "s"])
	else:
		install_queue.clear()
		for k in pack_sel:
			install_queue.append(items[k])
		install_price = 0
		install_src = -1
		_say("Pick a bay for each piece of gear. Right-click to leave it in the box.")
	pack = {}
	pack_sel.clear()

func _bench_kind() -> String:
	if bench < 0 or bench >= services.size():
		return ""
	return String(services[bench]["kind"])

func _start_service(i: int) -> void:
	var sv: Dictionary = services[i]
	if bool(sv["sold"]) or cash < int(sv["price"]):
		return
	if sv["kind"] == "enhance":
		binder_pick = i
		binder_open = true
		binder_page = 0
		return
	bench = i
	_say("Click a unit in your rack." if sv["kind"] == "upgrade" else "Click a fader or dial setting in your rack.")

func _bench_apply(bay: int, idx: int) -> void:
	var sv: Dictionary = services[bench]
	var g: Dictionary = rack[bay]
	if cash < int(sv["price"]) or g.is_empty():
		return
	if sv["kind"] == "upgrade":
		if g["id"] == "eq" or int(g.get("level", 0)) >= _gear_max(g):
			return
		g["level"] = int(g.get("level", 0)) + 1
		_say("%s upgraded to %s." % [D.GEAR[g["id"]]["name"], D.LEVEL_NAMES[g["level"]]])
	else:
		match String(g["id"]):
			"eq":
				g["levels"][idx] = mini(D.EQ_MAX, int(g["levels"][idx]) + 1)
				_say("%s is now %+d." % [D.GENRES[idx], int(g["levels"][idx])])
			"gain":
				g["genre"] = idx
				_say("Gain Stage set to %s." % D.GENRES[idx])
			"exciter":
				g["era"] = idx
				_say("Exciter set to the %s." % D.ERAS[idx])
			_:
				return
	cash -= int(sv["price"])
	sv["sold"] = true
	bench = -1
	comp_flash[bay] = 1.0
	_sfx("page_turn")

func _enhance(i: int) -> void:
	var sv: Dictionary = services[binder_pick]
	var d := collection[i]
	if d.edition != "" or cash < int(sv["price"]):
		return
	d.edition = String(sv["edition"])
	cash -= int(sv["price"])
	sv["sold"] = true
	binder_pick = -1
	binder_open = false
	_sfx("page_turn")
	_say("%s is now %s." % [d.title, D.EDITIONS[d.edition]["name"]])

func _make_services() -> void:
	services.clear()
	bench = -1
	var pool: Array = []
	if rng.randf() < float(D.SERVICE_CHANCE["enhance"]):
		var eds: Array = D.EDITIONS.keys()
		var e: String = eds[rng.randi_range(0, eds.size() - 1)]
		pool.append({"kind": "enhance", "edition": e, "price": int(D.EDITIONS[e]["price"]), "sold": false})
	if rng.randf() < float(D.SERVICE_CHANCE["tweak"]) and rack.any(func(g): return not g.is_empty() and g["id"] in ["eq", "gain", "exciter"]):
		pool.append({"kind": "tweak", "price": D.TWEAK_PRICE, "sold": false})
	if rng.randf() < float(D.SERVICE_CHANCE["upgrade"]) and rack.any(func(g): return not g.is_empty() and g["id"] != "eq" and int(g.get("level", 0)) < _gear_max(g)):
		pool.append({"kind": "upgrade", "price": D.UPGRADE_PRICE, "sold": false})
	_shuffle(pool)
	services = pool.slice(0, D.SERVICES_MAX)

func _install(slot: int) -> void:
	if install_queue.is_empty():
		return
	if install_price > 0:
		if cash < install_price:
			return
		cash -= install_price
		shop_items[install_src]["sold"] = true
	var g: Dictionary = install_queue.pop_front()
	rack[slot] = g
	comp_flash[slot] = 1.0
	install_price = 0
	install_src = -1
	_sfx("page_turn")
	_say("Installed the %s." % D.GEAR[g["id"]]["name"])

func _draw_shop() -> void:
	draw_rect(Rect2(-800, -800, UI_W + 1600, UI_H + 1600), Color("3a302b"))
	var x := -40.0
	while x < r_rack.position.x:
		draw_line(Vector2(x, -800.0), Vector2(x, UI_H + 800.0), Color(0, 0, 0, 0.08), 3.0)
		x += 120.0
	var sign := Rect2(r_bin.position.x + 120.0, 50.0, r_bin.size.x - 240.0, 100.0)
	for sx: float in [sign.position.x + 90.0, sign.end.x - 90.0]:
		draw_line(Vector2(sx, -40.0), Vector2(sx, sign.position.y), Color("5f5e5a"), 4.0)
	_shadow(sign, 12, 8.0)
	_panel(sign, Color("1d1a17"), 12, c_gold, 3)
	_panel(sign.grow(-10.0), Color(c_gold, 0.08), 8)
	_heavy_center(Rect2(sign.position.x, sign.position.y + 4.0, sign.size.x, 60.0), "THE B-SIDE", T_XL, c_gold)
	_text_center(Rect2(sign.position.x, sign.position.y + 58.0, sign.size.x, 30.0), "USED CDs  ·  AUDIO GEAR", T_XS, Color(c_gold, 0.75), true)
	_draw_bin()
	_draw_counter()
	_draw_gear_wall()

func _crate_wood(r: Rect2, seed_n: int) -> void:
	_surface(r, 4.0, "crate_wood", Color("a07a52"), Color("7d5c3c"), 500.0)
	if _tex("crate_wood") == null:
		var g := RandomNumberGenerator.new()
		g.seed = seed_n
		var y := r.position.y + 4.0
		while y < r.end.y - 4.0:
			var col := Color("5a3f27") if g.randf() < 0.5 else Color("c49a6c")
			var y2 := y + g.randf_range(-2.0, 2.0)
			draw_line(Vector2(r.position.x + 4.0, y), Vector2(r.end.x - 4.0, y2), Color(col, g.randf_range(0.08, 0.2)), g.randf_range(1.0, 2.0))
			y += g.randf_range(4.0, 9.0)
	draw_line(r.position + Vector2(4.0, 1.0), Vector2(r.end.x - 4.0, r.position.y + 1.0), Color(1, 1, 1, 0.25), 2.0)
	_panel(r, Color(0, 0, 0, 0), 4, Color(0, 0, 0, 0.5), 1)

func _draw_bin() -> void:
	var b := r_bin
	_shadow(b, 8, 14.0)
	_panel(Rect2(b.position.x, b.position.y, b.size.x, b.size.y - 60.0), Color("1c1714"), 6)
	_grad_panel(Rect2(b.position.x, b.position.y, b.size.x, 40.0), 6.0, Color(0, 0, 0, 0.5), Color(0, 0, 0, 0.0))
	var cw := (b.size.x - 40.0) / 3.0
	for k in 3:
		var cell := Rect2(b.position.x + 20.0 + k * cw, b.position.y + 34.0, cw, 260.0)
		if k > 0:
			_crate_wood(Rect2(cell.position.x - 6.0, b.position.y + 10.0, 12.0, 290.0), 90 + k)
		var it: Dictionary = shop_items[k]
		var cr := Rect2(cell.get_center().x - 140.0, cell.position.y + 6.0, 280.0, 248.0)
		if bool(it["sold"]):
			_heavy_center(cr, "SOLD", T_XL, Color(1, 1, 1, 0.1))
			continue
		var afford := cash >= int(it["price"])
		var hot := ui_live and afford and cr.has_point(mouse)
		var lift := 10.0 if hot else 0.0
		var rr := Rect2(cr.position - Vector2(0.0, lift), cr.size)
		if it["kind"] == "album":
			var d: Disc = it["disc"]
			_draw_case(rr, d, int(it["price"]))
			_tip_disc(cr, d)
		else:
			_draw_case_pack(rr, it["pack"], int(it["price"]))
			var ap: Dictionary = it["pack"]
			_tip(cr, "%s: open it and pick %d of %d albums for your binder." % [ap["name"], int(ap["pick"]), int(ap["show"])])
		if not afford:
			_panel(rr, Color(0, 0, 0, 0.5), 6)
		if ui_live and afford:
			_register(cr, _buy.bind(k))
	var lip := Rect2(b.position.x - 10.0, b.position.y + 286.0, b.size.x + 20.0, 74.0)
	_crate_wood(lip, 7)
	for k in 3:
		var it: Dictionary = shop_items[k]
		var card := Rect2(b.position.x + 20.0 + k * cw + 30.0, lip.position.y + 12.0, cw - 60.0, 50.0)
		_panel(card, Color("f6f1e3"), 3)
		draw_circle(card.position + Vector2(10, 10), 3.0, Color("9aa0a6"))
		if bool(it["sold"]):
			continue
		if it["kind"] == "album":
			_chip_row(Rect2(card.position.x, card.position.y + 9.0, card.size.x, 32.0), it["disc"])
		else:
			var ap: Dictionary = it["pack"]
			_text_center(card, "PICK %d OF %d" % [int(ap["pick"]), int(ap["show"])], T_SM, c_ink, true)
	draw_rect(Rect2(b.position.x + 20.0, b.end.y - 60.0, 26.0, 60.0), Color("2a2420"))
	draw_rect(Rect2(b.end.x - 46.0, b.end.y - 60.0, 26.0, 60.0), Color("2a2420"))

func _draw_case(r: Rect2, d: Disc, price: int = -1) -> void:
	var k := r.size.y / 160.0
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
	var tex := _cover_tex(d.cover)
	if tex:
		draw_texture_rect(tex, cover, false)
	else:
		_panel(cover, Color(D.GENRE_COLORS[d.genre]), 0)
	_panel(cover, Color(0, 0, 0, 0), 0, Color(0, 0, 0, 0.55), maxi(1, int(1.5 * k)))
	_disc_marks(cover.get_center(), cover.size.x * 0.5, d)
	var gloss := PackedVector2Array([r.position + Vector2(r.size.x * 0.35, 0), r.position + Vector2(r.size.x * 0.62, 0), r.position + Vector2(r.size.x * 0.3, r.size.y), r.position + Vector2(r.size.x * 0.03, r.size.y)])
	draw_colored_polygon(gloss, Color(1, 1, 1, 0.07))
	draw_line(r.position + Vector2(4.0 * k, 2.0 * k), Vector2(r.end.x - 4.0 * k, r.position.y + 2.0 * k), Color(1, 1, 1, 0.6), maxf(1.0, 1.5 * k))
	if price >= 0:
		_price_sticker(Vector2(cover.end.x - 8.0 * k, cover.position.y + 8.0 * k), "$%d" % price, k)

func _price_sticker(top_right: Vector2, text: String, k: float) -> void:
	var fs := maxi(12, int(20.0 * k * 0.7))
	var w := _heavy_w(text, fs) + 18.0
	var pr := Rect2(top_right.x - w, top_right.y, w, fs + 14.0)
	_panel(Rect2(pr.position + Vector2(1, 2), pr.size), Color(0, 0, 0, 0.3), 3)
	_panel(pr, Color("ffd23f"), 3)
	draw_line(Vector2(pr.position.x + 4.0, pr.end.y - 4.0), Vector2(pr.end.x - 4.0, pr.end.y - 4.0), Color(0, 0, 0, 0.18), 1.0)
	_heavy_center(pr, text, fs, Color("8a1c12"))

func _draw_case_pack(r: Rect2, ap: Dictionary, price: int) -> void:
	var k := r.size.y / 160.0
	for j in range(2, -1, -1):
		var cr := Rect2(r.position + Vector2(-j * 12.0, -j * 10.0) * k * 0.6 + Vector2(10.0, 10.0), r.size - Vector2(20.0, 20.0))
		_shadow(cr, 6, 4.0)
		_panel(cr, Color("c9d2db"), 6)
		var body := cr.grow(-3.0)
		_panel(body, Color("1b1e23"), 4)
		var ins := Rect2(body.position.x + 20.0, body.position.y + 6.0, body.size.x - 26.0, body.size.y - 12.0)
		_grad_panel(ins, 2.0, Color("2c3e50").lerp(Color("8e44ad"), j * 0.3), Color("1a252f"))
		if j == 0:
			_heavy_center(Rect2(ins.position.x, ins.position.y + ins.size.y * 0.25, ins.size.x, 50.0), String(ap["name"]).to_upper(), T_LG, Color("f4efe4"))
			_text_center(Rect2(ins.position.x, ins.position.y + ins.size.y * 0.25 + 46.0, ins.size.x, 30.0), "VARIOUS ARTISTS", T_XS, Color(1, 1, 1, 0.6), true)
	var wrap := r.grow(-4.0)
	_panel(wrap, Color(1, 1, 1, 0.06), 10, Color(1, 1, 1, 0.3), 2)
	draw_line(wrap.position + Vector2(30, 6), wrap.position + Vector2(8, 60), Color(1, 1, 1, 0.35), 3.0)
	draw_line(Vector2(wrap.end.x - 40.0, wrap.end.y - 8.0), Vector2(wrap.end.x - 8.0, wrap.end.y - 50.0), Color(1, 1, 1, 0.25), 2.0)
	_price_sticker(Vector2(r.end.x - 4.0, r.position.y + 4.0), "$%d" % price, k)

func _draw_counter() -> void:
	var c := r_counter
	var top := Rect2(c.position.x - 20.0, c.position.y, c.size.x + 40.0, 30.0)
	var front := Rect2(c.position.x, c.position.y + 30.0, c.size.x, c.size.y)
	_surface(front, 0.0, "wood", Color("5e412c"), Color("3e2a1c"), 700.0)
	if _tex("wood") == null:
		_grain(front, 23, 900.0)
	_surface(top, 6.0, "wood", Color("8a6446"), Color("6b4a32"), 700.0)
	draw_line(Vector2(top.position.x, top.end.y), Vector2(top.end.x, top.end.y), Color(0, 0, 0, 0.4), 4.0)
	var reg := Rect2(c.position.x + 40.0, c.position.y + 70.0, 440.0, 250.0)
	_shadow(reg, 10, 8.0)
	_surface(reg, 10.0, "metal_dark", Color("2b2e33"), Color("1a1c20"))
	_panel(reg, Color(0, 0, 0, 0), 10, Color(0, 0, 0, 0.6), 2)
	_silk(Vector2(reg.position.x + 30.0, reg.position.y + 44.0), "CASH", T_SM, Color("8d939b"))
	_lcd(Rect2(reg.position.x + 30.0, reg.position.y + 60.0, reg.size.x - 60.0, 90.0), "$%d" % cash, Color("7fe0a0"), T_HERO, "$888")
	_silk(Vector2(reg.position.x + 30.0, reg.end.y - 60.0), "BINDER", T_XS, Color("8d939b"))
	_text_right(reg.end.x - 30.0, reg.end.y - 60.0, "%d albums" % collection.size(), T_SM, Color("e6e9ed"), true)
	_silk(Vector2(reg.position.x + 30.0, reg.end.y - 28.0), "NEXT GIG", T_XS, Color("8d939b"))
	_text_right(reg.end.x - 30.0, reg.end.y - 28.0, "Gig %d · target %s" % [gig_n + 1, _fmt_int(D.TARGETS[mini(gig_n, D.GIGS - 1)])], T_SM, Color("e6e9ed"), true)
	var nb := Rect2(c.end.x - 420.0, c.position.y + 120.0, 380.0, 120.0)
	_hw_button(nb, "Next gig", _next_gig, ui_live and install_queue.is_empty() and bench < 0, Color("3f9b5a"), T_XL)
	_draw_services(Rect2(c.position.x + 40.0, c.position.y + 350.0, c.size.x - 80.0, 222.0))
	if not install_queue.is_empty():
		var g: Dictionary = install_queue[0]
		_wrap(Vector2(nb.position.x, nb.end.y + 24.0), "Choose a rack bay for the %s." % D.GEAR[g["id"]]["name"], nb.size.x, T_SM, Color("f4efe4"), true)

func _draw_gear_wall() -> void:
	var w := r_shelf
	_shadow(w, 8, 10.0)
	_surface(w, 8.0, "pegboard", Color("b89a72"), Color("a08360"), 400.0)
	if _tex("pegboard") == null:
		var y := w.position.y + 20.0
		while y < w.end.y - 10.0:
			var x := w.position.x + 20.0
			while x < w.end.x - 10.0:
				draw_circle(Vector2(x, y), 3.5, Color("4a3a2a"))
				x += 32.0
			y += 32.0
	_panel(w, Color(0, 0, 0, 0), 8, Color(0, 0, 0, 0.5), 2)
	var ux := w.position.x + 24.0
	var rows := [w.position.y + 50.0, w.position.y + 350.0]
	for k in 2:
		var it: Dictionary = shop_items[3 + k]
		var ur := Rect2(ux, rows[k], 556.0, 236.0)
		_shelf(Rect2(w.position.x + 10.0, ur.end.y + 6.0, w.size.x - 20.0, 16.0))
		if bool(it["sold"]):
			_heavy_center(ur, "SOLD", T_XL, Color(0, 0, 0, 0.25))
			continue
		var afford := cash >= int(it["price"])
		_draw_gear(ur, it["gear"], 0.0)
		var picked := install_src == 3 + k
		if picked:
			_panel(ur.grow(6.0), Color(0, 0, 0, 0), 10, c_gold, 5)
		if not afford:
			_panel(ur, Color(0, 0, 0, 0.45), 6)
		_hang_tag(Vector2(ur.end.x + 70.0, ur.position.y + 20.0), "$%d" % int(it["price"]))
		if ui_live and afford and install_queue.is_empty():
			if ur.has_point(mouse):
				_panel(ur.grow(4.0), Color(0, 0, 0, 0), 10, Color(c_gold, 0.8), 3)
			_register(ur, _buy.bind(3 + k))
	var it: Dictionary = shop_items[5]
	var bx := Rect2(ux, w.position.y + 700.0, 460.0, 270.0)
	_shelf(Rect2(w.position.x + 10.0, bx.end.y + 6.0, w.size.x - 20.0, 16.0))
	if bool(it["sold"]):
		_heavy_center(bx, "SOLD", T_XL, Color(0, 0, 0, 0.25))
	else:
		var gp: Dictionary = it["pack"]
		var afford := cash >= int(it["price"])
		var hot := ui_live and afford and install_queue.is_empty() and bx.has_point(mouse)
		_cardboard_box(Rect2(bx.position - Vector2(0.0, 8.0 if hot else 0.0), bx.size), String(gp["name"]), "PICK %d OF %d" % [int(gp["pick"]), int(gp["show"])])
		if not afford:
			_panel(bx, Color(0, 0, 0, 0.45), 4)
		_hang_tag(Vector2(bx.end.x + 70.0, bx.position.y + 20.0), "$%d" % int(it["price"]))
		_tip(bx, "%s: open it and keep %d of %d pieces of gear." % [gp["name"], int(gp["pick"]), int(gp["show"])])
		if ui_live and afford and install_queue.is_empty():
			_register(bx, _buy.bind(5))

func _shelf(r: Rect2) -> void:
	_shadow(r, 2, 6.0)
	_brushed(r, 2.0, Color("8d939a"), int(r.position.y))
	for bx: float in [r.position.x + 40.0, r.end.x - 60.0]:
		draw_colored_polygon(PackedVector2Array([Vector2(bx, r.end.y), Vector2(bx + 20.0, r.end.y), Vector2(bx + 20.0, r.end.y + 40.0)]), Color("6b7178"))

func _hang_tag(c: Vector2, text: String) -> void:
	draw_line(c + Vector2(0.0, -30.0), c + Vector2(0.0, 6.0), Color("e8e2d0"), 2.0)
	draw_circle(c + Vector2(0.0, -30.0), 5.0, Color("8d939a"))
	var r := Rect2(c.x - 55.0, c.y, 110.0, 70.0)
	_panel(Rect2(r.position + Vector2(2, 4), r.size), Color(0, 0, 0, 0.3), 6)
	_panel(r, Color("f3e3b5"), 6)
	draw_circle(Vector2(r.get_center().x, r.position.y + 10.0), 4.0, Color("6b5a3a"))
	_heavy_center(Rect2(r.position.x, r.position.y + 14.0, r.size.x, r.size.y - 14.0), text, T_LG, Color("8a1c12"))

func _cardboard_box(r: Rect2, title: String, sub: String) -> void:
	_shadow(r, 4, 10.0)
	_surface(r, 4.0, "cardboard", Color("c79b63"), Color("a97e4a"), 400.0)
	if _tex("cardboard") == null:
		var g := RandomNumberGenerator.new()
		g.seed = 11
		var x := r.position.x + 3.0
		while x < r.end.x - 3.0:
			draw_line(Vector2(x, r.position.y + 2.0), Vector2(x, r.end.y - 2.0), Color(0, 0, 0, g.randf_range(0.02, 0.05)), 1.0)
			x += 6.0
	_panel(r, Color(0, 0, 0, 0), 4, Color("7a5a33"), 2)
	draw_line(Vector2(r.position.x, r.position.y + 50.0), Vector2(r.end.x, r.position.y + 50.0), Color("8a6a40"), 2.0)
	draw_rect(Rect2(r.get_center().x - 40.0, r.position.y, 80.0, 50.0), Color("d9c9a3", 0.75))
	draw_rect(Rect2(r.get_center().x - 40.0, r.position.y, 80.0, 50.0), Color(1, 1, 1, 0.12))
	var lab := Rect2(r.position.x + 40.0, r.position.y + 80.0, r.size.x - 80.0, 130.0)
	_panel(lab, Color("f7f3e8"), 2)
	_heavy_center(Rect2(lab.position.x, lab.position.y + 14.0, lab.size.x, 56.0), title.to_upper(), T_XL, Color("22252a"))
	_text_center(Rect2(lab.position.x, lab.position.y + 72.0, lab.size.x, 34.0), sub, T_MD, Color("b03a2e"), true)
	for k in 2:
		var ax := r.end.x - 30.0 - k * 22.0
		draw_line(Vector2(ax, r.end.y - 20.0), Vector2(ax, r.end.y - 50.0), Color(0, 0, 0, 0.45), 3.0)
		draw_colored_polygon(PackedVector2Array([Vector2(ax - 7.0, r.end.y - 44.0), Vector2(ax + 7.0, r.end.y - 44.0), Vector2(ax, r.end.y - 56.0)]), Color(0, 0, 0, 0.45))

func _draw_pack() -> void:
	var items: Array = pack["items"]
	var pick := int(pack["pick"])
	var albums_mode: bool = pack["kind"] == "album"
	var n := items.size()
	var w := maxf(900.0, n * 320.0 + 120.0) if albums_mode else 760.0
	var h := 760.0 if albums_mode else 360.0 + n * 256.0
	var r := _modal_panel(w, h)
	_heavy_center(Rect2(r.position.x, r.position.y + 30.0, r.size.x, 70.0), String(pack["title"]), T_XL + 8, c_ink)
	_text_center(Rect2(r.position.x, r.position.y + 96.0, r.size.x, 34.0), "Pick %d. %d of %d chosen." % [pick, pack_sel.size(), pick], T_MD, c_body, true)
	for k in n:
		var sel := k in pack_sel
		var cell: Rect2
		if albums_mode:
			var x0 := r.get_center().x - n * 160.0
			cell = Rect2(x0 + k * 320.0 + 20.0, r.position.y + 160.0, 280.0, 430.0)
			var d: Disc = items[k]
			_draw_case(Rect2(cell.position, Vector2(280.0, 248.0)), d)
			_chip_row(Rect2(cell.position.x, cell.position.y + 260.0, 280.0, 32.0), d)
			if d.ability != "":
				var a: Dictionary = D.ABILITIES[d.ability]
				_text(Vector2(cell.position.x + 6.0, cell.position.y + 328.0), String(a["name"]), T_SM, Color(D.SOUND_COLOR if a["gain"] == "sound" else D.ENERGY_COLOR).darkened(0.2), true)
				_wrap(Vector2(cell.position.x + 6.0, cell.position.y + 338.0), String(a["text"]), 268.0, 17, c_body)
			_tip_disc(Rect2(cell.position, Vector2(280.0, 248.0)), d)
		else:
			cell = Rect2(r.get_center().x - 278.0, r.position.y + 150.0 + k * 256.0, 556.0, 236.0)
			_draw_gear(cell, items[k], 0.0)
		if sel:
			_panel(cell.grow(10.0), Color(c_gold, 0.12), 14, c_gold, 5)
		elif cell.has_point(mouse) and pack_sel.size() < pick:
			_panel(cell.grow(10.0), Color(0, 0, 0, 0), 14, Color(c_gold, 0.5), 3)
		_register(cell, _toggle_pick.bind(k))
	var n_sel := pack_sel.size()
	var label := ("Add to binder" if albums_mode else "Take gear") + (" (%d)" % n_sel if n_sel > 0 else "")
	_hw_button(Rect2(r.get_center().x - 230.0, r.end.y - 110.0, 300.0, 80.0), label, _take_pack, n_sel > 0, Color("3f9b5a"), T_MD)
	_hw_button(Rect2(r.get_center().x + 90.0, r.end.y - 110.0, 160.0, 80.0), "Skip", _skip_pack, true, Color("8a8f98"), T_MD)

func _skip_pack() -> void:
	pack = {}
	pack_sel.clear()

func _toggle_binder() -> void:
	binder_open = not binder_open
	binder_page = 0
	_sfx("page_turn")

func _flip_binder(step: int) -> void:
	var last := maxi(0, (collection.size() - 1) / BINDER_SPREAD)
	var to := clampi(binder_page + step, 0, last)
	if to != binder_page:
		binder_page = to
		_sfx("page_turn")

func _binder_order() -> Array:
	var ids: Array = range(collection.size())
	if sort_key != "":
		ids.sort_custom(func(a, b): return _sort_less(collection[a], collection[b]))
	return ids

func _binder_status(i: int) -> Array:
	if phase != "gig":
		return []
	if i in tray or i == held:
		return ["IN CHANGER", Color("3f9b5a")]
	if i in wallet:
		return ["IN WALLET", Color("2e6ea6")]
	if i in discard:
		return ["DUG", Color("6a6f77")]
	return []

func _draw_binder_button() -> void:
	var r := Rect2(60.0, 1312.0, 360.0, 84.0)
	_hw_button(r, "View binder (%d)" % collection.size(), _toggle_binder, true, C_LEATHER.lightened(0.15), T_MD)

func _draw_binder_overlay() -> void:
	hover_disc = null
	draw_rect(Rect2(Vector2(-800, -800), Vector2(UI_W, UI_H) + Vector2(1600, 1600)), Color(0.04, 0.05, 0.07, 0.82))
	_register(Rect2(Vector2(-800, -800), Vector2(UI_W, UI_H) + Vector2(1600, 1600)), func(): pass)
	var b := Rect2(60.0, 130.0, 1540.0, 960.0)
	_heavy(Vector2(b.position.x, 96.0), "Your Binder", T_XL + 8, Color("f4efe4"))
	var sorted_by := "  ·  sorted by %s" % String(D.SORT_TEXT[sort_key]).to_lower() if sort_key != "" else "  ·  in the order you got them"
	if binder_pick >= 0:
		var ed: Dictionary = D.EDITIONS[services[binder_pick]["edition"]]
		sorted_by = "  ·  pick an album to make %s ($%d)" % [ed["name"], int(services[binder_pick]["price"])]
	_text(Vector2(b.position.x + _heavy_w("Your Binder", T_XL + 8) + 24.0, 92.0), "%d albums%s" % [collection.size(), sorted_by], T_MD, Color("b8c0cc"), true)
	_shadow(b, 22, 14.0)
	_surface(b, 22.0, "leather", C_LEATHER.lightened(0.1), C_LEATHER.darkened(0.15), 600.0)
	if _tex("leather") == null:
		_grain(b, 29, 260.0)
	_stitch_rect(b.grow(-12.0), Color("aab3bf", 0.45))
	var spine := Rect2(b.get_center().x - 30.0, b.position.y + 18.0, 60.0, b.size.y - 36.0)
	_grad_panel(spine, 8.0, Color("23262b"), Color("15171a"))
	for k in 3:
		var ry := b.position.y + b.size.y * (0.2 + k * 0.3)
		draw_line(Vector2(spine.position.x - 14.0, ry), Vector2(spine.end.x + 14.0, ry), Color("5f676f"), 9.0)
		draw_line(Vector2(spine.position.x - 14.0, ry), Vector2(spine.end.x + 14.0, ry), Color("c3cad1"), 5.0)
	var order := _binder_order()
	var cell := 204.0
	var gap := 18.0
	for side in 2:
		var page := Rect2(b.position.x + 34.0 if side == 0 else spine.end.x + 18.0, b.position.y + 30.0, spine.position.x - 18.0 - b.position.x - 34.0, b.size.y - 60.0)
		_surface(page, 8.0, "fabric", Color("2a2d33"), Color("1f2227"), 300.0)
		var gx := page.position.x + (page.size.x - (3.0 * cell + 2.0 * gap)) * 0.5
		for k in 9:
			var n := binder_page * BINDER_SPREAD + side * 9 + k
			var r := Rect2(gx + (k % 3) * (cell + gap), page.position.y + 24.0 + (k / 3) * (cell + 80.0), cell, cell)
			var pocket := Rect2(r.position - Vector2(6.0, 6.0), Vector2(r.size.x + 12.0, r.size.y + 54.0))
			_panel(pocket, Color(1, 1, 1, 0.03), 8, Color(1, 1, 1, 0.13), 2)
			_pocket_lip(pocket)
			if n < order.size():
				var i: int = order[n]
				var d := collection[i]
				_cd_art(r.get_center(), r.size.x * 0.5 - 6.0, _cover_tex(d.cover))
				_disc_marks(r.get_center(), r.size.x * 0.5 - 6.0, d)
				_chip_row(Rect2(r.position.x - 10.0, r.end.y + 8.0, r.size.x + 20.0, 32.0), d)
				var st := _binder_status(i)
				if not st.is_empty():
					var tw := _text_w(String(st[0]), 13, true) + 18.0
					var tr := Rect2(r.end.x - tw + 4.0, r.position.y - 2.0, tw, 24.0)
					_panel(tr, st[1], 12, Color(1, 1, 1, 0.5), 1)
					_text_center(tr, String(st[0]), 13, Color.WHITE, true)
				if binder_pick >= 0:
					if d.edition != "":
						draw_circle(r.get_center(), r.size.x * 0.5 - 6.0, Color(0, 0, 0, 0.6))
					else:
						if pocket.has_point(mouse):
							draw_arc(r.get_center(), r.size.x * 0.5 - 2.0, 0.0, TAU, 64, c_gold, 5.0, true)
						_register(pocket, _enhance.bind(i))
				if pocket.has_point(mouse):
					hover_disc = d
			_sleeve_gloss(r)
	var pages := maxi(1, (collection.size() + BINDER_SPREAD - 1) / BINDER_SPREAD)
	var ny := b.end.y + 30.0
	_hw_button(Rect2(b.position.x, ny, 220.0, 76.0), "Prev page", _flip_binder.bind(-1), binder_page > 0, Color("3d4148"), T_MD)
	_hw_button(Rect2(b.end.x - 220.0, ny, 220.0, 76.0), "Next page", _flip_binder.bind(1), binder_page < pages - 1, Color("3d4148"), T_MD)
	var first := binder_page * 2 + 1
	_text_center(Rect2(b.position.x, ny, b.size.x, 76.0), "Pages %d–%d of %d   ·   arrow keys flip, Esc closes" % [first, first + 1, pages * 2], T_MD, Color("c9ced6"), true)
	_draw_binder_summary(Rect2(1650.0, 60.0, 850.0, 1320.0))

func _draw_binder_summary(r: Rect2) -> void:
	_shadow(r, 10, 10.0)
	_panel(r, Color("f4efe4"), 10)
	var x := r.position.x + 36.0
	var w := r.size.x - 72.0
	_heavy(Vector2(x, r.position.y + 62.0), "Summary", T_XL, c_ink)
	_hw_button(Rect2(r.end.x - 196.0, r.position.y + 22.0, 160.0, 60.0), "Close", _toggle_binder, true, Color("8a8f98"), T_MD)
	var y := r.position.y + 110.0
	var genre_n: Array = []
	var genre_c: Array = []
	for g in D.GENRES.size():
		genre_n.append(D.GENRES[g])
		genre_c.append(Color(D.GENRE_COLORS[g]))
	y = _summary_bars(x, y, w, "GENRE", genre_n, genre_c, _counts(func(d): return d.genre, D.GENRES.size()))
	var era_c: Array = []
	for e in D.ERAS.size():
		era_c.append(Color("5d626a"))
	y = _summary_bars(x, y, w * 0.48, "DECADE", D.ERAS, era_c, _counts(func(d): return d.era, D.ERAS.size()))
	var sound_n: Array = []
	var sound_c: Array = []
	for v in range(D.BASE_SOUND[0], D.BASE_SOUND[1] + 1):
		sound_n.append("%d Sound" % v)
		sound_c.append(Color(D.SOUND_COLOR))
	var sy := y - (40.0 + D.ERAS.size() * 30.0)
	_summary_bars(x + w * 0.52, sy, w * 0.48, "BASE SOUND", sound_n, sound_c, _counts(func(d): return d.sound - D.BASE_SOUND[0], sound_n.size()))
	var keys: Array = D.ABILITIES.keys()
	var ab_n: Array = []
	var ab_c: Array = []
	for k in keys:
		ab_n.append(String(D.ABILITIES[k]["name"]))
		ab_c.append(Color(D.SOUND_COLOR if D.ABILITIES[k]["gain"] == "sound" else D.ENERGY_COLOR))
	ab_n.append("No ability")
	ab_c.append(Color("9aa0a6"))
	var ab := _counts(func(d): return keys.size() if d.ability == "" else keys.find(d.ability), ab_n.size())
	var half := (ab_n.size() + 1) / 2
	var y0 := y
	y = _summary_bars(x, y0, w * 0.48, "ABILITY", ab_n.slice(0, half), ab_c.slice(0, half), ab.slice(0, half), 26.0)
	_summary_bars(x + w * 0.52, y0, w * 0.48, " ", ab_n.slice(half), ab_c.slice(half), ab.slice(half), 26.0)
	var bands := {}
	for d in collection:
		bands[d.band] = int(bands.get(d.band, 0)) + 1
	var names: Array = bands.keys()
	names.sort_custom(func(a, b): return bands[a] > bands[b] or (bands[a] == bands[b] and a < b))
	_text(Vector2(x, y + 26.0), "BAND", T_XS, c_muted, true)
	_text_right(x + w, y + 26.0, "%d bands" % names.size(), T_XS, c_muted, true)
	var eds := {}
	for d in collection:
		if d.edition != "":
			eds[d.edition] = int(eds.get(d.edition, 0)) + 1
	var ed_txt := ", ".join(eds.keys().map(func(e): return "%d %s" % [eds[e], D.EDITIONS[e]["name"]]))
	_text(Vector2(x, r.position.y + 100.0), "Editions: " + (ed_txt if ed_txt != "" else "none"), T_XS, c_body, true)
	y += 40.0
	var rows := int((r.end.y - 30.0 - y) / 30.0)
	for k in mini(names.size(), rows * 2):
		var cx := x + (k / rows) * (w * 0.52)
		var cy := y + (k % rows) * 30.0
		var nm := String(names[k])
		_text(Vector2(cx, cy + 22.0), nm, T_SM, c_ink if int(bands[nm]) > 1 else c_body, int(bands[nm]) > 1)
		_text_right(cx + w * 0.46, cy + 22.0, "×%d" % int(bands[nm]), T_SM, c_ink, true)
	if names.size() > rows * 2:
		_text_i(Vector2(x, r.end.y - 20.0), "+%d more" % (names.size() - rows * 2), T_XS, c_muted)

func _counts(key: Callable, n: int) -> Array:
	var out: Array = []
	for k in n:
		out.append(0)
	for d in collection:
		var v := int(key.call(d))
		if v >= 0 and v < n:
			out[v] += 1
	return out

func _summary_bars(x: float, y: float, w: float, title: String, names: Array, cols: Array, counts: Array, row_h: float = 30.0) -> float:
	_text(Vector2(x, y + 26.0), title, T_XS, c_muted, true)
	y += 40.0
	var most := 1
	for c in counts:
		most = maxi(most, int(c))
	var lw := 0.0
	for nm in names:
		lw = maxf(lw, _text_w(String(nm), T_XS, true))
	lw += 14.0
	for k in names.size():
		var c := int(counts[k])
		var ry := y + k * row_h
		_text(Vector2(x, ry + row_h * 0.5 + _vc(font_bold, T_XS)), String(names[k]), T_XS, c_ink if c > 0 else c_muted, true)
		var bw := w - lw - 40.0
		var bar := Rect2(x + lw, ry + row_h * 0.2, bw, row_h * 0.6)
		_panel(bar, Color(c_ink, 0.07), 4)
		if c > 0:
			_panel(Rect2(bar.position, Vector2(maxf(8.0, bw * c / most), bar.size.y)), cols[k], 4)
		_text_right(x + w, ry + row_h * 0.5 + _vc(font_bold, T_SM), str(c), T_SM, c_ink if c > 0 else c_muted, true)
	return y + names.size() * row_h + 14.0

func _edition_marks(c: Vector2, rad: float, e: String) -> void:
	var ed: Dictionary = D.EDITIONS[e]
	var col := Color(ed["color"])
	match e:
		"holo":
			var hues := [Color("ff6ec7"), Color("ffd36e"), Color("6effa0"), Color("6ee7ff"), Color("a78bff"), Color("ff8a6e")]
			for i in hues.size():
				var a0 := clock * 0.4 + i * 0.9
				draw_arc(c, rad * (0.42 + i * 0.095), a0, a0 + 1.6, 24, Color(hues[i], 0.32), rad * 0.08, true)
				draw_arc(c, rad * (0.42 + i * 0.095), a0 + PI, a0 + PI + 1.2, 24, Color(hues[(i + 3) % hues.size()], 0.22), rad * 0.08, true)
		"signed":
			var pts := PackedVector2Array()
			for i in 40:
				var t := i / 39.0
				var x := c.x + rad * (-0.55 + t * 0.95)
				var y := c.y + rad * (0.2 - t * 0.12) + sin(t * TAU * 2.6) * rad * 0.07 + (rad * 0.05 if t < 0.2 else 0.0)
				pts.append(Vector2(x, y))
			draw_polyline(pts, Color(1, 1, 1, 0.55), rad * 0.06, true)
			draw_polyline(pts, Color("15161a"), rad * 0.035, true)
			draw_line(c + Vector2(-rad * 0.5, rad * 0.32), c + Vector2(rad * 0.3, rad * 0.28), Color("15161a"), rad * 0.025, true)
		"limited":
			draw_arc(c, rad - rad * 0.035, 0.0, TAU, 72, Color("e9b949"), rad * 0.06, true)
			draw_arc(c, rad - rad * 0.075, 0.0, TAU, 72, Color(1, 1, 1, 0.5), 1.5, true)
		"remaster":
			draw_arc(c, rad * 0.4, 0.0, TAU, 48, Color(col, 0.85), rad * 0.05, true)
		"mint":
			for p: Vector2 in [Vector2(0.45, -0.3), Vector2(-0.25, 0.55), Vector2(0.62, 0.32)]:
				var sc := c + p * rad
				var s := rad * 0.09
				draw_colored_polygon(PackedVector2Array([sc + Vector2(0, -s), sc + Vector2(s * 0.25, -s * 0.25), sc + Vector2(s, 0), sc + Vector2(s * 0.25, s * 0.25), sc + Vector2(0, s), sc + Vector2(-s * 0.25, s * 0.25), sc + Vector2(-s, 0), sc + Vector2(-s * 0.25, -s * 0.25)]), Color(1, 1, 1, 0.85))
	var fs := maxi(9, int(rad * 0.13))
	var text := String(ed["short"])
	var w := _text_w(text, fs, true) + rad * 0.16
	var h := rad * 0.24
	var tc := c + Vector2(rad * 0.62, -rad * 0.78)
	var pr := Rect2(tc.x - w * 0.5, tc.y - h * 0.5, w, h)
	_panel(Rect2(pr.position + Vector2(0, 2), pr.size), Color(0, 0, 0, 0.4), int(h * 0.5))
	_panel(pr, col, int(h * 0.5), Color(1, 1, 1, 0.75), 1)
	_text_center(pr, text, fs, Color.WHITE, true)

func _draw_services(r: Rect2) -> void:
	if services.is_empty():
		_text_i(Vector2(r.position.x, r.position.y + 40.0), "No work orders today.", T_SM, Color(1, 1, 1, 0.35))
		return
	var tw := (r.size.x - 30.0) / 2.0
	for i in services.size():
		var sv: Dictionary = services[i]
		var t := Rect2(r.position.x + i * (tw + 30.0), r.position.y, tw, r.size.y)
		_shadow(t, 4, 6.0)
		_panel(t, Color("f6e7dc"), 3)
		var x := t.position.x + 14.0
		while x < t.end.x - 8.0:
			draw_circle(Vector2(x, t.position.y + 10.0), 3.0, Color("3e2a1c"))
			x += 18.0
		draw_line(Vector2(t.position.x + 10.0, t.position.y + 20.0), Vector2(t.end.x - 10.0, t.position.y + 20.0), Color(0, 0, 0, 0.12), 1.0)
		_text(Vector2(t.position.x + 20.0, t.position.y + 48.0), "WORK ORDER  №%03d" % (gig_n * 10 + i + 1), T_XS, Color("b03a2e"), true)
		var title := ""
		var desc := ""
		match String(sv["kind"]):
			"enhance":
				var ed: Dictionary = D.EDITIONS[sv["edition"]]
				title = String(ed["name"])
				desc = "Make one album in your binder %s: %s" % [ed["name"], ed["text"]]
			"tweak":
				title = "Bench tweak"
				desc = "Raise one EQ fader by 1, or turn a Gain Stage or Exciter dial to any setting."
			"upgrade":
				title = "Unit upgrade"
				desc = "Take one rack unit to its next level (MK II, MK III)."
		_heavy(Vector2(t.position.x + 20.0, t.position.y + 92.0), title, T_LG, Color("22252a"))
		_wrap(Vector2(t.position.x + 20.0, t.position.y + 104.0), desc, tw - 150.0, 17, Color("4c5058"))
		var pr := Rect2(t.end.x - 112.0, t.end.y - 76.0, 92.0, 56.0)
		_panel(pr, Color(0, 0, 0, 0), 6, Color("b03a2e"), 3)
		_heavy_center(pr, "$%d" % int(sv["price"]), T_LG, Color("b03a2e"))
		var active := bench == i or binder_pick == i
		if bool(sv["sold"]):
			_panel(t, Color(0, 0, 0, 0.25), 3)
			_heavy_center(t, "DONE", T_HERO, Color(c_good, 0.7))
			continue
		var afford := cash >= int(sv["price"])
		if active:
			_panel(t.grow(5.0), Color(0, 0, 0, 0), 8, c_gold, 5)
		elif not afford:
			_panel(t, Color(0, 0, 0, 0.35), 3)
		elif ui_live and bench < 0 and install_queue.is_empty():
			if t.has_point(mouse):
				_panel(t.grow(4.0), Color(0, 0, 0, 0), 8, Color(c_gold, 0.8), 3)
			_register(t, _start_service.bind(i))
