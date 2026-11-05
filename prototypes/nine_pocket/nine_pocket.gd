extends "res://prototypes/nine_pocket/nine_pocket_ui.gd"

const D := preload("res://prototypes/nine_pocket/nine_pocket_data.gd")

const DRAG_MIN := 24.0
const DRAG_START := 14.0
const SETTLE_T := 0.14
const WELL_R := 106.0
const DISC_R := 96.0
const WELL_PITCH := 314.0
const CELL := 208.0
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
	var rule := {}
	var edition := ""
	var cdr := false
	var mix_cover := ""
	var rarity := "common"

var rng := RandomNumberGenerator.new()
var albums: Array = []
var collection: Array[Disc] = []
var draw_pile: Array[int] = []
var discard: Array[int] = []
var wallet: Array[int] = []
var tray: Array[int] = []
var held := -1
var rec_pop := 0.0
var drag_pending := false
var drag_active := false
var drag_kind := ""
var drag_idx := -1
var drag_disc := -1
var drag_pos := Vector2.ZERO
var drag_lift := 0.0
var drag_hover: Array = []
var settles: Array = []
var held_from := -1
var press_pos := Vector2.ZERO
var gig_n := 1
var cash := 0
var rack: Array = []
var gear_defs := {}
var deck_defs: Array = []
var shop_items: Array = []
var pack := {}
var pack_sel: Array[int] = []
var pack_t := 0.0
var pack_slide := 0.0
var pack_rig_open := false
var hold_key := ""
var hold_t := 0.0
var hold_rect := Rect2()
var hold_cb: Callable
var hold_targets: Array = []
var pack_burst := false
var pack_skipped := false
var pack_revealed: Array[int] = []
var pack_sparks: Array = []
var pack_fx: Array = []
var install_queue: Array = []
var install_price := 0
var install_src := -1
var reward := {}
var show_cash := 0
var next_uid := 1
var binder_open := false
var venue := {}
var last_venue := -1
var score_tot := 0
var score_live := 0
var resolving := false
var label_title := true
var sel_slot := -1
var set_res := {}
var pending_kit := 0
var flow_live := 1.0
var gear_sel := -1
var gate_pool: Array = []
var burn_mode := false
var burn_marks: Array[int] = []
var peek_open := false
var settings_open := false
var settings_tab := "scoring"
var anim_idx := 1
var peek_ids: Array[int] = []
var tuner_bonus := 0
var booed := false
var tour: Array = []
var tour_at := 0
var tour_path: Array[int] = []
var map_seed := 0
var forks_done := 0
var boss_venue: Dictionary = {}
var doomed: Array = []
var score_mode := "song"
var place_mode := "all"
var play_ctx: Dictionary = {}
var set_live := false
var play_order: Array = []
var sel_hand := -1
var count_slot := 0
var finale := 0
var finale_flow := 1.0
var song_pts := 0
const EQ_COLS := 16
const EQ_SEGS := 8
var eq_level: Array = []
var eq_peak: Array = []
var eq_hue: Array = []
var eq_prev_run := 0
var fin_t := -1.0
var fin_from := 0
var fin_to := 0
var fin_boomed := false
var fin_boom_t := 0.0
var fin_accum := 0.0
var fin_tick_t := 0.0
var fin_shake := 0.0
var fin_flash := 0.0
var pts_pulse := 0.0
var flow_pulse := 0.0
var sparks: Array = []
var tick_player: AudioStreamPlayer
var fork_gigs := 0
var fork_roads: Array = []
var road_stops: Array = []
var fork_towns: Array = []
var tour_cols := 1
var pickup := {}
var pickup_shake := 0.0
var pickups_since_gear := 0
var played: Array[int] = []
var call := {}
var song_slot := -1
var binder_pick := -1
var services: Array = []
var bench := -1
var binder_page := 0
var digs := 0
var dig_mode := false
var dig_marks: Array[int] = []
var dig_offer: Array[int] = []
var dig_slot := -1
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
var comp_flash: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var slot_flash: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var spin := 0.0
var font_marker: Font
var music_player: AudioStreamPlayer
var bg_player: AudioStreamPlayer
var bg_files: Array = []
var bg_idx := -1
var bg_gain := 0.0
var gig_done := false
var count_t := 0.0
var count_n := 0
var count_pop := 0.0
var audition_player: AudioStreamPlayer
var audition_target: Disc = null
var audition_cur: Disc = null
var audition_gain := 0.0
var music_t := 0.0
var menu_album: Dictionary = {}
var pile_with_hand := false
var link_log: Array = []
var menu_fade := 0.0
var menu_music := false
var album_music := {}
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

var r_changer := Rect2(820.0, 40.0, 1020.0, 660.0)
var r_score := Rect2(60.0, 40.0, 736.0, 1260.0)
var r_wallet := Rect2(820.0, 720.0, 1020.0, 580.0)
var r_side := Rect2(1350.0, 796.0, 490.0, 500.0)
var r_cash := Rect2(1880.0, 40.0, 620.0, 100.0)
var r_rack := Rect2(1880.0, 160.0, 620.0, 1030.0)
var r_actions := Rect2(1880.0, 1210.0, 620.0, 190.0)
var r_bin := Rect2(70.0, 200.0, 1000.0, 420.0)
var r_counter := Rect2(70.0, 690.0, 1000.0, 690.0)
var r_shelf := Rect2(1110.0, 180.0, 730.0, 1200.0)

func _ready() -> void:
	_ui_ready()
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	rng.randomize()
	_load_gear()
	_load_albums()
	_load_decks()
	_load_music()
	_load_prefs()
	_load_finale_sounds()
	_to_title()

func _load_prefs() -> void:
	var cf := ConfigFile.new()
	if cf.load(D.PREFS_PATH) == OK:
		var m := String(cf.get_value("game", "score_mode", "song"))
		score_mode = m if m in ["song", "end"] else "song"
		var pm := String(cf.get_value("game", "place_mode", "all"))
		place_mode = pm if pm in ["all", "one"] else "all"
		anim_idx = clampi(int(cf.get_value("game", "anim_speed", 1)), 0, D.ANIM_SCALE.size() - 1)

func _save_prefs() -> void:
	var cf := ConfigFile.new()
	cf.load(D.PREFS_PATH)
	cf.set_value("game", "score_mode", score_mode)
	cf.set_value("game", "place_mode", place_mode)
	cf.set_value("game", "anim_speed", anim_idx)
	cf.save(D.PREFS_PATH)

func _anim() -> float:
	return float(D.ANIM_SCALE[anim_idx])

func _set_place_mode(m: String) -> void:
	place_mode = m
	_save_prefs()

func _set_score_mode(m: String) -> void:
	score_mode = m
	_save_prefs()

func _set_anim(i: int) -> void:
	anim_idx = i
	_save_prefs()

func _open_settings() -> void:
	settings_open = true

func _close_settings() -> void:
	settings_open = false

func _load_finale_sounds() -> void:
	if sfx.has("click"):
		tick_player = AudioStreamPlayer.new()
		tick_player.stream = (sfx["click"] as AudioStreamPlayer).stream
		tick_player.volume_db = -8.0
		add_child(tick_player)
	var rate := 22050
	var n := int(rate * 0.7)
	var data := PackedByteArray()
	data.resize(n * 2)
	var ph := 0.0
	var nr := RandomNumberGenerator.new()
	nr.seed = 3
	for i in n:
		var t := float(i) / rate
		ph += TAU * (36.0 + 60.0 * exp(-t * 16.0)) / rate
		var v := sin(ph) * 0.95 * exp(-t * 6.5) * minf(1.0, t * 300.0) + nr.randf_range(-1.0, 1.0) * 0.08 * exp(-t * 45.0)
		data.encode_s16(i * 2, int(clampf(v, -1.0, 1.0) * 30000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.stereo = false
	w.data = data
	var pl := AudioStreamPlayer.new()
	pl.stream = w
	pl.volume_db = -1.0
	add_child(pl)
	sfx["boom"] = pl

func _score_lcd() -> Rect2:
	return Rect2(r_score.position.x + 40.0, r_score.position.y + 50.0, r_score.size.x - 80.0, 130.0)

func _pts_lcd() -> Rect2:
	return Rect2(r_score.position.x + 40.0, r_score.position.y + 540.0, 296.0, 104.0)

func _flow_lcd() -> Rect2:
	return Rect2(r_score.position.x + 40.0, r_score.position.y + 708.0, 296.0, 104.0)

func _tick_eq(delta: float) -> void:
	if eq_level.is_empty():
		for i in EQ_COLS:
			eq_level.append(0.0)
			eq_peak.append(0.0)
			eq_hue.append(0.0)
	for i in EQ_COLS:
		eq_level[i] = maxf(0.0, float(eq_level[i]) - delta * 1.5)
		eq_peak[i] = maxf(float(eq_level[i]), float(eq_peak[i]) - delta * 0.6)

func _kick_eq(power: float, flow: bool = false) -> void:
	if eq_level.is_empty():
		_tick_eq(0.0)
	for i in EQ_COLS:
		var bell := 1.0 - absf(float(i) - (EQ_COLS - 1) * 0.5) / EQ_COLS * 0.9
		var v := clampf(power * bell * rng.randf_range(0.55, 1.0), 0.0, 1.0)
		if v >= float(eq_level[i]):
			eq_hue[i] = 1.0 if flow else 0.0
		eq_level[i] = maxf(float(eq_level[i]), v)
		eq_peak[i] = maxf(float(eq_peak[i]), v)

func _eq_strip(r: Rect2) -> void:
	_inset(r, 6.0, Color("0b0c0e"))
	if eq_level.is_empty():
		return
	var cw := (r.size.x - 24.0) / EQ_COLS
	var sh := (r.size.y - 16.0) / EQ_SEGS
	for i in EQ_COLS:
		var lv := float(eq_level[i]) * EQ_SEGS
		var pk := int(ceil(float(eq_peak[i]) * EQ_SEGS)) - 1
		for k in EQ_SEGS:
			var t := float(k) / (EQ_SEGS - 1)
			var col := (Color(D.FLOW_COLOR) if float(eq_hue[i]) > 0.5 else Color(D.SOUND_COLOR)).lightened(t * 0.35)
			var on := float(k) < lv
			var sr := Rect2(r.position.x + 12.0 + i * cw, r.end.y - 8.0 - (k + 1) * sh + 2.0, cw - 4.0, sh - 3.0)
			_panel(sr, col if on else (Color(col.lightened(0.3), 0.9) if k == pk and pk >= 0 else Color(col, 0.1)), 2)

func _tick() -> void:
	if tick_player != null:
		tick_player.pitch_scale = rng.randf_range(1.0, 1.5)
		tick_player.play()

func _fin_u() -> float:
	return clampf((fin_t - (D.FIN_WIND * _anim())) / (D.FIN_STREAM * _anim()), 0.0, 1.0)

func _fin_value() -> int:
	if fin_boomed:
		return fin_to
	return fin_from + int(round((fin_to - fin_from) * pow(_fin_u(), 2.2)))

func _spawn_stream() -> void:
	var a := (_flow_lcd().get_center() + _pts_lcd().get_center()) * 0.5
	var b := _score_lcd().get_center()
	sparks.append({"kind": "stream", "a": a, "b": b, "t": 0.0, "life": 0.42, "bend": rng.randf_range(-160.0, 160.0), "col": Color(D.FLOW_COLOR).lightened(0.4), "r": rng.randf_range(5.0, 9.0), "p": a})

func _boom() -> void:
	fin_boomed = true
	fin_boom_t = fin_t
	score_tot = fin_to
	score_live = fin_to
	pts_pulse = 1.0
	if fin_to >= _gig_target():
		fin_shake = 0.3
	_sfx("boom")

func _tick_finale(delta: float) -> void:
	fin_t += delta
	var wind: float = (D.FIN_WIND * _anim())
	var end_stream: float = (D.FIN_WIND * _anim()) + (D.FIN_STREAM * _anim())
	if fin_t < wind:
		flow_pulse = maxf(flow_pulse, 0.5 + 0.5 * sin(fin_t * 14.0))
	elif fin_t < end_stream:
		var u := _fin_u()
		if fin_to >= _gig_target():
			fin_shake = maxf(fin_shake, 0.04 + 0.1 * u)
		fin_accum += delta * lerpf(10.0, 34.0, u)
		while fin_accum >= 1.0:
			fin_accum -= 1.0
			if fin_t < end_stream - 0.4:
				_spawn_stream()
		fin_tick_t -= delta
		if fin_tick_t <= 0.0 and tick_player != null:
			fin_tick_t = lerpf(0.12, 0.06, u)
			tick_player.pitch_scale = lerpf(0.9, 1.7, u)
			tick_player.play()
	elif not fin_boomed:
		_boom()
	if fin_boomed and fin_t - fin_boom_t >= (D.FIN_HOLD * _anim()):
		fin_t = -1.0
		resolving = false
		_end_show()

func _tick_sparks(delta: float) -> void:
	for i in range(sparks.size() - 1, -1, -1):
		var f: Dictionary = sparks[i]
		f["t"] = float(f["t"]) + delta
		if String(f["kind"]) == "stream":
			var u := clampf(float(f["t"]) / float(f["life"]), 0.0, 1.0)
			var a: Vector2 = f["a"]
			var b: Vector2 = f["b"]
			f["p"] = a.lerp(b, u) + Vector2(0.0, sin(u * PI) * float(f["bend"]))
			if u >= 1.0:
				pts_pulse = maxf(pts_pulse, 0.7)
				sparks.remove_at(i)
		else:
			var v: Vector2 = f["v"]
			v.y += 1800.0 * delta
			f["v"] = v
			f["p"] = Vector2(f["p"]) + v * delta
			if float(f["t"]) >= float(f["life"]):
				sparks.remove_at(i)

func _draw_finale() -> void:
	if fin_flash > 0.0:
		draw_rect(Rect2(-800.0, -800.0, UI_W + 1600.0, UI_H + 1600.0), Color(1, 0.97, 0.85, 0.7 * fin_flash))
	for f: Dictionary in sparks:
		var p: Vector2 = f["p"]
		var col: Color = f["col"]
		if String(f["kind"]) == "stream":
			draw_circle(p, float(f["r"]) * 1.8, Color(col, 0.25))
			draw_circle(p, float(f["r"]), col)
		else:
			var a := clampf(1.0 - float(f["t"]) / float(f["life"]), 0.0, 1.0)
			var v: Vector2 = f["v"]
			draw_line(p, p - v * 0.02, Color(col, a), float(f["r"]))
	if fin_t < 0.0:
		return
	var c := _score_lcd().get_center()
	var mid := Vector2(r_score.get_center().x, r_score.position.y + 1000.0)
	var txt := "FLOW x%s" % _ff(finale_flow)
	var col2 := Color(D.FLOW_COLOR).lightened(0.4)
	var pop := 1.0 + 0.1 * sin(fin_t * 10.0) * (1.0 if not fin_boomed else 0.0)
	if fin_boomed:
		var ratio := float(fin_to) / float(_gig_target())
		var tier := 3 if ratio >= D.TIER_GREAT else (2 if ratio >= D.TIER_GOOD else (1 if ratio >= 1.0 else 0))
		txt = ["FALLING SHORT", "TARGET CLEARED", "BIG APPLAUSE!", "ENCORE!"][tier]
		col2 = [c_bad.lightened(0.3), Color("7fe0a0"), Color("f2c14e"), Color("ffd96a")][tier]
		pop = 1.0 + 0.12 * maxf(0.0, 1.0 - (fin_t - fin_boom_t) * 3.0)
	var fs := int(T_HERO * pop)
	var w := _heavy_w(txt, fs)
	_panel(Rect2(mid.x - w * 0.5 - 30.0, mid.y - fs * 0.9, w + 60.0, fs * 1.5), Color(0.05, 0.06, 0.08, 0.85), int(fs * 0.4))
	_heavy_center(Rect2(mid.x - w * 0.5 - 30.0, mid.y - fs * 0.9, w + 60.0, fs * 1.5), txt, fs, col2)

func _process(delta: float) -> void:
	pts_pulse = maxf(0.0, pts_pulse - delta * 2.5)
	_tick_eq(delta)
	_tick_drag(delta)
	_tick_bg(delta)
	_tick_count(delta)
	_tick_pack(delta)
	_tick_hold(delta)
	_tick_audition(delta)
	rec_pop = maxf(0.0, rec_pop - delta * 4.0)
	flow_pulse = maxf(0.0, flow_pulse - delta * 2.5)
	fin_flash = maxf(0.0, fin_flash - delta * 2.2)
	fin_shake = maxf(0.0, fin_shake - delta * (0.5 if fin_t >= 0.0 and not fin_boomed else 2.2))
	if not sparks.is_empty():
		_tick_sparks(delta)
	if fin_t >= 0.0:
		_tick_finale(delta)
	message_t = maxf(0.0, message_t - delta)
	pickup_shake = maxf(0.0, pickup_shake - delta)
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
				step_t = maxf(D.STEP_MIN, D.STEP_FIRST - D.STEP_RAMP * step_i) * _anim()
			elif step_i == steps.size():
				step_i += 1
				step_t = D.SONG_TAIL * _anim()
				music_t = minf(music_t, D.SONG_TAIL * _anim())
			elif music_t <= 0.0:
				_finish_song()
		music_t = maxf(0.0, music_t - delta)
		if music_player != null and music_player.playing:
			music_player.volume_db = linear_to_db(clampf(music_t / D.MUSIC_FADE, 0.0, 1.0))
	if menu_fade > 0.0:
		menu_fade = maxf(0.0, menu_fade - delta)
		if music_player != null and music_player.playing:
			music_player.volume_db = linear_to_db(clampf(menu_fade / D.MENU_FADE, 0.0001, 1.0))
		if menu_fade <= 0.0:
			_music_stop()
	_ui_process(delta)

func _unhandled_input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton:
		var mb := ev as InputEventMouseButton
		if not pack.is_empty() and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT and not _pack_ready():
			pack_skipped = true
			pack_t = _pack_ready_time()
			return
		if fin_t >= 0.0 and mb.pressed and not fin_boomed:
			fin_t = (D.FIN_WIND * _anim()) + (D.FIN_STREAM * _anim())
			return
		if binder_open and mb.pressed and (mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			_flip_binder(-1 if mb.button_index == MOUSE_BUTTON_WHEEL_UP else 1)
		elif mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			press_pos = _ui_mouse()
			if not _try_drag_press(press_pos):
				_ui_click(press_pos)
		elif mb.button_index == MOUSE_BUTTON_LEFT and (drag_active or drag_pending):
			if drag_active:
				_end_drag()
			else:
				drag_pending = false
				_ui_click(press_pos)
		elif mb.button_index == MOUSE_BUTTON_LEFT and (held >= 0 or gear_sel >= 0) and press_pos.distance_to(_ui_mouse()) > DRAG_MIN:
			_ui_click(_ui_mouse())
		elif mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			_cancel()
	elif ev is InputEventKey and ev.pressed and not ev.echo:
		var key := (ev as InputEventKey).keycode
		if key == KEY_ESCAPE:
			_cancel()
		elif key == KEY_B and phase in ["show", "shop", "map", "fork"]:
			_toggle_binder()
		elif binder_open and key == KEY_LEFT:
			_flip_binder(-1)
		elif binder_open and key == KEY_RIGHT:
			_flip_binder(1)

func _cancel() -> void:
	if drag_active or drag_pending:
		_cancel_drag()
		return
	if not dig_offer.is_empty():
		return
	if binder_open:
		binder_open = false
		binder_pick = -1
		return
	if peek_open:
		_close_peek()
		return
	if burn_mode:
		burn_mode = false
		burn_marks.clear()
		message_t = 0.0
		return
	if gear_sel >= 0:
		gear_sel = -1
		return
	if bench >= 0:
		bench = -1
		return
	if not install_queue.is_empty():
		install_queue.pop_front()
		install_price = 0
		install_src = -1
	_return_held()
	sel_slot = -1
	sel_hand = -1
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

func _load_gear() -> void:
	gear_defs.clear()
	if not FileAccess.file_exists(D.GEAR_PATH):
		push_error("Missing %s" % D.GEAR_PATH)
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(D.GEAR_PATH))
	if data is Array:
		for u: Dictionary in data:
			gear_defs[String(u["id"])] = u

func _gp(id: String, key: String) -> float:
	return float((gear_defs[id]["params"] as Dictionary).get(key, 0.0))

func _gs(id: String, key: String) -> String:
	return String((gear_defs[id]["params"] as Dictionary).get(key, ""))

func _gear_fmt(def: Dictionary) -> String:
	var t := String(def["text"])
	var vals: Dictionary = (def["params"] as Dictionary).duplicate()
	var rl: Dictionary = def.get("rule", {})
	for k in ["amount", "cap", "aparam", "rparam", "rn"]:
		if rl.has(k):
			vals[k] = rl[k]
	for k in vals.keys():
		var v = vals[k]
		t = t.replace("{%s}" % k, v if v is String else _ff(float(v)))
	return t

func _read_cards() -> Array:
	if not FileAccess.file_exists(D.CARDS_PATH):
		return []
	var data = JSON.parse_string(FileAccess.get_file_as_string(D.CARDS_PATH))
	return data if data is Array else []

func _card_to_album(c: Dictionary) -> Dictionary:
	var band := String(c.get("band", ""))
	var rule := {"condition": String(c.get("condition", "always")), "cparam": String(c.get("cond_param", "")), "effect": String(c.get("effect", "none")), "value": float(c.get("value", 0.0)), "target": String(c.get("target", "self")), "tparam": String(c.get("target_param", ""))}
	return {"id": String(c.get("id", "")), "title": String(c.get("title", "")), "orig": String(c.get("title", "")), "band": band, "cover": String(c.get("cover", "")), "song": String(c.get("song", "")), "genre": maxi(0, D.GENRES.find(String(c.get("genre", "")))), "era": maxi(0, D.ERAS.find(String(c.get("decade", "")))), "label": (absi(band.hash()) / 7) % D.LABELS.size(), "points": int(c.get("points", 3)), "rule": rule, "rarity": String(c.get("rarity", "common"))}

func _legacy_rule(effect: String, cv: int) -> Dictionary:
	var p := ""
	if effect.ends_with("genre") or effect == "fans" or effect == "anthem":
		p = D.GENRES[clampi(cv, 0, D.GENRES.size() - 1)]
	elif effect.ends_with("decade"):
		p = D.ERAS[clampi(cv, 0, D.ERAS.size() - 1)]
	return _legacy_rule_named(effect, p)

func _legacy_rule_named(effect: String, p: String) -> Dictionary:
	var r := {"condition": "always", "cparam": "", "effect": "none", "value": 0.0, "target": "self", "tparam": ""}
	match effect:
		"set1", "set2":
			r["condition"] = effect
			r["effect"] = "points"
			r["value"] = float(D.SET_BONUS)
		"odd", "even":
			r["condition"] = effect
			r["effect"] = "points"
			r["value"] = float(D.SIDE_BONUS)
		"opener":
			r["condition"] = "first"
			r["effect"] = "mult"
			r["value"] = D.OPENER_MULT
		"closer":
			r["condition"] = "last"
			r["effect"] = "mult"
			r["value"] = D.CLOSER_MULT
		"after_genre", "after_decade":
			r["condition"] = "prev_is"
			r["cparam"] = p
			r["effect"] = "mult"
			r["value"] = D.AFTER_MULT
		"above_genre", "above_decade":
			r["condition"] = "above_is"
			r["cparam"] = p
			r["effect"] = "mult"
			r["value"] = D.ABOVE_MULT
		"hype":
			r["effect"] = "flow_add"
			r["value"] = D.AMP_ADD
			r["target"] = "set"
		"boost":
			r["effect"] = "flow_mult"
			r["value"] = D.SURGE_MULT
			r["target"] = "set"
		"fans":
			r["condition"] = "per_before"
			r["cparam"] = p
			r["effect"] = "flow_add"
			r["value"] = D.FANS_FLOW
			r["target"] = "set"
		"anthem":
			r["effect"] = "points"
			r["value"] = float(D.ANTHEM_ADD)
			r["target"] = "later_genre"
			r["tparam"] = p
		"mirror":
			r["effect"] = "copy"
	return r

func _load_albums() -> void:
	for c in _read_cards():
		albums.append(_card_to_album(c))
	if albums.is_empty():
		_legacy_albums()

func _legacy_albums() -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string(D.CATALOG))
	if not data is Array:
		push_error("Missing %s: run tools/make_covers.gd" % D.CATALOG)
		return
	var real := {}
	for a in data:
		var gname := String(a["genre"])
		if not real.has(gname):
			real[gname] = []
		real[gname].append(a)
	for gname: String in D.CATALOG_DATA.GENRES:
		var g := D.GENRES.find(gname)
		if g < 0 or not real.has(gname):
			continue
		var by_band := {}
		for rc0: Dictionary in real[gname]:
			if not by_band.has(rc0["band"]):
				by_band[rc0["band"]] = []
			by_band[rc0["band"]].append(rc0)
		var covers_g: Array = []
		for bk in by_band.keys():
			covers_g.append_array(by_band[bk])
		var cat_g: Array = D.CATALOG_DATA.albums_of_genre(gname)
		for k in mini(covers_g.size(), cat_g.size()):
			var rc: Dictionary = covers_g[k]
			var ca: Dictionary = cat_g[k]
			var h := absi(String(rc["band"]).hash())
			var e0 := D.ERAS.find(String(ca["decade"]))
			var rgn := RandomNumberGenerator.new()
			rgn.seed = absi(String(rc["cover"]).hash())
			var cr := _roll_cond(rgn, "")
			albums.append({"title": ca["album"], "orig": rc["album"], "band": rc["band"], "cover": rc["cover"], "genre": g, "era": e0, "label": (h / 7) % D.LABELS.size(), "points": cr["points"], "rule": _legacy_rule(String(cr["cond"]), int(cr["cond_v"]))})

func _roll_cond(rg: RandomNumberGenerator, cname: String) -> Dictionary:
	if cname == "":
		var tot := 0
		for ck in D.COND_WEIGHTS:
			tot += int(D.COND_WEIGHTS[ck])
		var roll := rg.randi_range(0, tot - 1)
		for ck in D.COND_WEIGHTS:
			roll -= int(D.COND_WEIGHTS[ck])
			if roll < 0:
				cname = String(ck)
				break
	var cv := 0
	if cname.ends_with("genre") or cname == "fans" or cname == "anthem":
		cv = rg.randi_range(0, D.GENRES.size() - 1)
	elif cname.ends_with("decade"):
		cv = rg.randi_range(0, D.ERAS.size() - 1)
	return {"cond": cname, "cond_v": cv, "points": int(D.COND_POINTS[cname])}

func _music_files(dir: String, out: Array) -> void:
	for sub in DirAccess.get_directories_at(dir):
		_music_files(dir.path_join(sub), out)
	var seen := {}
	for f in DirAccess.get_files_at(dir):
		var name := f.trim_suffix(".import").trim_suffix(".remap")
		if name.get_extension().to_lower() in ["mp3", "ogg", "wav"] and not seen.has(name):
			seen[name] = true
			out.append(dir.path_join(name))

func _music_key(s: String) -> String:
	return " ".join(s.to_lower().split(" ", false))

func _load_music() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.finished.connect(_on_music_finished)
	bg_player = AudioStreamPlayer.new()
	bg_player.volume_db = -80.0
	add_child(bg_player)
	_music_files(D.BG_DIR, bg_files)
	audition_player = AudioStreamPlayer.new()
	audition_player.volume_db = -80.0
	add_child(audition_player)
	var files: Array = []
	_music_files(D.MUSIC_DIR, files)
	for a: Dictionary in albums:
		if String(a.get("song", "")) != "":
			album_music[a["cover"]] = String(a["song"])
			continue
		var key := _music_key("%s - %s" % [a["band"], a["orig"]])
		for f: String in files:
			var base := _music_key(f.get_file().get_basename())
			if base == key or base.begins_with(key + " -"):
				album_music[a["cover"]] = f
				break

func _bg_next() -> void:
	if bg_files.is_empty() or bg_player == null:
		return
	bg_idx = (bg_idx + 1) % bg_files.size() if bg_idx >= 0 else rng.randi_range(0, bg_files.size() - 1)
	var stream := _music_stream(String(bg_files[bg_idx]))
	if stream == null:
		return
	if bg_files.size() == 1 and "loop" in stream:
		stream.loop = true
	bg_player.stream = stream
	bg_player.stream_paused = false
	bg_player.play(0.0)

func _bg_wanted() -> bool:
	if resolving or playing or (_one_mode() and set_live):
		return false
	if audition_target != null or audition_cur != null or audition_gain > 0.02:
		return false
	if gig_done and phase in ["show", "end", "result", "over", "won"]:
		return false
	return true

func _tick_bg(delta: float) -> void:
	if bg_player == null or bg_files.is_empty():
		return
	if not (phase in ["show", "end", "result", "over", "won"]):
		gig_done = false
	if _bg_wanted():
		if bg_player.stream_paused:
			bg_player.stream_paused = false
		elif not bg_player.playing:
			_bg_next()
		bg_gain = move_toward(bg_gain, 1.0, delta / D.BG_FADE_IN)
	else:
		bg_gain = move_toward(bg_gain, 0.0, delta / D.BG_FADE_OUT)
		if bg_gain <= 0.0 and bg_player.playing:
			bg_player.stream_paused = true
	bg_player.volume_db = linear_to_db(maxf(bg_gain, 0.0001)) + D.BG_DB

func _tick_count(delta: float) -> void:
	count_pop = maxf(0.0, count_pop - delta * 3.0)
	if count_t <= 0.0:
		return
	count_t -= delta
	var n := int(ceil(count_t / D.COUNT_STEP))
	if n != count_n and n > 0:
		count_n = n
		count_pop = 1.0
		if tick_player != null:
			tick_player.pitch_scale = 0.8 + 0.25 * (4 - n)
			tick_player.play()
	if count_t <= 0.0:
		count_n = 0
		_start_slot(count_slot)

func _draw_countdown() -> void:
	if count_n <= 0:
		return
	var c := r_changer.get_center()
	var frac := 1.0 - fposmod(count_t, D.COUNT_STEP) / D.COUNT_STEP
	draw_circle(c, 180.0, Color(0.05, 0.06, 0.08, 0.72))
	draw_arc(c, 172.0, -PI * 0.5, -PI * 0.5 + TAU * frac, 64, c_gold, 8.0, true)
	var sz := int(T_HERO * 1.7 * (1.0 + 0.3 * count_pop))
	_heavy_center(Rect2(c.x - 180.0, c.y - 130.0, 360.0, 260.0), str(count_n), sz, Color("f4efe4"))

func _audition(d: Disc) -> void:
	if d != null and not d.cdr and ui_live:
		audition_target = d

func _tick_audition(delta: float) -> void:
	if audition_player == null:
		return
	var tgt := audition_target
	if tgt != audition_cur:
		audition_gain = move_toward(audition_gain, 0.0, delta / 0.15)
		if audition_gain <= 0.0:
			audition_player.stop()
			audition_cur = null
			if tgt != null:
				var stream := _music_stream(_music_for(tgt))
				if stream != null:
					audition_cur = tgt
					audition_player.stream = stream
					var len := stream.get_length()
					audition_player.play(rng.randf_range(0.0, len - 20.0) if len > 25.0 else 0.0)
	else:
		audition_gain = move_toward(audition_gain, 1.0 if tgt != null else 0.0, delta / (0.25 if tgt != null else 0.3))
		if tgt == null and audition_gain <= 0.0 and audition_player.playing:
			audition_player.stop()
	audition_player.volume_db = linear_to_db(maxf(audition_gain, 0.0001)) + D.AUDITION_DB

func _music_for(d: Disc) -> String:
	return String(album_music.get(d.mix_cover if d.cdr else d.cover, ""))

func _on_music_finished() -> void:
	if menu_music and phase in ["title", "kits", "decks"] and menu_fade <= 0.0:
		music_player.play(0.0)

func _music_stream(path: String) -> AudioStream:
	var stream: AudioStream
	if ResourceLoader.exists(path):
		stream = load(path)
	elif path.get_extension().to_lower() == "mp3":
		var mp3 := AudioStreamMP3.new()
		mp3.data = FileAccess.get_file_as_bytes(path)
		stream = mp3
	return stream

func _music_start(d: Disc) -> void:
	music_t = D.MUSIC_SECONDS
	menu_music = false
	menu_fade = 0.0
	var path := _music_for(d)
	if path == "" or music_player == null:
		return
	var stream := _music_stream(path)
	if stream == null:
		return
	music_player.stream = stream
	music_player.volume_db = 0.0
	music_player.play(rng.randf_range(0.0, maxf(0.0, stream.get_length() - D.MUSIC_SECONDS - 1.0)))

func _menu_song() -> void:
	menu_music = false
	menu_fade = 0.0
	_music_stop()
	menu_album = {}
	if not albums.is_empty():
		menu_album = albums[rng.randi_range(0, albums.size() - 1)]

func _menu_fade_out() -> void:
	if menu_music and music_player != null and music_player.playing:
		menu_fade = D.MENU_FADE
	menu_music = false

func _music_stop() -> void:
	if music_player != null:
		music_player.stop()

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
	d.sound = int(a["points"])
	d.rule = (a["rule"] as Dictionary).duplicate()
	d.rarity = String(a.get("rarity", "common"))
	if rng.randf() < D.EDITION_CHANCE:
		var eds: Array = D.EDITIONS.keys()
		d.edition = eds[rng.randi_range(0, eds.size() - 1)]
	return d

func _resolve_mix(d: Disc) -> void:
	var a: Dictionary = albums[rng.randi_range(0, albums.size() - 1)]
	d.genre = a["genre"]
	d.era = a["era"]
	d.mix_cover = a["cover"]

func _reset_mixes() -> void:
	for d in collection:
		if d.cdr:
			d.genre = -1
			d.era = -1
			d.mix_cover = ""

func _make_cdr() -> Disc:
	var d := Disc.new()
	d.uid = next_uid
	next_uid += 1
	d.title = "Blank CD-R"
	d.band = ""
	d.cover = ""
	d.genre = -1
	d.era = -1
	d.label = rng.randi_range(0, D.LABELS.size() - 1)
	d.sound = D.CDR_POINTS
	d.cdr = true
	return d

func _roll_rarity() -> String:
	var tot := 0
	for k in D.RARITY_WEIGHTS:
		tot += int(D.RARITY_WEIGHTS[k])
	var roll := rng.randi_range(0, tot - 1)
	for k in D.RARITY_WEIGHTS:
		roll -= int(D.RARITY_WEIGHTS[k])
		if roll < 0:
			return String(k)
	return "common"

func _pick_card(g: int, e: int, rarity: String, used: Array) -> Dictionary:
	var pool: Array = albums.filter(func(a): return not a.get("id", a["cover"]) in used)
	if pool.is_empty():
		pool = albums
	var steps: Array = []
	if rarity != "":
		steps = [[g, e, rarity], [g, -1, rarity], [-1, e, rarity], [-1, -1, rarity]]
	steps.append_array([[g, e, ""], [g, -1, ""], [-1, -1, ""]])
	for st: Array in steps:
		var cand: Array = pool.filter(func(a): return (int(st[0]) < 0 or int(a["genre"]) == int(st[0])) and (int(st[1]) < 0 or int(a["era"]) == int(st[1])) and (String(st[2]) == "" or String(a.get("rarity", "")) == String(st[2])))
		if not cand.is_empty():
			return (cand[rng.randi_range(0, cand.size() - 1)] as Dictionary).duplicate()
	return (albums[0] as Dictionary).duplicate()

func _random_albums(n: int, g0: int = -1, e0: int = -1) -> Array:
	var out: Array = []
	var used: Array = []
	for k in n:
		var g := g0 if k == 0 else -1
		var e := e0 if k == 0 else -1
		var a := _pick_card(g, e, _roll_rarity(), used)
		used.append(a.get("id", a["cover"]))
		out.append(a)
	return out

func _common(key: String, count: int) -> Array:
	var counts := {}
	for d in collection:
		if d.cdr:
			continue
		var v: int = d.genre if key == "genre" else d.era
		counts[v] = int(counts.get(v, 0)) + 1
	var out: Array = counts.keys().filter(func(v): return int(counts[v]) >= count)
	return out if not out.is_empty() else counts.keys()

func _gear_full(g: Dictionary) -> bool:
	return String(gear_defs[g["id"]]["size"]) == "full"

func _gear_cells(id: String) -> int:
	return 2 if String(gear_defs[id]["size"]) == "full" else 1

func _rand_pair(avoid: Array = []) -> Array:
	var pr: Array = []
	for _try in 20:
		var a := rng.randi_range(0, D.GENRES.size() - 1)
		var b := rng.randi_range(0, D.GENRES.size() - 2)
		if b >= a:
			b += 1
		pr = [a, b]
		if pr != avoid:
			break
	return pr

func _make_gear(id: String) -> Dictionary:
	var g := {"id": id, "used": 0, "broken": false}
	match id:
		"genre_eq":
			var lv: Array = D.EQ_START.duplicate()
			_shuffle(lv)
			g["levels"] = lv
		"decade_eq":
			var lv2: Array = D.EQ_ERA_START.duplicate()
			_shuffle(lv2)
			g["levels"] = lv2
		"octave", "sampler":
			var p1 := _rand_pair()
			g["pairs"] = [p1, _rand_pair(p1)]
		"vintage", "feedback":
			g["count"] = 0
		"piggy":
			g["pot"] = 0
	return g

func _gear_text(g: Dictionary) -> String:
	var id := String(g["id"])
	if g.has("pairs"):
		var pr: Array = g["pairs"][0]
		if id == "octave":
			return "Songs of %s also count as %s." % [D.GENRES[int(pr[0])], D.GENRES[int(pr[1])]]
		return "Songs of %s pay $1 when they follow %s." % [D.GENRES[int(pr[0])], D.GENRES[int(pr[1])]]
	return _gear_fmt(gear_defs[id])

func _gear_max(_g: Dictionary) -> int:
	return 0

func _owned_gear() -> Array:
	var out: Array = []
	for g: Dictionary in rack:
		if not g.is_empty():
			out.append(g["id"])
	for g: Dictionary in install_queue:
		out.append(g["id"])
	return out

func _gear_pool() -> Array:
	return gear_defs.keys().filter(func(id): return bool(gear_defs[id].get("enabled", true)))

func _random_gear_ids(n: int, exclude: Array = []) -> Array:
	var owned := _owned_gear()
	var ids: Array = _gear_pool().filter(func(id): return not id in owned and not id in exclude)
	_shuffle(ids)
	return ids.slice(0, n)

func _slot_taken(i: int) -> bool:
	if not rack[i].is_empty():
		return true
	return i % 2 == 1 and not rack[i - 1].is_empty() and _gear_full(rack[i - 1])

func _anchor(i: int) -> int:
	if rack[i].is_empty() and i % 2 == 1 and not rack[i - 1].is_empty() and _gear_full(rack[i - 1]):
		return i - 1
	return i

func _can_fit(id: String) -> bool:
	if _gear_cells(id) == 2:
		for b in D.RACK_SLOTS / 2:
			if not _slot_taken(b * 2) and not _slot_taken(b * 2 + 1):
				return true
		return false
	for i in D.RACK_SLOTS:
		if not _slot_taken(i):
			return true
	return false

func _place_free(g: Dictionary) -> bool:
	if _gear_full(g):
		for b in D.RACK_SLOTS / 2:
			if not _slot_taken(b * 2) and not _slot_taken(b * 2 + 1):
				rack[b * 2] = g
				return true
		return false
	for i in D.RACK_SLOTS:
		if not _slot_taken(i):
			rack[i] = g
			return true
	return false

func _install_anchor(g: Dictionary, slot: int) -> int:
	if not _gear_full(g):
		return _anchor(slot)
	var a := (slot / 2) * 2
	var count := 0
	if not rack[a].is_empty():
		count += 1
	if not rack[a + 1].is_empty():
		count += 1
	return a if count < 2 else -1

func _put_unit(g: Dictionary, t: int) -> void:
	if _gear_full(g):
		rack[t] = g
		rack[t + 1] = {}
	else:
		rack[t] = g

func _chain() -> Array:
	var out: Array = []
	for i in rack.size():
		if not rack[i].is_empty() and not bool(rack[i].get("broken", false)):
			out.append(i)
	return out

func _gear_map() -> Dictionary:
	var out := {}
	var ch := _chain()
	for k in ch.size():
		var ci: int = ch[k]
		var g: Dictionary = rack[ci]
		var m := 1
		if k > 0 and String(rack[ch[k - 1]]["id"]) == "splitter" and String(g["id"]) != "splitter":
			m = 2
		out[String(g["id"])] = {"g": g, "ci": ci, "m": m, "left": k}
	return out

func _gear_m(id: String) -> int:
	if _bay_of(id) < 0:
		return 0
	var gm := _gear_map()
	return int(gm[id]["m"]) if gm.has(id) else 0

func _octave_pairs() -> Array:
	if _bay_of("octave") < 0:
		return []
	var gm := _gear_map()
	if not gm.has("octave"):
		return []
	return ((gm["octave"]["g"] as Dictionary)["pairs"] as Array).slice(0, int(gm["octave"]["m"]))

func _in_genre(d: Disc, gi: int) -> bool:
	if d.genre < 0 or gi < 0:
		return false
	if d.genre == gi:
		return true
	for pr: Array in _octave_pairs():
		if int(pr[0]) == d.genre and int(pr[1]) == gi:
			return true
	return false

func _nm_nb(d: Disc, nm: String) -> bool:
	if _name_matches(d, nm):
		return true
	return d.genre >= 0 and String(D.GENRES[d.genre]) == "Jazz" and D.GENRES.has(nm) and _bay_of("sax") >= 0

func _request_pts() -> int:
	var m := _gear_m("request")
	return D.REQUEST + (int(_gp("request", "pays")) - D.REQUEST) * m if m > 0 else D.REQUEST

func _gate_ignored() -> Array:
	var m := _gear_m("gate")
	if m <= 0 or _boss_kind() == "hates":
		return []
	return gate_pool.slice(0, m * int(_gp("gate", "count")))

func _hand_genre_count() -> int:
	var seen := {}
	for i in wallet + tray:
		if i >= 0:
			var d: Disc = collection[i]
			if d.genre >= 0:
				seen[d.genre] = true
	return seen.size()

func _stored_flow(gm: Dictionary) -> float:
	var f := 0.0
	for id: String in ["vintage", "feedback"]:
		if gm.has(id):
			f += float((gm[id]["g"] as Dictionary).get("count", 0)) * _gp(id, "store") * float(gm[id]["m"])
	return f

func _gear_status(g: Dictionary, slot: int) -> String:
	var gm := _gear_map()
	var id := String(g["id"])
	var m: int = int(gm[id]["m"]) if gm.has(id) else 1
	var rl: Dictionary = gear_defs[id].get("rule", {})
	if String(rl.get("per", "")) == "units_left" and String(rl.get("effect", "")) == "flow":
		var left := int(gm[id]["left"]) if gm.has(id) else 0
		return "+%s flow per song" % _ff(float(rl["amount"]) * left * m)
	match id:
		"vintage", "feedback":
			return "Stored: +%s flow" % _ff(float(g.get("count", 0)) * _gp(id, "store") * m)
		"piggy":
			return "Pot: $%d" % int(g.get("pot", 0))
		"gate":
			var ig := _gate_ignored()
			if phase != "show" and phase != "end":
				return ""
			if _boss_kind() == "hates":
				return "Offline: the boss hates"
			if ig.is_empty():
				return "Nothing to ignore"
			return "Ignoring " + ", ".join(ig.map(func(t): return String(t[1])))
		"splitter":
			var ch := _chain()
			var at := ch.find(slot)
			if at >= 0 and at + 1 < ch.size():
				return "Copying: " + String(gear_defs[rack[ch[at + 1]]["id"]]["name"])
			return "Nothing to its right"
		"octave", "sampler":
			if m > 1 and g.has("pairs"):
				var pr: Array = g["pairs"][1]
				return "Also: %s / %s" % [D.GENRES[int(pr[0])], D.GENRES[int(pr[1])]]
	return ""

func _new_run(kit_i: int = 0, deck: Dictionary = {}) -> void:
	_menu_fade_out()
	collection.clear()
	next_uid = 1
	var kit: Dictionary = D.KITS[kit_i]
	var dk: Dictionary = deck
	if dk.is_empty():
		var all := _decks()
		dk = all[rng.randi_range(0, all.size() - 1)]
	for d: Disc in _deck_discs(dk):
		collection.append(d)
	rack.clear()
	for k in D.RACK_SLOTS:
		rack.append({})
	_place_free(_make_gear(String(kit["gear"])))
	cash = D.START_CASH
	gig_n = 1
	plays = {}
	pack = {}
	install_queue.clear()
	last_venue = -1
	pickups_since_gear = 0
	_make_tour()
	message_t = 0.0
	if D.USE_FORK:
		_make_forks()
		_back_on_road()
	else:
		phase = "map"

func _load_decks() -> void:
	deck_defs.clear()
	if FileAccess.file_exists(D.DECKS_PATH):
		var data = JSON.parse_string(FileAccess.get_file_as_string(D.DECKS_PATH))
		if data is Array:
			for dk: Dictionary in data:
				if bool(dk.get("enabled", true)):
					deck_defs.append(dk)
	if deck_defs.is_empty():
		var all := {}
		for a: Dictionary in albums:
			all[String(a.get("id", ""))] = 1
		deck_defs.append({"id": "all", "name": "Every card", "idea": "One of every card.", "mixes": 0, "cards": all})
	deck_defs = deck_defs.slice(0, D.DECKS_SHOWN)

func _decks() -> Array:
	return deck_defs

func _album_by_id(id: String) -> Dictionary:
	for a: Dictionary in albums:
		if String(a.get("id", "")) == id:
			return a
	return {}

func _deck_size(deck: Dictionary) -> int:
	var n := 0
	var cards: Dictionary = deck.get("cards", {})
	for id in cards.keys():
		if not _album_by_id(String(id)).is_empty():
			n += int(cards[id])
	return n

func _deck_lead(deck: Dictionary) -> Dictionary:
	var best := {}
	var top := 0
	var cards: Dictionary = deck.get("cards", {})
	for id in cards.keys():
		var a := _album_by_id(String(id))
		if not a.is_empty() and int(cards[id]) > top:
			best = a
			top = int(cards[id])
	return best

func _deck_discs(deck: Dictionary) -> Array:
	var out: Array = []
	var cards: Dictionary = deck.get("cards", {})
	for id in cards.keys():
		var a := _album_by_id(String(id))
		if a.is_empty():
			continue
		for n in int(cards[id]):
			var d := _make_disc(a)
			d.edition = ""
			out.append(d)
	for n in int(deck.get("mixes", 0)):
		out.append(_make_cdr())
	return out

func _refill() -> void:
	for p in wallet.size():
		if wallet[p] < 0:
			wallet[p] = _draw_card()
	_apply_sort()

func _draw_card() -> int:
	if draw_pile.is_empty():
		draw_pile = discard.duplicate()
		discard.clear()
		_shuffle(draw_pile)
	if draw_pile.is_empty():
		return -1
	return draw_pile.pop_back()

func _st(k: int, src: String, text: String, col: String, sound: float, pool: float, score_tot: int, e0: int) -> Dictionary:
	return {"k": k, "src": src, "text": text, "col": col, "sound": sound, "pool": pool, "score_tot": score_tot, "egain": score_tot - e0}

func _num(x: float) -> String:
	if is_equal_approx(x, roundf(x)):
		return str(int(roundf(x)))
	return String.num(x, 1)

func _ff(v: float) -> String:
	var t := "%.2f" % v
	while t.contains(".") and (t.ends_with("0") or t.ends_with(".")):
		t = t.left(t.length() - 1)
	return t

func _fmt_int(n: int) -> String:
	var a := absi(n)
	var sgn := "-" if n < 0 else ""
	if a < 1000000:
		var s := str(a)
		var out := ""
		while s.length() > 3:
			out = "," + s.right(3) + out
			s = s.left(s.length() - 3)
		return sgn + s + out
	var units := [[1000000.0, "M"], [1000000000.0, "B"], [1000000000000.0, "T"]]
	var ui := 0
	for i in units.size():
		if float(a) >= float(units[i][0]):
			ui = i
	while ui < units.size():
		var txt := "%.3f" % (float(a) / float(units[ui][0]))
		if not txt.begins_with("1000."):
			return sgn + txt + String(units[ui][1])
		ui += 1
	var e := int(floor(log(float(a)) / log(10.0)))
	var mant := float(a) / pow(10.0, e)
	var mt := "%.3f" % mant
	if mt.begins_with("10."):
		e += 1
		mt = "%.3f" % (mant / 10.0)
	return "%s%se%d" % [sgn, mt, e]

func _fmt_flow(f: float) -> String:
	if f >= 1000.0:
		return _fmt_int(int(round(f)))
	return _ff(f)

func _lcd_size(r: Rect2, cap: int) -> int:
	var sz := cap
	while sz > 14 and _text_w("888.888M", sz, true) > r.size.x - 28.0:
		sz -= 1
	return sz

func _fit_size(s: String, size: int, maxw: float, floor_size: int = 9) -> int:
	var sz := size
	while sz > floor_size and _text_w(s, sz, true) > maxw:
		sz -= 1
	return sz

func _case_rect(s: int) -> Rect2:
	var c := _well_center(s)
	return Rect2(c - Vector2(116.0, 102.5), Vector2(232.0, 205.0))

func _case_cols(d: Disc) -> Array:
	if d.genre >= 0 and d.genre < D.SLEEVE_MAIN.size():
		return [Color(D.SLEEVE_MAIN[d.genre]), Color(D.SLEEVE_LIGHT[d.genre]), Color(D.SLEEVE_DARK[d.genre])]
	return [Color("4a4e55"), Color("eceff3"), Color("2b2e33")]

func _abbr(p: String) -> String:
	if D.ERAS.has(p):
		return p.left(2)
	if p == "":
		return ""
	return p.left(1).to_upper()

func _jewel_parts(d: Disc) -> Dictionary:
	if d.cdr and d.genre < 0:
		return {"cb": ["?"], "ei": "", "en": "?", "es": ""}
	var r: Dictionary = d.rule
	var eff := String(r.get("effect", "none"))
	if eff == "none":
		return {"cb": [], "ei": "", "en": "", "es": ""}
	if eff == "copy":
		return {"cb": ["@left", "="], "ei": "", "en": "=", "es": ""}
	var v := float(r.get("value", 0.0))
	var tgt := String(r.get("target", "self"))
	var tp := String(r.get("tparam", ""))
	var p := _abbr(String(r.get("cparam", "")))
	var half := D.SETLIST / 2
	var cb: Array = []
	match String(r.get("condition", "always")):
		"first":
			cb = ["1"]
		"last":
			cb = [str(D.SETLIST)]
		"set1":
			cb = ["1-%d" % half]
		"set2":
			cb = ["%d-%d" % [half + 1, D.SETLIST]]
		"odd":
			cb = ["O"]
		"even":
			cb = ["E"]
		"slot1", "slot2", "slot3", "slot4", "slot5", "slot6":
			cb = [String(r.get("condition", "")).substr(4)]
		"prev_is":
			cb = ["@left", p]
		"above_is":
			cb = ["@up", p]
		"next_is":
			cb = ["@right", p]
		"per_before":
			cb = ["@each", p]
		"per_hand":
			cb = ["@hand", p]
	var ei := "note"
	var en := ("+$" + _ff(v)) if eff == "cash" else (("+" + _ff(v)) if eff == "points" or eff == "flow_add" else ("x" + _ff(v)))
	if eff == "flow_add" or eff == "flow_mult":
		ei = "wave"
	elif eff == "cash":
		ei = "coin"
	var es := ""
	match tgt:
		"next":
			es = "next"
		"later", "later_genre", "later_decade":
			es = "later"
	return {"cb": cb, "ei": ei, "en": en, "es": es}

func _icon(kind: String, c: Vector2, s: float, col: Color) -> void:
	var w := maxf(1.5, s * 0.12)
	var h := s * 0.5
	match kind:
		"note":
			draw_circle(c + Vector2(-h * 0.35, h * 0.55), h * 0.38, col)
			draw_line(c + Vector2(0.0, h * 0.5), c + Vector2(0.0, -h * 0.8), col, w)
			draw_line(c + Vector2(0.0, -h * 0.8), c + Vector2(h * 0.7, -h * 0.35), col, w)
		"wave":
			var pts := PackedVector2Array()
			for i in 13:
				var t := i / 12.0
				pts.append(c + Vector2(lerpf(-h, h, t), sin(t * TAU) * h * 0.45))
			draw_polyline(pts, col, w, true)
		"coin":
			draw_arc(c, h * 0.85, 0.0, TAU, 24, col, w, true)
			_text_center(Rect2(c - Vector2(h, h), Vector2(h, h) * 2.0), "$", int(s * 0.6), col, true)
		"numbers":
			for i in 3:
				var y := c.y + (i - 1) * h * 0.6
				draw_circle(Vector2(c.x - h * 0.7, y), w * 0.7, col)
				draw_line(Vector2(c.x - h * 0.35, y), Vector2(c.x + h * 0.8, y), col, w)
		"right":
			draw_line(c + Vector2(-h * 0.8, 0.0), c + Vector2(h * 0.5, 0.0), col, w)
			draw_colored_polygon(PackedVector2Array([c + Vector2(h * 0.95, 0.0), c + Vector2(h * 0.35, -h * 0.5), c + Vector2(h * 0.35, h * 0.5)]), col)
		"left":
			draw_line(c + Vector2(h * 0.8, 0.0), c + Vector2(-h * 0.5, 0.0), col, w)
			draw_colored_polygon(PackedVector2Array([c + Vector2(-h * 0.95, 0.0), c + Vector2(-h * 0.35, -h * 0.5), c + Vector2(-h * 0.35, h * 0.5)]), col)
		"up":
			draw_line(c + Vector2(0.0, h * 0.8), c + Vector2(0.0, -h * 0.5), col, w)
			draw_colored_polygon(PackedVector2Array([c + Vector2(0.0, -h * 0.95), c + Vector2(-h * 0.5, -h * 0.35), c + Vector2(h * 0.5, -h * 0.35)]), col)
		"flag":
			draw_line(c + Vector2(-h * 0.5, h * 0.9), c + Vector2(-h * 0.5, -h * 0.9), col, w)
			draw_colored_polygon(PackedVector2Array([c + Vector2(-h * 0.5, -h * 0.85), c + Vector2(h * 0.8, -h * 0.4), c + Vector2(-h * 0.5, h * 0.05)]), col)
		"sort":
			draw_line(c + Vector2(-h * 0.4, h * 0.8), c + Vector2(-h * 0.4, -h * 0.4), col, w)
			draw_colored_polygon(PackedVector2Array([c + Vector2(-h * 0.4, -h * 0.9), c + Vector2(-h * 0.8, -h * 0.35), c + Vector2(0.0, -h * 0.35)]), col)
			draw_line(c + Vector2(h * 0.4, -h * 0.8), c + Vector2(h * 0.4, h * 0.4), col, w)
			draw_colored_polygon(PackedVector2Array([c + Vector2(h * 0.4, h * 0.9), c + Vector2(0.0, h * 0.35), c + Vector2(h * 0.8, h * 0.35)]), col)
		"stack":
			for i in 3:
				var y := c.y + (i - 1) * h * 0.55
				draw_rect(Rect2(c.x - h * 0.8 + i * h * 0.15, y - h * 0.18, h * 1.4, h * 0.36), col)
		"finish":
			draw_line(c + Vector2(-h * 0.7, h * 0.9), c + Vector2(-h * 0.7, -h * 0.9), col, w)
			for i in 4:
				for q in 2:
					if (i + q) % 2 == 0:
						draw_rect(Rect2(c.x - h * 0.7 + i * h * 0.4, c.y - h * 0.85 + q * h * 0.4, h * 0.4, h * 0.4), col)
		"hand":
			for i in 3:
				draw_rect(Rect2(c.x - h * 0.8 + i * h * 0.55, c.y - h * 0.6 + abs(i - 1) * h * 0.25, h * 0.45, h * 1.3), col)
		"each":
			draw_line(c + Vector2(-h * 0.55, -h * 0.8), c + Vector2(0.0, h * 0.85), col, w)
			draw_line(c + Vector2(h * 0.55, -h * 0.8), c + Vector2(0.0, h * 0.85), col, w)
			draw_line(c + Vector2(-h * 0.3, -h * 0.1), c + Vector2(h * 0.3, -h * 0.1), col, w)
		"next":
			draw_polyline(PackedVector2Array([c + Vector2(-h * 0.4, -h * 0.7), c + Vector2(h * 0.4, 0.0), c + Vector2(-h * 0.4, h * 0.7)]), col, w, true)
		"later":
			draw_polyline(PackedVector2Array([c + Vector2(-h * 0.8, -h * 0.7), c + Vector2(0.0, 0.0), c + Vector2(-h * 0.8, h * 0.7)]), col, w, true)
			draw_polyline(PackedVector2Array([c + Vector2(0.0, -h * 0.7), c + Vector2(h * 0.8, 0.0), c + Vector2(0.0, h * 0.7)]), col, w, true)
		"mix":
			_text_center(Rect2(c - Vector2(h, h), Vector2(h, h) * 2.0), "?", int(s * 0.9), col, true)

func _badge(c: Vector2, rad: float, fill: Color, dim: float) -> void:
	draw_circle(c + Vector2(0.0, rad * 0.12), rad * 1.05, Color(0, 0, 0, 0.5))
	draw_circle(c, rad, Color(0.94, 0.94, 0.96).darkened(dim * 0.7))
	draw_circle(c, rad * 0.9, fill.darkened(dim * 0.7))
	draw_arc(c, rad * 0.9, PI * 1.1, PI * 1.9, 24, Color(1, 1, 1, 0.18), maxf(1.0, rad * 0.06), true)

func _jewel_box(r: Rect2) -> Rect2:
	var cs := Vector2(r.size.x, r.size.x * 0.886)
	return Rect2(r.get_center() - cs * 0.5, cs)

func _draw_jewel(r: Rect2, d: Disc, dim: float = 0.0, price: int = -1) -> void:
	var cs := Vector2(r.size.x, r.size.x * 0.886)
	var cr := Rect2(r.get_center() - cs * 0.5, cs)
	var k := cr.size.y / 160.0
	var cols := _case_cols(d)
	var main: Color = cols[0]
	var dark: Color = cols[2]
	var bw := maxi(1, int(round(2.0 * k)))
	_shadow(cr, int(6.0 * k), 5.0 * k)
	_panel(cr, Color("c9d2db"), int(4.0 * k))
	var body := cr.grow(-2.0 * k)
	_panel(body, Color("1b1e23"), int(3.0 * k))
	var pad := 5.0 * k
	var side := cr.size.y - 2.0 * pad
	var cover := Rect2(cr.end.x - side - pad, cr.position.y + pad, side, side)
	var spine := Rect2(body.position.x, body.position.y, cover.position.x - body.position.x - 2.0 * k, body.size.y)
	_grad_panel(spine, 2.0 * k, Color("3a4048"), Color("23272d"))
	for j in 3:
		var sx := spine.position.x + spine.size.x * (0.3 + j * 0.2)
		draw_line(Vector2(sx, spine.position.y + 8.0 * k), Vector2(sx, spine.end.y - 8.0 * k), Color(1, 1, 1, 0.12), maxf(1.0, 1.5 * k))
	_grad_panel(cover, 0.0, main.lightened(0.12), main.darkened(0.25))
	_disc_face(cover.get_center(), side * 0.45, d)
	_panel(cover, Color(0, 0, 0, 0), 0, Color(0, 0, 0, 0.55), maxi(1, int(1.5 * k)))
	var gloss := PackedVector2Array([cr.position + Vector2(cr.size.x * 0.35, 0), cr.position + Vector2(cr.size.x * 0.62, 0), cr.position + Vector2(cr.size.x * 0.3, cr.size.y), cr.position + Vector2(cr.size.x * 0.03, cr.size.y)])
	draw_colored_polygon(gloss, Color(1, 1, 1, 0.07))
	draw_line(cr.position + Vector2(4.0 * k, 2.0 * k), Vector2(cr.end.x - 4.0 * k, cr.position.y + 2.0 * k), Color(1, 1, 1, 0.6), maxf(1.0, 1.5 * k))
	var title := "Mix CD" if d.cdr and d.genre < 0 else (d.title if d.title != "" else "Untitled")
	var rad := cr.size.x * 0.135
	var off := rad * 0.55
	var strip_h := cr.size.y * 0.19
	var strip := Rect2(body.position.x, body.position.y, body.size.x, strip_h)
	_grad_panel(Rect2(strip.position.x, strip.end.y, strip.size.x, 7.0 * k), 0.0, Color(0, 0, 0, 0.35), Color(0, 0, 0, 0.0))
	draw_rect(strip, main)
	var tx := cr.position.x + off + rad + 10.0 * k
	var pfs := maxi(12, int(20.0 * k * 0.7))
	var reserve := 0.0
	if price >= 0:
		reserve = _heavy_w("$%d" % price, pfs) + 18.0 + 10.0 * k
	var tsz := _fit_size(title, int(round(strip_h * 0.66)), body.end.x - 8.0 * k - tx - reserve, 10)
	_text(Vector2(tx, strip.get_center().y + _vc(font_bold, tsz)), title, tsz, Color.WHITE, true)
	if price >= 0:
		_price_sticker(Vector2(body.end.x - 6.0 * k, strip.position.y + (strip_h - (pfs + 14.0)) * 0.5), "$%d" % price, k)
	if d.genre >= 0:
		var dc := cover.position + Vector2(side * 0.89, side * 0.5)
		var drad := side * 0.1
		draw_circle(dc + Vector2(0.0, 1.5 * k), drad, Color(0, 0, 0, 0.3))
		draw_circle(dc, drad, Color.WHITE)
		draw_arc(dc, drad - 1.5 * k, 0.0, TAU, 32, main, 1.5 * k, true)
		_text_center(Rect2(dc - Vector2(drad, drad), Vector2(drad, drad) * 2.0), String(D.ERAS[d.era]), _fit_size(String(D.ERAS[d.era]), int(round(side * 0.075)), drad * 1.7, 8), dark, true)
	if d.edition != "":
		var ed: Dictionary = D.EDITIONS[d.edition]
		var esz := int(round(side * 0.065))
		var ew := _text_w(String(ed["short"]), esz, true) + 10.0 * k
		var er := Rect2(cover.position.x + side * 0.04, cover.position.y + side * 0.34, ew, side * 0.1)
		_panel(er, Color(ed["color"]), 3, Color.WHITE, bw)
		_text_center(er, String(ed["short"]), esz, Color.WHITE, true)
	if dim > 0.0:
		_panel(cr, Color(0, 0, 0, dim), int(4.0 * k))
	var white := Color(1, 1, 1, 1.0 - dim * 0.5)
	var charcoal := Color("2b2e33")
	var pc := cr.position + Vector2(off, off)
	_badge(pc, rad, Color(D.SOUND_COLOR), dim)
	var ps := _fmt_int(d.sound)
	var psz := _fit_size(ps, int(round(rad * 1.15)), rad * 1.45, 12)
	_text_center(Rect2(pc - Vector2(rad, rad), Vector2(rad, rad) * 2.0), ps, psz, white, true)
	var parts := _jewel_parts(d)
	var cb: Array = parts["cb"]
	if not cb.is_empty():
		var cc := Vector2(cr.position.x + off, cr.end.y - off)
		_badge(cc, rad, charcoal, dim)
		var fs := int(round(rad * 0.95))
		var total := 0.0
		for t in cb:
			total += (rad * 0.85) if String(t).begins_with("@") else _text_w(String(t), fs, true)
		while fs > 9 and total > rad * 1.55:
			fs -= 1
			total = 0.0
			for t in cb:
				total += (rad * 0.85) if String(t).begins_with("@") else _text_w(String(t), fs, true)
		var cx := cc.x - total * 0.5
		for t in cb:
			var ts := String(t)
			if ts.begins_with("@"):
				_icon(ts.substr(1), Vector2(cx + rad * 0.425, cc.y), rad * 0.8, white)
				cx += rad * 0.85
			else:
				var tw := _text_w(ts, fs, true)
				_text(Vector2(cx, cc.y + _vc(font_bold, fs)), ts, fs, white, true)
				cx += tw
	var ei := String(parts["ei"])
	var en := String(parts["en"])
	if en != "":
		var ec := Vector2(cr.end.x - off, cr.end.y - off)
		var fill := charcoal
		if ei == "note":
			fill = Color(D.SOUND_COLOR)
		elif ei == "wave":
			fill = Color(D.ENERGY_COLOR)
		elif ei == "coin":
			fill = Color("d19a1c")
		_badge(ec, rad, fill, dim)
		if ei == "coin":
			_text_center(Rect2(ec - Vector2(rad, rad), Vector2(rad, rad) * 2.0), "$", int(round(rad * 1.6)), white, true)
		elif ei == "":
			_text_center(Rect2(ec - Vector2(rad, rad), Vector2(rad, rad) * 2.0), en, int(round(rad * 1.0)), white, true)
		else:
			var is_mult := en.begins_with("x")
			var xs := int(round(rad * 0.85))
			var xw := _text_w("x", xs, true) if is_mult else 0.0
			var isz := rad * 0.95
			var chev := rad * 0.5 if String(parts["es"]) != "" else 0.0
			var tw2 := xw + isz + chev
			var sx := ec.x - tw2 * 0.5
			if is_mult:
				_text(Vector2(sx, ec.y + _vc(font_bold, xs)), "x", xs, white, true)
				sx += xw
			_icon(ei, Vector2(sx + isz * 0.5, ec.y), isz, white)
			if chev > 0.0:
				_icon(String(parts["es"]), Vector2(sx + isz + chev * 0.5, ec.y), chev * 0.9, white)

func _draw_cd_player(r: Rect2, art: Texture2D = null, art_spin: float = 0.0, force_art: bool = false) -> void:
	_shadow(r, 14, 8.0)
	_grad_panel(r, 14.0, Color("34373c"), Color("202226"))
	_panel(r, Color(0, 0, 0, 0), 14, Color(0, 0, 0, 0.6), 2)
	var c := r.position + Vector2(r.size.x * 0.5, r.size.y * 0.49)
	var wr := r.size.x * 0.44
	draw_circle(c, wr + 5.0, Color("0b0c0e"))
	draw_circle(c, wr, Color("17181b"))
	draw_arc(c, wr - 8.0, 0.0, TAU, 96, Color(1, 1, 1, 0.07), 2.0, true)
	var d := _playing_disc()
	if force_art:
		_cd_art(c, wr * 0.9, art, art_spin)
	elif d != null:
		_disc_face(c, wr * 0.9 * lerpf(0.9, 1.0, 1.0 - rec_pop), d, spin)
	else:
		draw_circle(c, wr * 0.1, Color("2a2c31"))
		draw_arc(c, wr * 0.1, 0.0, TAU, 32, Color(1, 1, 1, 0.2), 2.0, true)
	draw_colored_polygon(PackedVector2Array([r.position + Vector2(14.0, 10.0), r.position + Vector2(r.size.x * 0.62, 10.0), r.position + Vector2(14.0, r.size.y * 0.62)]), Color(1, 1, 1, 0.06))
	draw_circle(r.end - Vector2(22.0, 22.0), 5.0, Color("7fe0a0") if d != null or force_art else Color("4a4e55"))

func _setlist() -> Array:
	var ids: Array = []
	var slots: Array = []
	for s in tray.size():
		if tray[s] >= 0:
			ids.append(tray[s])
			slots.append(s)
	return [ids, slots]

func _cell_get(kind: String, idx: int) -> int:
	return tray[idx] if kind == "tray" else wallet[idx]

func _cell_set(kind: String, idx: int, v: int) -> void:
	if kind == "tray":
		tray[idx] = v
	else:
		wallet[idx] = v

func _cell_center(kind: String, idx: int) -> Vector2:
	return _well_center(idx) if kind == "tray" else _pocket_rect(idx).get_center()

func _can_drag() -> bool:
	return ui_live and phase == "show" and not resolving and not playing and dig_offer.is_empty() and not dig_mode and not burn_mode and not peek_open and not binder_open and not settings_open and pack.is_empty() and gear_sel < 0 and bench < 0 and install_queue.is_empty() and held < 0

func _drag_source_at(pos: Vector2) -> Array:
	for s in D.SETLIST:
		if not _one_mode() and tray[s] >= 0 and _case_rect(s).has_point(pos):
			return ["tray", s]
	for p in D.HAND:
		if wallet[p] >= 0 and _pocket_rect(p).has_point(pos):
			return ["wallet", p]
	return []

func _drop_target(pos: Vector2) -> Array:
	var best: Array = []
	var bestd := INF
	for s in D.SETLIST:
		if _one_mode() and tray[s] >= 0:
			continue
		var rr := _case_rect(s).grow(16.0)
		if rr.has_point(pos):
			var d := pos.distance_to(rr.get_center())
			if d < bestd:
				bestd = d
				best = ["tray", s]
	for p in D.HAND:
		if _one_mode():
			continue
		var r := _pocket_rect(p).grow(10.0)
		if r.has_point(pos):
			var d2 := pos.distance_to(r.get_center())
			if d2 < bestd:
				bestd = d2
				best = ["wallet", p]
	return best

func _cell_hidden(kind: String, idx: int) -> bool:
	if drag_active and drag_kind == kind and drag_idx == idx:
		return true
	for st: Dictionary in settles:
		if String(st["kind"]) == kind and int(st["idx"]) == idx:
			return true
	return false

func _try_drag_press(pos: Vector2) -> bool:
	if not _can_drag():
		return false
	var src := _drag_source_at(pos)
	if src.is_empty():
		return false
	drag_pending = true
	drag_kind = String(src[0])
	drag_idx = int(src[1])
	return true

func _start_drag() -> void:
	drag_pending = false
	drag_active = true
	drag_disc = _cell_get(drag_kind, drag_idx)
	drag_pos = _cell_center(drag_kind, drag_idx)
	drag_lift = 0.0
	drag_hover = []
	sel_slot = -1
	_sfx("click")

func _apply_drop(kind: String, idx: int) -> void:
	var a := drag_disc
	var b := _cell_get(kind, idx)
	_cell_set(kind, idx, a)
	_cell_set(drag_kind, drag_idx, b)
	settles.append({"disc": a, "kind": kind, "idx": idx, "from": drag_pos, "t": 0.0, "w0": _cell_w(drag_kind) * 1.1, "w1": _cell_w(kind)})
	if b >= 0:
		settles.append({"disc": b, "kind": drag_kind, "idx": drag_idx, "from": _cell_center(kind, idx), "t": 0.0, "w0": _cell_w(kind), "w1": _cell_w(drag_kind)})
	if kind == "tray":
		slot_flash[idx] = 1.0
	_sfx("page_turn")

func _end_drag() -> void:
	var tgt := _drop_target(_ui_mouse())
	if _one_mode():
		if tgt.is_empty() or String(tgt[0]) != "tray" or drag_kind != "wallet":
			_cancel_drag()
			return
		var pidx := drag_idx
		var from_pos := drag_pos
		drag_active = false
		drag_disc = -1
		drag_hover = []
		_play_cd(pidx, int(tgt[1]), from_pos)
		return
	if tgt.is_empty() or (String(tgt[0]) == drag_kind and int(tgt[1]) == drag_idx):
		_cancel_drag()
		return
	_apply_drop(String(tgt[0]), int(tgt[1]))
	drag_active = false
	drag_disc = -1
	drag_hover = []

func _cancel_drag() -> void:
	if drag_active:
		settles.append({"disc": drag_disc, "kind": drag_kind, "idx": drag_idx, "from": drag_pos, "t": 0.0, "w0": _cell_w(drag_kind) * 1.1, "w1": _cell_w(drag_kind)})
	drag_active = false
	drag_pending = false
	drag_disc = -1
	drag_hover = []

func _tick_drag(delta: float) -> void:
	var mp := _ui_mouse()
	var down := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if drag_pending:
		if not down:
			drag_pending = false
		elif press_pos.distance_to(mp) > DRAG_START:
			_start_drag()
	if drag_active:
		if phase != "show" or resolving or playing:
			_cancel_drag()
		elif not down:
			_end_drag()
		else:
			drag_pos = drag_pos.lerp(mp, 1.0 - exp(-delta * 28.0))
			drag_lift = minf(1.0, drag_lift + delta * 10.0)
			drag_hover = _drop_target(mp)
	for i in range(settles.size() - 1, -1, -1):
		settles[i]["t"] = float(settles[i]["t"]) + delta
		if float(settles[i]["t"]) >= SETTLE_T:
			settles.remove_at(i)
	if drag_active:
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
	elif _can_drag() and not _drag_source_at(mp).is_empty():
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _draw_lifted(di: int, pos: Vector2, w: float, sh: float) -> void:
	var r := Rect2(pos - Vector2(w, w) * 0.5, Vector2(w, w))
	_panel(Rect2(r.position + Vector2(8.0, 20.0) * sh + Vector2(0.0, w * 0.057), Vector2(w, w * 0.886)), Color(0, 0, 0, 0.22 * sh), 8)
	_draw_jewel(r, collection[di])

func _cell_rect(kind: String, idx: int) -> Rect2:
	if kind == "tray":
		return _case_rect(idx)
	return _pocket_rect(idx).grow(-8.0)

func _draw_drag() -> void:
	if drag_active:
		_panel(_cell_rect(drag_kind, drag_idx), Color(0, 0, 0, 0), 8, Color(1, 1, 1, 0.22), 3)
		var pulse := 0.16 + 0.08 * sin(clock * 5.0)
		for s in D.SETLIST:
			if not (drag_kind == "tray" and drag_idx == s) and (not _one_mode() or tray[s] < 0):
				_panel(_case_rect(s).grow(6.0), Color(0, 0, 0, 0), 12, Color(c_gold, pulse), 3)
		for p in D.HAND:
			if not (drag_kind == "wallet" and drag_idx == p) and not _one_mode():
				_panel(_pocket_rect(p).grow(-4.0), Color(0, 0, 0, 0), 10, Color(c_gold, pulse), 3)
		if not drag_hover.is_empty() and not (String(drag_hover[0]) == drag_kind and int(drag_hover[1]) == drag_idx):
			var hr := _cell_rect(String(drag_hover[0]), int(drag_hover[1])).grow(8.0)
			_panel(hr, Color(c_gold, 0.14), 12, c_gold, 6)
	for st: Dictionary in settles:
		var u := clampf(float(st["t"]) / SETTLE_T, 0.0, 1.0)
		var e := 1.0 - pow(1.0 - u, 3.0)
		var from: Vector2 = st["from"]
		var to := _cell_center(String(st["kind"]), int(st["idx"]))
		_draw_lifted(int(st["disc"]), from.lerp(to, e), lerpf(float(st["w0"]), float(st["w1"]), e), 1.0 - e)
	if drag_active:
		var lift := 1.0 - pow(1.0 - drag_lift, 3.0)
		_draw_lifted(drag_disc, drag_pos, _cell_w(drag_kind) * lerpf(1.0, 1.1, lift), lift)

func _return_held() -> void:
	if held < 0:
		return
	var p := held_from if held_from >= 0 and wallet[held_from] < 0 else wallet.find(-1)
	wallet[p] = held
	held = -1

func _placed() -> int:
	var n := 0
	for t in tray:
		if t >= 0:
			n += 1
	return n

func _can_play() -> bool:
	if _one_mode():
		return false
	return ui_live and phase == "show" and not resolving and not playing and not dig_mode and not burn_mode and not peek_open and dig_offer.is_empty() and _placed() == D.SETLIST

func _on_pocket(p: int) -> void:
	if burn_mode:
		_on_burn_pick(p)
		return
	if dig_mode:
		if wallet[p] >= 0:
			if p in dig_marks:
				dig_marks.erase(p)
			else:
				dig_marks.assign([p])
		return
	if resolving or playing or not dig_offer.is_empty():
		return
	if _one_mode():
		sel_hand = -1 if sel_hand == p else (p if wallet[p] >= 0 else -1)
		_sfx("click")
		return
	if sel_slot >= 0:
		var back := tray[sel_slot]
		tray[sel_slot] = wallet[p]
		wallet[p] = back
		slot_flash[sel_slot] = 1.0
		sel_slot = -1
		_sfx("page_turn")
		return
	if wallet[p] < 0:
		return
	var o := tray.find(-1)
	if o < 0:
		_say("The changer is full. Click a CD in it to swap or send it back.")
		return
	tray[o] = wallet[p]
	wallet[p] = -1
	slot_flash[o] = 1.0
	_sfx("page_turn")

func _on_slot(s: int) -> void:
	if resolving or playing or not dig_offer.is_empty():
		return
	if _one_mode():
		if sel_hand >= 0 and tray[s] < 0:
			_play_cd(sel_hand, s, _cell_center("wallet", sel_hand))
		return
	if sel_slot < 0:
		if tray[s] >= 0:
			sel_slot = s
			_sfx("click")
		return
	if s == sel_slot:
		var p := wallet.find(-1)
		if p >= 0:
			wallet[p] = tray[s]
			tray[s] = -1
		sel_slot = -1
		_sfx("page_turn")
		return
	var t := tray[s]
	tray[s] = tray[sel_slot]
	tray[sel_slot] = t
	slot_flash[s] = 1.0
	sel_slot = -1
	_sfx("page_turn")

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
			return [_reward_rank(d), d.genre, d.era, d.title]
	return [d.title, d.title, d.title]

func _sort_less(a: Disc, b: Disc) -> bool:
	var ka := _sort_vals(a)
	var kb := _sort_vals(b)
	for i in ka.size():
		if ka[i] != kb[i]:
			return ka[i] < kb[i]
	return false

func _discard_hand() -> void:
	if digs <= 0 or playing or resolving or (_one_mode() and set_live):
		return
	_return_held()
	var old: Array[int] = []
	for p in wallet.size():
		if wallet[p] >= 0:
			old.append(wallet[p])
			wallet[p] = -1
	if old.is_empty() and draw_pile.is_empty() and discard.is_empty():
		return
	for p in wallet.size():
		if draw_pile.is_empty() and not discard.is_empty():
			draw_pile = discard.duplicate()
			discard.clear()
			_shuffle(draw_pile)
		if not draw_pile.is_empty():
			wallet[p] = draw_pile.pop_back()
	var kept := 0
	for p in wallet.size():
		if wallet[p] < 0 and not old.is_empty():
			wallet[p] = old.pop_back()
			kept += 1
	discard.append_array(old)
	digs -= 1
	_apply_sort()
	_sfx("page_turn")
	_say("Discarded your hand and drew %d new CDs." % (wallet.size() - kept))

func _start_dig() -> void:
	if not D.DIG_PICK:
		_discard_hand()
		return
	if digs <= 0 or playing:
		return
	_return_held()
	dig_mode = true
	dig_marks.clear()

func _confirm_dig() -> void:
	if dig_marks.is_empty() or digs <= 0:
		return
	var p: int = dig_marks[0]
	var gone := wallet[p]
	if draw_pile.size() < D.DIG_OFFERS and not discard.is_empty():
		draw_pile.append_array(discard)
		discard.clear()
		_shuffle(draw_pile)
	if draw_pile.is_empty():
		_say("There are no CDs left in the binder to draw.")
		dig_mode = false
		dig_marks.clear()
		return
	discard.append(gone)
	wallet[p] = -1
	dig_offer.clear()
	for k in mini(D.DIG_OFFERS, draw_pile.size()):
		dig_offer.append(draw_pile.pop_back())
	dig_slot = p
	digs -= 1
	dig_mode = false
	dig_marks.clear()
	_sfx("page_turn")
	_say("Discarded %s." % collection[gone].title)

func _take_offer(k: int) -> void:
	if k >= dig_offer.size():
		return
	var take: int = dig_offer[k]
	for j in dig_offer.size():
		if j != k:
			draw_pile.append(dig_offer[j])
	_shuffle(draw_pile)
	wallet[dig_slot] = take
	dig_offer.clear()
	dig_slot = -1
	_apply_sort()
	_sfx("page_turn")
	_say("Took %s." % collection[take].title)

func _toggle_pile_mode() -> void:
	pile_with_hand = not pile_with_hand
	_sfx("click")

func _pile_counts() -> Dictionary:
	var g: Array = []
	for k in D.GENRES.size():
		g.append(0)
	var e: Array = []
	for k in D.ERAS.size():
		e.append(0)
	var mix := 0
	var pool: Array = draw_pile.duplicate()
	if pile_with_hand:
		for w in wallet:
			if w >= 0:
				pool.append(w)
	for i in pool:
		var d := collection[i]
		if d.cdr and d.genre < 0:
			mix += 1
		else:
			g[d.genre] += 1
			e[d.era] += 1
	return {"genre": g, "era": e, "mix": mix, "total": pool.size()}

func _draw_pile_table(r: Rect2) -> void:
	var ink := Color("23262b")
	var counts := _pile_counts()
	var x0 := r.position.x
	var w := r.size.x
	for row in 2:
		var is_genre := row == 0
		var n := D.GENRES.size() if is_genre else D.ERAS.size()
		var cw := w / n
		var ly := r.position.y + (24.0 if is_genre else 70.0)
		for k in n:
			var cell := Rect2(x0 + k * cw + 2.0, ly + 4.0, cw - 4.0, 24.0)
			var lab := String(D.GENRE_SHORT[k]) if is_genre else String(D.ERAS[k]).to_upper()
			var cnt := int((counts["genre"] if is_genre else counts["era"])[k])
			var keeps := _cell_keeps(is_genre, k)
			_silk(Vector2(cell.get_center().x - _text_w(lab, 12, true) * 0.5, ly), lab, 12, ink)
			_panel(cell, Color("0b0d0e"), 3, Color(D.FLOW_COLOR) if keeps else Color(0, 0, 0, 0.6), 2 if keeps else 1)
			var col := Color(D.FLOW_COLOR).lightened(0.3) if keeps else Color("ff9a6b")
			_text_center(cell, str(cnt), 18, col if cnt > 0 else Color(col, 0.25), true)
			if is_genre:
				draw_rect(Rect2(cell.position.x + 3.0, cell.end.y - 4.0, cell.size.x - 6.0, 2.0), Color(D.GENRE_COLORS[k]).lightened(0.35))

func _draw_dig_offer() -> void:
	var r := r_rack
	_shadow(r, 10, 14.0)
	_surface(r, 10.0, "metal_dark", Color("1d1f23"), Color("121316"))
	_panel(r, Color(0, 0, 0, 0), 10, Color(c_gold, 0.8), 3)
	var x := r.position.x + 40.0
	var w := r.size.x - 80.0
	var gone: Disc = collection[discard.back()]
	_heavy(Vector2(x, r.position.y + 76.0), "Choose 1 of %d" % dig_offer.size(), T_XL, Color("f4efe4"))
	_wrap(Vector2(x, r.position.y + 112.0), "You discarded %s. Pick a CD for the glowing slot in your hand." % gone.title, w, T_SM, Color("b8c0cc"), true)
	var ch := 372.0
	for k in dig_offer.size():
		var d: Disc = collection[dig_offer[k]]
		var cr := Rect2(x, r.position.y + 190.0 + k * (ch + 14.0), w, ch)
		_panel(cr, Color(1, 1, 1, 0.05), 12, Color(1, 1, 1, 0.14), 2)
		var dc := Vector2(cr.position.x + 120.0, cr.position.y + 124.0)
		_draw_jewel(Rect2(dc - Vector2(104.0, 104.0), Vector2(208.0, 208.0)), d)
		_tip_disc(Rect2(dc - Vector2(104.0, 92.0), Vector2(208.0, 184.0)), d)
		var tx := cr.position.x + 250.0
		var tw := cr.size.x - 270.0
		_wrap(Vector2(tx, cr.position.y + 44.0), d.title, tw, T_MD, Color.WHITE, true)
		var cx := tx
		if d.genre >= 0:
			cx += _info_chip(cx, cr.position.y + 112.0, String(D.GENRE_SHORT[d.genre]), Color("5d626a")) + 6.0
			_info_chip(cx, cr.position.y + 112.0, String(D.ERAS[d.era]), Color("5d626a"))
		else:
			_info_chip(cx, cr.position.y + 112.0, "MIX", Color("2b5fa8"))
		var body := "Becomes a random album when played." if d.cdr else _cond_text(d)
		if d.edition != "":
			body += "  " + String(D.EDITIONS[d.edition]["name"]) + " edition: " + String(D.EDITIONS[d.edition]["text"])
		_wrap(Vector2(tx, cr.position.y + 170.0), body, tw, 15, Color("e8ecf2"), true)
		_hw_button(Rect2(cr.position.x + 20.0, cr.end.y - 84.0, w - 40.0, 64.0), "Take this CD", _take_offer.bind(k), true, Color("3f9b5a"), T_SM)

func _well_center(s: int) -> Vector2:
	var cols := D.SETLIST / 2
	var col := s if s < cols else D.SETLIST - 1 - s
	var row := 0 if s < cols else 1
	return Vector2(r_changer.position.x + 40.0 + col * 323.0 + 178.0, r_changer.position.y + 146.5 + row * 305.0)

func _pocket_rect(p: int) -> Rect2:
	var per := D.HAND / 2
	var col := p % per
	var row := p / per
	var span := (r_wallet.size.x - 2.0 * WALLET_BORDER) / per
	var cx := r_wallet.position.x + WALLET_BORDER + (col + 0.5) * span
	var ch := 221.0
	var gap := 56.0
	var top := r_wallet.position.y + WALLET_BORDER + (r_wallet.size.y - 2.0 * WALLET_BORDER - 2.0 * ch - gap) * 0.5 + 8.0
	return Rect2(cx - 124.0, top + row * (ch + gap), 248.0, ch)

func _draw() -> void:
	_begin_draw()
	audition_target = null
	hold_targets.clear()
	if fin_shake > 0.0:
		draw_set_transform(screen_origin + Vector2(sin(clock * 91.0), cos(clock * 77.0)) * 16.0 * fin_shake * ui_scale, 0.0, Vector2(ui_scale, ui_scale))
	var modal := phase in ["result", "over", "won", "end"] or not pack.is_empty() or binder_open or settings_open
	ui_live = not modal and not playing
	hover_disc = null
	if phase == "map":
		_draw_map()
	elif phase == "fork":
		_draw_fork()
	elif phase == "boss":
		_draw_boss()
	elif phase == "title":
		_draw_title()
	elif phase == "kits":
		_draw_kits()
	elif phase == "decks":
		_draw_decks()
	elif phase == "pickup":
		_draw_pickup()
	elif phase == "shop":
		_draw_shop()
		_draw_rack()
	else:
		_draw_room()
		_register(Rect2(-800.0, -800.0, UI_W + 1600.0, UI_H + 1600.0), _return_held)
		_draw_changer()
		_draw_score_panel()
		_draw_wallet()
		_draw_rack()
	_draw_floats()
	_draw_finale()
	_draw_countdown()
	_draw_toast()
	_draw_held()
	_draw_drag()
	ui_live = true
	if not pack.is_empty():
		_draw_pack()
	if not dig_offer.is_empty():
		_draw_dig_offer()
	if peek_open:
		_draw_peek()
	if settings_open:
		_draw_settings()
	match phase:
		"result":
			_draw_result()
		"over":
			_draw_run_end(false)
		"won":
			_draw_run_end(true)
		"end":
			_draw_show_end()
	if binder_open:
		_draw_binder_overlay()
	elif (phase == "shop" and install_queue.is_empty()) or phase in ["map", "fork"]:
		_draw_binder_button()
	_draw_hold()
	if held < 0 and not drag_active and hover_disc != null:
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

func _lcd(r: Rect2, text: String, col: Color, size: int, ghost: String = "", align: String = "right") -> void:
	_panel(r.grow(5.0), Color("0a0b0d"), 9)
	_grad_panel(r, 6.0, col.darkened(0.9).lerp(Color("0d1210"), 0.4), Color("06080a"))
	var g := ghost if ghost != "" else "8".repeat(text.length())
	var yb := r.get_center().y + _vc(font_bold, size)
	var gx := r.end.x - 14.0 - _text_w(g, size, true)
	var tx := r.end.x - 14.0 - _text_w(text, size, true)
	if align == "center":
		gx = r.get_center().x - _text_w(g, size, true) * 0.5
		tx = r.get_center().x - _text_w(text, size, true) * 0.5
	elif align == "left":
		gx = r.position.x + 14.0
		tx = r.position.x + 14.0
	_text(Vector2(gx, yb), g, size, Color(col, 0.04), true)
	_text(Vector2(tx, yb), text, size, col, true)
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
	var tray_r := Rect2(r.position.x + 40.0, r.position.y + 30.0, r.size.x - 80.0, r.size.y - 60.0)
	_inset(tray_r, 14.0, Color("141518"))
	for s in D.SETLIST:
		_draw_well(s)

func _slot_met(s: int) -> bool:
	var i := tray[s]
	if i < 0:
		return false
	var d := collection[i]
	if d.cdr:
		return false
	var rule: Dictionary = d.rule
	var eff := String(rule.get("effect", "none"))
	if eff == "none":
		return false
	var half := D.SETLIST / 2
	var gm := _gear_map()
	var prev: Disc = collection[tray[s - 1]] if s > 0 and tray[s - 1] >= 0 else null
	var above: Disc = null
	if (s >= half or gm.has("audio")) and tray[D.SETLIST - 1 - s] >= 0:
		above = collection[tray[D.SETLIST - 1 - s]]
	var nxt: Disc = collection[tray[s + 1]] if s + 1 < tray.size() and tray[s + 1] >= 0 else null
	if eff == "copy":
		if prev == null or String(prev.rule.get("effect", "none")) in ["none", "copy"]:
			return false
		rule = prev.rule
	if String(rule.get("condition", "always")) == "per_before":
		var c := 0
		for j in s:
			if tray[j] >= 0 and _name_matches(collection[tray[j]], String(rule.get("cparam", ""))):
				c += 1
		return c > 0
	return _cond_count(rule, s, tray, prev, above, nxt) > 0

func _cell_w(kind: String) -> float:
	return 232.0

func _draw_well(s: int) -> void:
	var cr := _case_rect(s)
	var c := cr.get_center()
	_inset(cr.grow(12.0), 10.0, Color("0b0c0e"))
	_panel(cr, Color(1, 1, 1, 0.03), 6, Color(1, 1, 1, 0.1), 2)
	var met := _slot_met(s)
	var nb := Rect2(cr.position.x - 62.0, c.y - 23.0, 46.0, 46.0)
	if met:
		_panel(nb.grow(5.0), Color(0.5, 0.88, 0.63, 0.2), 14)
	_panel(nb, Color("0b0c0e"), 10, Color("7fe0a0") if met else Color(1, 1, 1, 0.14), 3 if met else 2)
	_text_center(nb, str(s + 1), T_LG, Color("9af0b8") if met else Color("6c727a"), true)
	var open := sel_slot == s and not resolving
	var done := (tray[s] >= 0 and now_slot != s and set_live) if _one_mode() else (resolving and s < played.size() and now_slot != s)
	var lock_tag := ""
	if _boss_kind() == "slot" and int(venue["challenge"]["slot"]) == s:
		lock_tag = "ONLY %s or %s" % [String(D.GENRES[int(venue["challenge"]["genre"])]).to_upper(), D.ERAS[int(venue["challenge"]["era"])]]
	if open:
		_panel(cr.grow(10.0), Color(0, 0, 0, 0), 14, c_gold, 5)
	elif sel_slot >= 0 and not resolving:
		_panel(cr.grow(8.0), Color(0, 0, 0, 0), 14, Color(c_gold, 0.25 + 0.15 * sin(clock * 4.0)), 3)
	var i := tray[s]
	if i >= 0 and not _cell_hidden("tray", s):
		var d := collection[i]
		var dimv := 0.0
		if now_slot == s:
			dimv = 0.55
		elif done:
			dimv = 0.5
		elif playing:
			dimv = 0.35
		_draw_jewel(cr, d, dimv)
		if now_slot == s:
			_text_center(cr, "PLAYING", T_SM, Color(1, 1, 1, 0.9), true)
		_tip_disc(cr, d)
	if slot_flash[s] > 0.0:
		_panel(cr.grow(6.0), Color(0, 0, 0, 0), 12, Color(c_gold, slot_flash[s]), 5)
	if _one_mode() and set_live and s < play_order.size() and int(play_order[s]) > 0:
		var ob := Vector2(cr.end.x - 8.0, cr.position.y + 8.0)
		_badge(ob, 21.0, Color("2b2e33"), 0.0)
		_text_center(Rect2(ob - Vector2(21.0, 21.0), Vector2(42.0, 42.0)), str(int(play_order[s])), T_MD, Color.WHITE, true)
	if _one_mode() and tray[s] < 0 and not resolving and not playing and ui_live:
		var pdisc := -1
		if drag_active and drag_kind == "wallet":
			pdisc = drag_disc
		elif sel_hand >= 0 and wallet[sel_hand] >= 0:
			pdisc = wallet[sel_hand]
		var hot_slot := false
		if drag_active:
			hot_slot = not drag_hover.is_empty() and String(drag_hover[0]) == "tray" and int(drag_hover[1]) == s
		else:
			hot_slot = cr.has_point(mouse)
		if pdisc >= 0 and hot_slot:
			var pv := _preview_play(pdisc, s)
			var pr := Rect2(c - Vector2(110.0, 60.0), Vector2(220.0, 120.0))
			_panel(Rect2(pr.position + Vector2(0.0, 6.0), pr.size), Color(0, 0, 0, 0.35), 16)
			_panel(pr, Color(0.05, 0.06, 0.08, 0.92), 16, Color(c_gold, 0.85), 3)
			_text_center(Rect2(pr.position.x, pr.position.y + 6.0, pr.size.x, 64.0), "+" + _fmt_int(int(pv["score"])), T_XL, Color(D.SOUND_COLOR).lightened(0.25), true)
			var ftxt := "flow x%s" % _ff(float(pv["flow"]))
			if absf(float(pv["flow"]) - float(pv["flow0"])) > 0.001:
				ftxt = "flow x%s  >  x%s" % [_ff(float(pv["flow0"])), _ff(float(pv["flow"]))]
			_text_center(Rect2(pr.position.x, pr.position.y + 72.0, pr.size.x, 36.0), ftxt, T_SM, Color(D.FLOW_COLOR).lightened(0.3), true)
	if lock_tag != "":
		var lr0 := Rect2(cr.position.x, cr.position.y + 4.0, cr.size.x, 30.0)
		_panel(lr0, Color("7a1f1f"), 8, Color("ffb0a6"), 2)
		_text_center(lr0, lock_tag, 13, Color.WHITE, true)
	var ro: Dictionary = readout[s]
	var lr := Rect2(cr.position.x, cr.end.y + 26.0, cr.size.x, 40.0)
	var lc := Color(D.SOUND_COLOR).lightened(0.25)
	if not ro.is_empty() and ro.has("net") and int(ro["net"]) < 0:
		lc = c_bad.lightened(0.3)
	_lcd(lr, String(ro["text"]) if not ro.is_empty() else "", lc, _lcd_size(lr, 28), "888,888")
	if ui_live and not dig_mode and not resolving and not playing:
		_register(cr.grow(10.0), _on_slot.bind(s))

func _tape_poly(c: Vector2, rr: float, hw: float, a0: float, a1: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var n := maxi(8, int((a1 - a0) * rr / 6.0))
	var jit := 4.0 / rr
	for i in n + 1:
		pts.append(c + Vector2.from_angle(a0 + (a1 - a0) * i / n) * (rr + hw))
	for k in range(1, 5):
		pts.append(c + Vector2.from_angle(a1 + (jit if k % 2 == 1 else -jit)) * (rr + hw - 2.0 * hw * k / 5.0))
	for i in n + 1:
		pts.append(c + Vector2.from_angle(a1 - (a1 - a0) * i / n) * (rr - hw))
	for k in range(1, 5):
		pts.append(c + Vector2.from_angle(a0 + (jit if k % 2 == 1 else -jit)) * (rr - hw + 2.0 * hw * k / 5.0))
	return pts

func _band_text(c: Vector2, rad: float, d: Disc) -> void:
	if d.genre < 0:
		return
	var label := "%s-%s" % [D.ERAS[d.era], D.GENRES[d.genre]]
	var split := String(D.ERAS[d.era]).length()
	if label_title:
		label = d.title if d.title != "" else "Untitled"
	var f := _marker_font()
	var rr := rad * 0.62
	var fs := maxi(10, int(rad * 0.18))
	var adv: Array[float] = []
	var total := 0.0
	for i in label.length():
		adv.append(f.get_string_size(label.substr(i, 1), HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
		total += adv[i]
	var max_arc := rr * deg_to_rad(140.0)
	if total > max_arc:
		fs = maxi(7 if label_title else 9, int(fs * maxf(0.4 if label_title else 0.6, max_arc / total)))
		total = 0.0
		for i in adv.size():
			adv[i] = f.get_string_size(label.substr(i, 1), HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			total += adv[i]
	var ctr := -PI * 0.5 + ((d.uid * 37) % 7 - 3) * 0.035
	var half := total / rr * 0.5 + 0.2
	var hw := fs * 0.95
	var tape := _tape_poly(c, rr, hw, ctr - half, ctr + half)
	var drop := PackedVector2Array()
	for q in tape:
		drop.append(q + Vector2(0.0, 2.0))
	draw_colored_polygon(drop, Color(0, 0, 0, 0.3))
	draw_colored_polygon(tape, Color("eadfbf", 0.96))
	draw_arc(c, rr + hw * 0.7, ctr - half + 0.05, ctr + half - 0.05, 32, Color(1, 1, 1, 0.35), 1.5, true)
	draw_arc(c, rr - hw * 0.7, ctr - half + 0.05, ctr + half - 0.05, 32, Color(0.5, 0.42, 0.25, 0.18), 1.5, true)
	var base_ink := Color("17171b")
	var pos := -total * 0.5
	for i in label.length():
		var ch := label.substr(i, 1)
		var th := ctr + (pos + adv[i] * 0.5) / rr
		pos += adv[i]
		if ch == " ":
			continue
		var ink := base_ink
		if label_title:
			pass
		elif i < split:
			ink = _ring_ink(true, d.era, base_ink)
		elif i > split:
			ink = _ring_ink(false, d.genre, base_ink)
		draw_set_transform(screen_origin + (c + Vector2.from_angle(th) * rr) * ui_scale, th + PI * 0.5, Vector2(ui_scale, ui_scale))
		var p := Vector2(-adv[i] * 0.5, fs * 0.35)
		draw_string(f, p + Vector2(0.7, 0.5), ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(ink, 0.5))
		draw_string(f, p, ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
	draw_set_transform(screen_origin, 0.0, Vector2(ui_scale, ui_scale))

func _ring_ink(is_era: bool, v: int, base: Color) -> Color:
	var r := _tag_ring_val(is_era, v)
	if r.a <= 0.0:
		return base
	if r == c_bad:
		return Color("a01820")
	if r == c_gold:
		return Color("8a5a00")
	return Color("1f6b3a")

func _disc_face(c: Vector2, rad: float, d: Disc, spin: float = 0.0) -> void:
	if d.cdr and d.genre < 0:
		_cd_art(c, rad, null, spin)
		return
	_cd_art(c, rad, _cover_tex(d.mix_cover if d.cdr else d.cover), spin)

func _short_name(n: String) -> String:
	var gi := D.GENRES.find(n)
	if gi >= 0:
		return String(D.GENRE_SHORT[gi])
	return n.to_upper()

func _cond_label(d: Disc) -> String:
	var r: Dictionary = d.rule
	var eff := String(r.get("effect", "none"))
	if eff == "none":
		return "NO EFFECT"
	if eff == "copy":
		return "COPY PREV"
	var v := float(r.get("value", 0.0))
	var tgt := String(r.get("target", "self"))
	var tp := _short_name(String(r.get("tparam", "")))
	var p := _short_name(String(r.get("cparam", "")))
	var sg := ("+$" + _ff(v)) if eff == "cash" else (("+" + _ff(v)) if eff == "points" or eff == "flow_add" else ("x" + _ff(v)))
	var part := sg
	if eff == "flow_add" or eff == "flow_mult":
		part = "FLOW " + sg
	elif tgt == "next":
		part = "NEXT " + sg
	elif tgt == "later":
		part = "LATER " + sg
	elif tgt == "later_genre" or tgt == "later_decade":
		part = "LATER %s %s" % [tp, sg]
	var cp := ""
	match String(r.get("condition", "always")):
		"first":
			cp = "FIRST"
		"last":
			cp = "LAST"
		"set1":
			cp = "SET 1"
		"set2":
			cp = "SET 2"
		"odd":
			cp = "ODD"
		"even":
			cp = "EVEN"
		"slot1", "slot2", "slot3", "slot4", "slot5", "slot6":
			cp = "SLOT " + String(r.get("condition", "")).substr(4)
		"prev_is":
			cp = "AFTER " + p
		"above_is":
			cp = "ABOVE " + p
		"next_is":
			cp = "BEFORE " + p
		"per_before":
			return "%s PER %s" % [part, p]
		"per_hand":
			return "%s PER %s IN HAND" % [part, p]
	return part if cp == "" else cp + " " + part

func _cond_text(d: Disc) -> String:
	var r: Dictionary = d.rule
	var eff := String(r.get("effect", "none"))
	if eff == "none":
		return "No effect. It is just points."
	if eff == "copy":
		return "Repeats the effect of the song before it."
	var half := D.SETLIST / 2
	var v := _ff(float(r.get("value", 0.0)))
	var tp := String(r.get("tparam", ""))
	var p := String(r.get("cparam", ""))
	var lead := ""
	match String(r.get("condition", "always")):
		"first":
			lead = "If it is played first, "
		"last":
			lead = "If it is played last, "
		"set1":
			lead = "In the first set (slots 1 to %d), " % half
		"set2":
			lead = "In the second set (slots %d to %d), " % [half + 1, D.SETLIST]
		"odd":
			lead = "In an odd slot (1, 3, 5), "
		"even":
			lead = "In an even slot (2, 4, 6), "
		"slot1", "slot2", "slot3", "slot4", "slot5", "slot6":
			lead = "In slot %s, " % String(r.get("condition", "")).substr(4)
		"prev_is":
			lead = "If the song before it is %s, " % p
		"above_is":
			lead = "If the song above it is %s (slots %d to %d only), " % [p, half + 1, D.SETLIST]
		"next_is":
			lead = "If the song after it is %s, " % p
		"per_before":
			lead = "For each %s song played before it, " % p
		"per_hand":
			lead = "For each %s song left in your hand, " % p
	var tgt := String(r.get("target", "self"))
	var amount := ("+%s points" % v) if eff == "points" else ("x%s" % v)
	var body := ""
	match eff:
		"flow_add":
			body = "your flow goes up by %s after this song plays." % v
		"flow_mult":
			body = "your flow is multiplied by %s after this song plays." % v
		"cash":
			body = "you earn $%s." % v
		_:
			match tgt:
				"next":
					body = "the next song scores %s." % amount
				"later":
					body = "every later song scores %s." % amount
				"later_genre", "later_decade":
					body = "every later %s song scores %s." % [tp, amount]
				_:
					body = "this song scores %s." % amount
	var out := lead + body
	return out.left(1).to_upper() + out.substr(1)

func _name_matches(d: Disc, nm: String) -> bool:
	if d.genre < 0 or nm == "":
		return false
	var gi := D.GENRES.find(nm)
	if gi >= 0:
		return _in_genre(d, gi)
	var ei := D.ERAS.find(nm)
	return ei >= 0 and _era_near(d.era, ei)

func _cond_part(rule: Dictionary, count: int) -> String:
	var p := String(rule.get("cparam", ""))
	match String(rule.get("condition", "always")):
		"first":
			return "First"
		"last":
			return "Last"
		"set1":
			return "Set 1"
		"set2":
			return "Set 2"
		"odd":
			return "Odd slot"
		"even":
			return "Even slot"
		"slot1", "slot2", "slot3", "slot4", "slot5", "slot6":
			return "Slot " + String(rule.get("condition", "")).substr(4)
		"prev_is":
			return "After %s" % p
		"above_is":
			return "Above %s" % p
		"next_is":
			return "Before %s" % p
		"per_before":
			return "Fans (%d %s)" % [count, p]
		"per_hand":
			return "Hand (%d %s)" % [count, p]
	return ""

func _rule_line(rule: Dictionary, count: int, amt: float) -> String:
	var cp := _cond_part(rule, count)
	var eff := String(rule.get("effect", "none"))
	var tgt := String(rule.get("target", "self"))
	var tp := String(rule.get("tparam", ""))
	var sg := ("+$" + _ff(amt)) if eff == "cash" else (("+" + _ff(amt)) if eff == "points" or eff == "flow_add" else ("x" + _ff(amt)))
	var body := ""
	if eff == "cash":
		return (cp + " " + sg) if cp != "" else sg
	if eff == "flow_add" or eff == "flow_mult":
		body = "flow %s after this song" % sg
	elif tgt == "next":
		body = "next song " + sg
	elif tgt == "later":
		body = "later songs " + sg
	elif tgt == "later_genre" or tgt == "later_decade":
		body = "later %s songs %s" % [tp, sg]
	else:
		return (cp if cp != "" else "Bonus") + " " + sg
	return (cp + ": " + body) if cp != "" else body.left(1).to_upper() + body.substr(1)

func _era_near(e: int, v: int) -> bool:
	return e == v or (_bay_of("pitch") >= 0 and absi(e - v) <= 1)

func _disc_marks(c: Vector2, rad: float, d: Disc) -> void:
	if d.cdr and d.genre < 0:
		_heavy_center(Rect2(c.x - rad, c.y - rad * 0.62, rad * 2.0, rad * 0.4), "MIX", int(rad * 0.3), Color("2b5fa8"))
		_text_center(Rect2(c.x - rad, c.y + rad * 0.32, rad * 2.0, rad * 0.3), "CD-R", int(rad * 0.16), Color("5d626a"), true)
	else:
		_band_text(c, rad, d)
		var lab := "MIX" if d.cdr else _cond_label(d)
		var fs := maxi(10, int(rad * 0.17))
		while fs > 8 and _heavy_w(lab, fs) + rad * 0.3 > rad * 1.7:
			fs -= 1
		var pw := minf(_heavy_w(lab, fs) + rad * 0.3, rad * 1.7)
		var pr := Rect2(c.x - pw * 0.5, c.y + rad * 0.5, pw, fs * 1.7)
		_panel(Rect2(pr.position + Vector2(1.0, 2.0), pr.size), Color(0, 0, 0, 0.45), int(fs * 0.8))
		_panel(pr, Color("14181d"), int(fs * 0.8), Color(D.FLOW_COLOR).lightened(0.2), maxi(1, int(rad * 0.02)))
		_heavy_center(pr, lab, fs, Color.WHITE)
	var tc := c + Vector2(-rad * 0.72, -rad * 0.72)
	var sc := Color(D.SOUND_COLOR)
	draw_circle(tc + Vector2(0, 3), rad * 0.2, Color(0, 0, 0, 0.4))
	draw_circle(tc, rad * 0.2, sc.darkened(0.15))
	draw_arc(tc, rad * 0.2, 0.0, TAU, 32, Color(1, 1, 1, 0.75), 2.0, true)
	_heavy_center(Rect2(tc - Vector2(rad, rad) * 0.2, Vector2(rad, rad) * 0.4), str(d.sound), int(rad * (0.24 if d.sound < 10 else 0.19)), Color.WHITE)
	if d.edition != "":
		_edition_marks(c, rad, d.edition)

func _debuff_marks(c: Vector2, rad: float, d: Disc, soft: bool) -> void:
	if not soft:
		draw_circle(c, rad, Color(0.34, 0.35, 0.38, 0.62))
		draw_arc(c, rad, 0.0, TAU, 64, Color(c_bad, 0.6), 3.0, true)
	var bc := c + Vector2(-rad * 0.72, rad * 0.72)
	var br := rad * 0.2
	var u := br * 0.5
	draw_circle(bc + Vector2(0.0, 3.0), br, Color(0, 0, 0, 0.4))
	draw_circle(bc, br, Color("2a0f12"))
	draw_arc(bc, br, 0.0, TAU, 32, c_bad.lightened(0.25), maxf(1.5, br * 0.12), true)
	draw_colored_polygon(PackedVector2Array([bc + Vector2(-u * 0.95, -u * 0.55), bc + Vector2(u * 0.95, -u * 0.55), bc + Vector2(0.0, u * 0.8)]), c_bad.lightened(0.3))

func _draw_wallet() -> void:
	var b := r_wallet
	_shadow(b, 22, 12.0)
	_grad_panel(b, 22.0, Color("2b3036"), Color("1c1f24"))
	_panel(b, Color(0, 0, 0, 0), 22, Color(0, 0, 0, 0.55), 2)
	draw_line(b.position + Vector2(22.0, 2.0), Vector2(b.end.x - 22.0, b.position.y + 2.0), Color(1, 1, 1, 0.16), 2.0)
	for p in D.HAND:
		var r := _pocket_rect(p)
		var c := r.grow(-8.0)
		var over := ui_live and r.has_point(mouse) and (wallet[p] >= 0 or sel_slot >= 0) and (dig_mode or not resolving)
		var i := wallet[p]
		if _cell_hidden("wallet", p):
			i = -1
		if i < 0:
			_panel(c, Color(1, 1, 1, 0.04), 10)
		if over:
			_panel(c.grow(7.0), Color(c_gold, 0.1), 14, Color(c_gold, 0.8), 3)
		if _one_mode() and sel_hand == p and i >= 0:
			_panel(c.grow(9.0), Color(c_gold, 0.16), 14, c_gold, 5)
		if not dig_offer.is_empty() and p == dig_slot:
			_panel(c.grow(8.0), Color(0, 0, 0, 0), 14, Color(c_gold, 0.6 + 0.3 * sin(clock * 5.0)), 4)
		if i >= 0:
			var d := collection[i]
			_draw_jewel(c, d)
			_tip_disc(r, d)
			if dig_mode and p in dig_marks:
				draw_rect(c, Color(0, 0, 0, 0.55))
				_heavy_center(c, "DISCARD", T_XL, c_gold)
				_panel(c.grow(-2.0), Color(0, 0, 0, 0), 8, c_gold, 5)
			elif dig_mode:
				_panel(c.grow(-2.0), Color(0, 0, 0, 0), 8, Color(c_gold, 0.35 + 0.2 * sin(clock * 5.0)), 3)
			elif burn_mode and p in burn_marks:
				draw_rect(c, Color(0, 0, 0, 0.55))
				_heavy_center(c, "BURN", T_XL, c_gold)
				_panel(c.grow(-2.0), Color(0, 0, 0, 0), 8, c_gold, 5)
			elif burn_mode:
				_panel(c.grow(-2.0), Color(0, 0, 0, 0), 8, Color(c_gold, 0.35 + 0.2 * sin(clock * 5.0)), 3)
		if ui_live:
			_register(r, _on_pocket.bind(p))
	_draw_console()
	_draw_actions()

func _nav_bg(r: Rect2) -> void:
	_shadow(r, 8, 12.0)
	_brushed(r, 8.0, Color("b4b9bf"), 71)
	draw_line(r.position + Vector2(8.0, 1.0), Vector2(r.end.x - 8.0, r.position.y + 1.0), Color(1, 1, 1, 0.35), 2.0)
	_panel(r, Color(0, 0, 0, 0), 8, Color(0, 0, 0, 0.45), 1)
	for ex in [r.position.x + 14.0, r.end.x - 14.0]:
		for ey in [r.position.y + 14.0, r.end.y - 14.0]:
			_screw(Vector2(ex, ey), 6.0)

func _draw_cash() -> void:
	var r := r_cash
	_shadow(r, 8, 10.0)
	_surface(r, 8.0, "metal_dark", Color("2b2e33"), Color("1a1c20"))
	_panel(r, Color(0, 0, 0, 0), 8, Color(0, 0, 0, 0.6), 2)
	_silk(Vector2(r.position.x + 28.0, r.position.y + 62.0), "CASH", T_MD, Color("8d939b"))
	var lr := Rect2(r.position.x + 160.0, r.position.y + 14.0, r.size.x - 190.0, 72.0)
	_lcd(lr, "$" + _fmt_int(cash), Color("7fe0a0"), _lcd_size(lr, 56), "$888,888")

func _draw_actions() -> void:
	var r := r_actions
	_nav_bg(r)
	var x := r.position.x
	var y := r.position.y
	var black := Color("1a1c20")
	var ink := Color("23262b")
	if _one_mode():
		var hint_r := Rect2(x + 24.0, y + 16.0, 572.0, 84.0)
		_panel(hint_r, Color("1d3a26"), 12, Color("3f9b5a"), 3)
		_text_center(hint_r, "PLAYING" if resolving else ("DRAG A CD ONTO A TRAY" if sel_hand < 0 else "CLICK A TRAY"), T_LG, Color("bfe8c9"), true)
	else:
		_hw_button(Rect2(x + 24.0, y + 16.0, 572.0, 84.0), "PLAY SET" if not resolving else "PLAYING", _play, _can_play(), Color("3f9b5a"), T_XL)
	var red := Color("c23a2e")
	if dig_mode:
		var n := dig_marks.size()
		_hw_button(Rect2(x + 24.0, y + 112.0, 400.0, 62.0), "Discard" if n > 0 else "Pick", _confirm_dig, n > 0, red, T_LG)
		_hw_button(Rect2(x + 436.0, y + 112.0, 160.0, 62.0), "Cancel", _cancel, true, black, T_SM)
	else:
		var can := ui_live and phase == "show" and not resolving and dig_offer.is_empty() and digs > 0 and draw_pile.size() + discard.size() > 0 and not (_one_mode() and set_live)
		_hw_button(Rect2(x + 24.0, y + 112.0, 400.0, 62.0), "Discard", _start_dig, can, red, T_LG)
		var lamps := maxi(D.DIGS, digs)
		for k in lamps:
			_led(Vector2(x + 392.0 - (lamps - 1 - k) * 28.0, y + 143.0), 8.0, Color("ffb347"), 1.0 if k < digs else 0.0)
	var count := ("%d / %d" % [mini(played.size() + 1, D.SETLIST), D.SETLIST]) if resolving else ("%d / %d" % [_placed(), D.SETLIST])
	_text_center(Rect2(x + 440.0, y + 112.0, 156.0, 40.0), count, T_LG, ink, true)
	_silk(Vector2(x + 518.0 - _text_w("SLOT" if resolving else "LOADED", 14, true) * 0.5, y + 166.0), "SLOT" if resolving else "LOADED", 14, ink)

func _draw_shop_nav() -> void:
	var r := r_actions
	_nav_bg(r)
	var x := r.position.x
	var y := r.position.y
	var enabled := ui_live and install_queue.is_empty() and bench < 0
	_hw_button(Rect2(x + 24.0, y + 16.0, 572.0, 84.0), "Exit shop", _leave_shop, enabled, Color("3f9b5a"), T_XL)
	_hw_button(Rect2(x + 24.0, y + 112.0, 572.0, 62.0), "View binder (%d)" % collection.size(), _toggle_binder, install_queue.is_empty(), Color("1a1c20"), T_MD)

func _aisle_label(w: Rect2, text: String) -> void:
	var lr := Rect2(w.position.x + 30.0, w.position.y + 18.0, w.size.x - 60.0, 50.0)
	_panel(lr, Color("0d0e10"), 8, Color(c_gold, 0.7), 2)
	_heavy_center(lr, text, T_MD, c_gold)

func _draw_console() -> void:
	var r := Rect2(60.0, 1302.0, r_side.end.x - 60.0, 108.0)
	_shadow(r, 6, 8.0)
	_brushed(r, 6.0, Color("b4b9bf"), 53)
	draw_line(r.position + Vector2(6.0, 1.0), Vector2(r.end.x - 6.0, r.position.y + 1.0), Color(1, 1, 1, 0.35), 2.0)
	_panel(r, Color(0, 0, 0, 0), 6, Color(0, 0, 0, 0.45), 1)
	for ex in [r.position.x + 18.0, r.end.x - 18.0]:
		for ey in [r.position.y + 22.0, r.end.y - 22.0]:
			_screw(Vector2(ex, ey), 7.0)
	var ink := Color("23262b")
	var cy := r.position.y + 14.0
	var x := r.position.x + 44.0
	_hw_button(Rect2(x, cy + 8.0, 196.0, 72.0), "View binder (%d)" % collection.size(), _toggle_binder, phase == "show" and not dig_mode, Color("1a1c20"), T_SM)
	x += 224.0
	_draw_pile_table(Rect2(x, r.position.y, 560.0, r.size.y))
	x += 586.0
	_console_divider(r, x)
	x += 26.0
	_silk(Vector2(x, cy + 32.0), "SORT", T_SM, ink)
	_silk(Vector2(x, cy + 58.0), "HAND", 13, Color("3d4148"))
	var keys: Array = D.SORT_KEYS
	var x0 := x + 96.0
	var gap := 18.0
	var kw := (r.end.x - 44.0 - x0 - gap * (keys.size() - 1)) / keys.size()
	var live := ui_live and not dig_mode and phase == "show"
	for k in keys.size():
		_stereo_key(Rect2(x0 + k * (kw + gap), cy, kw, 72.0), String(D.SORT_TEXT[keys[k]]), sort_key == String(keys[k]), live, String(keys[k]))

func _stereo_key(r: Rect2, label: String, on: bool, live: bool, key: String) -> void:
	var hover := live and r.has_point(mouse)
	_panel(r.grow(5.0), Color("0d0e10"), 10)
	var down := 4.0 if on else 0.0
	var face := Rect2(r.position + Vector2(0.0, down), r.size - Vector2(0.0, down))
	var top := Color("d3d7dc") if not on else Color("9aa0a8")
	var bot := Color("8d939a") if not on else Color("686e76")
	if hover and not on:
		top = top.lightened(0.1)
		bot = bot.lightened(0.1)
	_grad_panel(face, 7.0, top, bot)
	draw_line(face.position + Vector2(7.0, 2.0), Vector2(face.end.x - 7.0, face.position.y + 2.0), Color(1, 1, 1, 0.7 if not on else 0.25), 2.0)
	_panel(face, Color(0, 0, 0, 0), 7, Color(0, 0, 0, 0.5), 1)
	_led(Vector2(face.position.x + 26.0, face.get_center().y), 7.0, Color("ffb347"), 1.0 if on else 0.0)
	_text_center(Rect2(face.position.x + 40.0, face.position.y, face.size.x - 40.0, face.size.y), label.to_upper(), T_SM, Color("23262b"), true)
	if live:
		_register(r, _set_sort.bind(key))

func _reward_rank(d: Disc) -> int:
	if d.cdr and d.genre < 0:
		return 8
	match String(d.rule.get("effect", "none")):
		"points":
			return 0
		"mult":
			return 1
		"flow_add":
			return 2
		"flow_mult":
			return 3
		"cash":
			return 4
		"copy":
			return 5
	return 6

func _console_divider(r: Rect2, x: float) -> void:
	draw_line(Vector2(x, r.position.y + 12.0), Vector2(x, r.end.y - 12.0), Color(0, 0, 0, 0.35), 2.0)
	draw_line(Vector2(x + 2.0, r.position.y + 12.0), Vector2(x + 2.0, r.end.y - 12.0), Color(1, 1, 1, 0.45), 1.0)

func _toggle_switch(c: Vector2, on: bool) -> void:
	draw_circle(c + Vector2(0.0, 2.0), 17.0, Color(0, 0, 0, 0.35))
	var hexp := PackedVector2Array()
	for i in 6:
		hexp.append(c + Vector2.from_angle(TAU * i / 6.0 + PI / 6.0) * 16.0)
	draw_colored_polygon(hexp, Color("8d939a"))
	draw_polyline(hexp + PackedVector2Array([hexp[0]]), Color(0, 0, 0, 0.45), 1.0, true)
	draw_circle(c, 11.0, Color("c3c8ce"))
	draw_circle(c, 7.0, Color("2a2c31"))
	var tip := c + Vector2(4.0, -20.0 if on else 20.0)
	draw_line(c + Vector2(2.0, 2.0), tip + Vector2(2.0, 2.0), Color(0, 0, 0, 0.3), 9.0, true)
	draw_line(c, tip, Color("b9bec4"), 8.0, true)
	draw_line(c + Vector2(-1.5, 0.0), tip + Vector2(-1.5, 0.0), Color(1, 1, 1, 0.6), 2.0, true)
	draw_circle(tip, 6.5, Color("d9dde2"))
	draw_circle(tip - Vector2(2.0, 2.0), 2.5, Color(1, 1, 1, 0.8))

func _score_color(v: float) -> Color:
	var t := float(_gig_target())
	if v < t * 0.5:
		return Color("ff6b5a")
	if v < t:
		return Color("f2c14e")
	if v < t * D.TIER_GOOD:
		return Color("7fe0a0")
	return Color("b6ff8a")

func _tag_ring_val(is_era: bool, v: int) -> Color:
	var key := "era" if is_era else "genre"
	var name := String(D.ERAS[v]) if is_era else String(D.GENRES[v])
	if not venue.is_empty():
		for tag: Array in venue["dislikes"]:
			if tag == [key, name]:
				return c_bad
		for tag: Array in venue["likes"]:
			if tag == [key, name]:
				return c_good.lightened(0.2)
	var bo := _boosts(key, v)
	if bo != 0:
		return c_gold if bo > 0 else c_bad
	return Color(0, 0, 0, 0)

func _boosts(key: String, v: int) -> int:
	var best := 0
	for g: Dictionary in rack:
		if g.is_empty() or bool(g.get("broken", false)):
			continue
		if (key == "genre" and g["id"] == "genre_eq") or (key == "era" and g["id"] == "decade_eq"):
			var lv := int(g["levels"][v])
			if lv < 0:
				return -1
			if lv > 0:
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
	var left := draw_pile.size()
	var help := "Pick an album to discard." if dig_mode else ("Discard 1 wallet album, then pick 1 of %d from your binder (%d left)." % [D.DIG_OFFERS, left] if D.DIG_PICK else "Discard every album in your wallet and draw a fresh hand (%d left in the binder)." % left)
	_wrap(Vector2(x, dy + 70.0), help, w, T_SM, Color("2b2e33"))
	var by := r.end.y - 116.0
	if dig_mode:
		var n := dig_marks.size()
		_hw_button(Rect2(x, by, w * 0.55, 76.0), "Dig %d" % n if n > 0 else "Dig", _confirm_dig, n > 0, Color("c9a227"), T_LG)
		_hw_button(Rect2(x + w * 0.6, by, w * 0.4, 76.0), "Cancel", _cancel, true, Color("8a8f98"), T_MD)
	else:
		_hw_button(Rect2(x, by, w, 76.0), "Dig through the binder", _start_dig, digs > 0 and ui_live, Color("c9a227"), T_LG)

func _rack_idle() -> bool:
	return not resolving and not playing and dig_offer.is_empty() and not dig_mode and not burn_mode and not peek_open and install_queue.is_empty() and bench < 0 and (pack.is_empty() or pack_rig_open) and not binder_open and (phase == "show" or phase == "shop") and not (_one_mode() and set_live)

func _gear_click(i: int) -> void:
	if not _rack_idle():
		return
	var a := _anchor(i)
	if gear_sel < 0:
		if not rack[a].is_empty():
			gear_sel = a
			_sfx("click")
		return
	if a == gear_sel:
		gear_sel = -1
		return
	if _rack_try(gear_sel, i):
		_sfx("page_turn")
	gear_sel = -1

func _rack_try(fa: int, to_i: int) -> bool:
	var g: Dictionary = rack[fa]
	var ta := _anchor(to_i)
	if g.is_empty() or ta == fa:
		return false
	if _gear_full(g):
		var tb := (to_i / 2) * 2
		if tb == fa:
			return false
		var o1: Dictionary = rack[tb]
		var o2: Dictionary = rack[tb + 1]
		rack[fa] = {}
		rack[fa + 1] = {}
		rack[tb] = g
		rack[tb + 1] = {}
		if not o1.is_empty():
			rack[fa] = o1
		if not o2.is_empty():
			rack[fa + 1] = o2
		comp_flash[tb] = 1.0
	else:
		var occ: Dictionary = rack[ta]
		if not occ.is_empty() and _gear_full(occ):
			var partner := fa + 1 if fa % 2 == 0 else fa - 1
			if not rack[partner].is_empty():
				_say("The %s needs a free slot beside it to swap." % gear_defs[g["id"]]["name"])
				return false
			rack[fa] = {}
			rack[ta] = g
			rack[(fa / 2) * 2] = occ
		else:
			rack[fa] = {}
			rack[ta] = g
			if not occ.is_empty():
				rack[fa] = occ
		comp_flash[ta] = 1.0
	if phase == "show":
		_sync_tuner()
	return true

func _sell_gear(i: int) -> void:
	if phase != "shop" or not install_queue.is_empty() or bench >= 0 or rack[i].is_empty():
		return
	var g: Dictionary = rack[i]
	var id := String(g["id"])
	var gm := _gear_map()
	var got := maxi(1, int(gear_defs[id]["price"]) / 2)
	if id == "piggy":
		got += int(g.get("pot", 0)) * (int(gm[id]["m"]) if gm.has(id) else 1)
	cash += got
	rack[i] = {}
	gear_sel = -1
	_sfx("page_turn")
	_say("Sold the %s for $%d." % [gear_defs[id]["name"], got])

func _can_use(g: Dictionary) -> bool:
	var m := _gear_m(String(g["id"]))
	if m <= 0 or int(g.get("used", 0)) >= m:
		return false
	return ui_live and phase == "show" and not resolving and not playing and dig_offer.is_empty() and not dig_mode and not peek_open and not binder_open and held < 0

func _use_gear(slot: int) -> void:
	var g: Dictionary = rack[slot]
	if g.is_empty() or not _can_use(g):
		return
	match String(g["id"]):
		"deep_library":
			burn_mode = false
			burn_marks.clear()
			for p in wallet.size():
				if wallet[p] >= 0:
					discard.append(wallet[p])
					wallet[p] = -1
			_refill()
			g["used"] = int(g["used"]) + 1
			comp_flash[slot] = 1.0
			_sfx("page_turn")
			_say("Fresh hand from the Deep Library.")
		"sneak_peek":
			peek_ids.clear()
			for k in mini(int(_gp("sneak_peek", "count")), draw_pile.size()):
				peek_ids.append(draw_pile[draw_pile.size() - 1 - k])
			peek_open = true
			g["used"] = int(g["used"]) + 1
			comp_flash[slot] = 1.0
			_sfx("page_turn")
		"cd_burner":
			if burn_mode:
				burn_mode = false
				burn_marks.clear()
				return
			burn_mode = true
			burn_marks.clear()
			_say("CD Burner: pick an album and a Mix in your hand.")
			message_t = 60.0

func _on_burn_pick(p: int) -> void:
	if wallet[p] < 0:
		return
	if p in burn_marks:
		burn_marks.erase(p)
		return
	burn_marks.append(p)
	if burn_marks.size() < 2:
		return
	var a: Disc = collection[wallet[burn_marks[0]]]
	var b: Disc = collection[wallet[burn_marks[1]]]
	var mix: Disc = a if a.cdr else (b if b.cdr else null)
	var src: Disc = b if mix == a else a
	if mix == null or src.cdr:
		_say("Pick one album and one Mix.")
		message_t = 60.0
		burn_marks.clear()
		return
	mix.title = src.title
	mix.band = src.band
	mix.cover = src.cover
	mix.genre = src.genre
	mix.era = src.era
	mix.label = src.label
	mix.sound = src.sound
	mix.rule = src.rule.duplicate()
	mix.edition = src.edition
	mix.cdr = false
	mix.mix_cover = ""
	for ci in rack.size():
		if not rack[ci].is_empty() and String(rack[ci]["id"]) == "cd_burner":
			rack[ci]["used"] = int(rack[ci]["used"]) + 1
			comp_flash[ci] = 1.0
	burn_mode = false
	burn_marks.clear()
	_sfx("page_turn")
	message_t = 0.0
	_say("Burned a copy of %s." % src.title)

func _close_peek() -> void:
	peek_open = false
	peek_ids.clear()

func _choice(r: Rect2, label: String, on: bool, cb: Callable) -> void:
	_hw_button(r, label, cb, true, Color("3f9b5a") if on else Color("5a5f67"), T_MD)

func _draw_settings() -> void:
	var r := _modal_panel(1200.0, 980.0)
	_register(Rect2(Vector2(-800, -800), Vector2(UI_W, UI_H) + Vector2(1600, 1600)), func(): pass)
	_heavy_center(Rect2(r.position.x, r.position.y + 26.0, r.size.x, 70.0), "Settings", T_XL, c_ink)
	var tab := Rect2(r.position.x + 60.0, r.position.y + 120.0, 220.0, 56.0)
	_panel(tab, Color("2b2e33"), 12)
	_text_center(tab, "Scoring", T_MD, Color("f4efe4"), true)
	draw_line(Vector2(r.position.x + 40.0, tab.end.y + 8.0), Vector2(r.end.x - 40.0, tab.end.y + 8.0), Color("2b2e33"), 4.0)
	var x := r.position.x + 60.0
	var w := r.size.x - 120.0
	var y := r.position.y + 220.0
	_text(Vector2(x, y), "SCORING SYSTEM", 16, c_muted, true)
	var half := (w - 24.0) * 0.5
	_choice(Rect2(x, y + 20.0, half, 76.0), "Flow each song", score_mode == "song", _set_score_mode.bind("song"))
	_choice(Rect2(x + half + 24.0, y + 20.0, half, 76.0), "Flow at end", score_mode == "end", _set_score_mode.bind("end"))
	_text(Vector2(x, y + 134.0), "Flow multiplies each song as it plays." if score_mode == "song" else "Flow multiplies the whole set once at the end.", T_SM, c_body, true)
	var y2 := y + 210.0
	_text(Vector2(x, y2), "ANIMATION SPEED", 16, c_muted, true)
	var n: int = D.ANIM_NAMES.size()
	var bw := (w - 16.0 * (n - 1)) / n
	for i in n:
		_choice(Rect2(x + i * (bw + 16.0), y2 + 20.0, bw, 76.0), String(D.ANIM_NAMES[i]), anim_idx == i, _set_anim.bind(i))
	_text(Vector2(x, y2 + 134.0), "How fast the score sequence plays out.", T_SM, c_body, true)
	var y3 := y2 + 210.0
	_text(Vector2(x, y3), "PLACEMENT", 16, c_muted, true)
	_choice(Rect2(x, y3 + 20.0, half, 76.0), "All at once", place_mode == "all", _set_place_mode.bind("all"))
	_choice(Rect2(x + half + 24.0, y3 + 20.0, half, 76.0), "One at a time", place_mode == "one", _set_place_mode.bind("one"))
	_text(Vector2(x, y3 + 134.0), "Lay out the whole set, then press play." if place_mode == "all" else "Drag a CD onto any empty tray and it plays right away.", T_SM, c_body, true)
	_hw_button(Rect2(r.get_center().x - 160.0, r.end.y - 110.0, 320.0, 80.0), "Close", _close_settings, true, Color("3f9b5a"), T_LG)

func _draw_peek() -> void:
	var r := _modal_panel(1300.0, 620.0)
	_register(Rect2(Vector2(-800, -800), Vector2(UI_W, UI_H) + Vector2(1600, 1600)), func(): pass)
	_heavy_center(Rect2(r.position.x, r.position.y + 30.0, r.size.x, 70.0), "Sneak Peek", T_XL, c_ink)
	_text_center(Rect2(r.position.x, r.position.y + 100.0, r.size.x, 36.0), ("The next %d songs in your binder, in the order you will draw them." % peek_ids.size()) if not peek_ids.is_empty() else "Your binder is empty.", T_MD, c_body, true)
	var n := maxi(1, peek_ids.size())
	var step := (r.size.x - 120.0) / n
	for k in peek_ids.size():
		var d: Disc = collection[peek_ids[k]]
		var c := Vector2(r.position.x + 60.0 + step * (k + 0.5), r.position.y + 270.0)
		var pw := minf(220.0, step - 24.0)
		_draw_jewel(Rect2(c - Vector2(pw, pw) * 0.5, Vector2(pw, pw)), d)
		_tip_disc(Rect2(c - Vector2(pw, pw * 0.886) * 0.5, Vector2(pw, pw * 0.886)), d)
		_text_center(Rect2(c.x - step * 0.5, c.y + 96.0, step, 30.0), "%d" % (k + 1), T_MD, c_muted, true)
	_hw_button(Rect2(r.get_center().x - 160.0, r.end.y - 110.0, 320.0, 80.0), "Close", _close_peek, true, Color("3f9b5a"), T_LG)

func _rack_unit(r: Rect2, title: String, sub: String, seed_n: int, flash: float, sub_w: float = 226.0, tx: float = 44.0) -> void:
	_shadow(r, 6, 6.0)
	_brushed(r, 6.0, Color("b4b9bf"), seed_n)
	for ex in [r.position.x + 18.0, r.end.x - 18.0]:
		for ey in [r.position.y + 24.0, r.end.y - 24.0]:
			_screw(Vector2(ex, ey), 7.0)
	var fs := T_MD
	while fs > 14 and _text_w(title.to_upper(), fs, true) > sub_w + 16.0:
		fs -= 1
	_silk(Vector2(r.position.x + tx, r.position.y + 44.0), title.to_upper(), fs, Color("23262b"))
	_wrap(Vector2(r.position.x + tx, r.position.y + 58.0), sub, sub_w, 17, Color("3d4148"))
	_led(Vector2(r.position.x + tx + 10.0, r.end.y - 34.0), 7.0, Color("ffb347"), flash)
	_silk(Vector2(r.position.x + tx + 28.0, r.end.y - 28.0), "ACTIVE", 12, Color("3d4148"))

func _bay_rect(k: int) -> Rect2:
	return Rect2(1912.0, 196.0 + k * 330.0, 556.0, 316.0)

func _slot_rect(i: int) -> Rect2:
	var b := _bay_rect(i / 2)
	var hw := (b.size.x - 12.0) * 0.5
	return Rect2(b.position.x + (i % 2) * (hw + 12.0), b.position.y, hw, b.size.y)

func _unit_rect(i: int) -> Rect2:
	if not rack[i].is_empty() and _gear_full(rack[i]):
		return _bay_rect(i / 2)
	return _slot_rect(i)

func _draw_rack() -> void:
	_draw_cash()
	var r := r_rack
	_shadow(r, 10, 14.0)
	_surface(r, 10.0, "metal_dark", Color("1d1f23"), Color("121316"))
	for rx in [r.position.x + 12.0, r.end.x - 26.0]:
		draw_rect(Rect2(rx, r.position.y + 14.0, 14.0, r.size.y - 28.0), Color("2a2d32"))
		var yy := r.position.y + 30.0
		while yy < r.end.y - 20.0:
			draw_rect(Rect2(rx + 4.0, yy, 6.0, 6.0), Color("0b0c0e"))
			yy += 30.0
	var installing := phase == "shop" and not install_queue.is_empty() and ui_live
	var idle := _rack_idle()
	var bk := _bench_kind()
	for i in rack.size():
		if rack[i].is_empty() and _slot_taken(i):
			continue
		var g: Dictionary = rack[i]
		var br := _unit_rect(i)
		if installing:
			if g.is_empty():
				_draw_empty_bay(br)
			else:
				_draw_gear(br, g, comp_flash[i], i)
			var inst: Dictionary = install_queue[0]
			var tr := _bay_rect(i / 2) if _gear_full(inst) else br
			var good := _install_anchor(inst, i) >= 0
			var hot := tr.has_point(mouse) and good
			if good:
				_panel(tr.grow(6.0), Color(c_gold, 0.12 if hot else 0.0), 10, Color(c_gold, 0.95 if hot else 0.45 + 0.25 * sin(clock * 5.0)), 5 if hot else 3)
			else:
				_panel(tr, Color(0, 0, 0, 0.45), 6)
			if hot:
				var occ: Dictionary = g if not g.is_empty() else (rack[(i / 2) * 2] if _gear_full(inst) else {})
				var label := "Install here" if occ.is_empty() else "Replace %s" % gear_defs[occ["id"]]["name"]
				var lw := _text_w(label, T_MD, true) + 40.0
				var lr := Rect2(tr.get_center().x - lw * 0.5, tr.get_center().y - 28.0, lw, 56.0)
				_panel(lr, Color(0.06, 0.07, 0.09, 0.92), 28)
				_text_center(lr, label, T_MD, c_gold, true)
			if install_price > 0:
				_hold(tr, "inst%d" % i, "Hold to buy", _install.bind(i))
			else:
				_register(tr, _install.bind(i))
			continue
		if idle and bk == "":
			_register(br, _gear_click.bind(i))
		if g.is_empty():
			_draw_empty_bay(br)
		else:
			_draw_gear(br, g, comp_flash[i], i)
		if gear_sel == i:
			_panel(br.grow(6.0), Color(c_gold, 0.1), 10, c_gold, 5)
		elif gear_sel >= 0 and idle and br.has_point(mouse):
			_panel(br.grow(6.0), Color(0, 0, 0, 0), 10, Color(c_gold, 0.7), 3)
		if bk == "tweak" and ui_live and phase == "shop" and not g.is_empty():
			var ok := String(g["id"]) in ["genre_eq", "decade_eq"]
			_panel(br.grow(6.0), Color(0, 0, 0, 0), 10, Color(c_gold, 0.45 + 0.25 * sin(clock * 5.0)) if ok else Color(0, 0, 0, 0), 3)
			if not ok:
				_panel(br, Color(0, 0, 0, 0.45), 6)
	if gear_sel >= 0 and not rack[gear_sel].is_empty():
		var nm := "Moving the %s" % gear_defs[rack[gear_sel]["id"]]["name"]
		var tw := _text_w(nm, T_SM, true) + 28.0
		var tr2 := Rect2(mouse + Vector2(18.0, 18.0), Vector2(tw, 40.0))
		_panel(tr2, Color(0.06, 0.07, 0.09, 0.92), 20)
		_text_center(tr2, nm, T_SM, c_gold, true)

func _marker_w(s: String, size: int) -> float:
	return _marker_font().get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x

func _marker_fit(s: String, size: int, maxw: float) -> int:
	var w := _marker_w(s, size)
	return size if w <= maxw else maxi(10, int(floor(size * maxw / w)))

func _marker_l(x: float, y: float, s: String, size: int, col: Color, rot: float = 0.0) -> void:
	_marker(Vector2(x + _marker_w(s, size) * 0.5, y), s, size, col, rot)

func _marker_lines(s: String, size: int, maxw: float) -> Array:
	var lines: Array = []
	var cur := ""
	for word in s.split(" "):
		var t := word if cur == "" else cur + " " + word
		if cur != "" and _marker_w(t, size) > maxw:
			lines.append(cur)
			cur = word
		else:
			cur = t
	if cur != "":
		lines.append(cur)
	return lines

func _tag_names(tags: Array) -> String:
	var out: Array = []
	for t: Array in tags:
		out.append(String(t[1]))
	return ", ".join(out)

func _draw_paper(p: Rect2, tgt: int) -> void:
	var vs := p.size.y / 286.0
	var fs := sqrt(vs)
	_shadow(p, 2, 6.0)
	_panel(p, Color("f4efe4"), 6)
	draw_rect(Rect2(p.get_center().x - 50.0, p.position.y - 12.0, 100.0, 26.0), Color(1, 1, 1, 0.55))
	var ink := Color("15171b")
	var red := Color("c4161c")
	var left := p.position.x + 24.0
	var nm := String(venue.get("name", ""))
	_marker_l(left, p.position.y + 50.0 * vs, nm, _marker_fit(nm, int(34.0 * fs), 340.0), ink)
	var big := _fmt_int(tgt)
	var bsz := _marker_fit(big, int(84.0 * fs), 230.0)
	_marker_l(p.end.x - 24.0 - _marker_w(big, bsz), p.position.y + 56.0 * vs, big, bsz, red)
	if _boss_kind() != "":
		_marker_l(left, p.position.y + 92.0 * vs, "BOSS  ·  " + String(_boss_info(venue["challenge"])["short"]), int(18.0 * fs), red.darkened(0.2))
	var colw := (p.size.x - 226.0 - 24.0 - 30.0) * 0.5
	var hx := left + colw + 30.0
	var like_head := "+%d points" % D.LIKE
	var hate_head := "No points" if _boss_kind() == "hates" else "Half points"
	var like_names := _tag_names(venue.get("likes", []))
	var hate_names := _tag_names(venue.get("dislikes", []))
	var hy := p.position.y + 150.0 * vs
	var ny := p.position.y + 206.0 * vs
	_marker_l(left, hy, like_head, _marker_fit(like_head, int(30.0 * fs), colw), ink)
	_marker_l(left, ny, like_names, _marker_fit(like_names, int(28.0 * fs), colw), Color("1f7a3a"))
	_marker_l(hx, hy, hate_head, _marker_fit(hate_head, int(30.0 * fs), colw), red)
	_marker_l(hx, ny, hate_names, _marker_fit(hate_names, int(28.0 * fs), colw), red)
	var note := Rect2(p.end.x - 218.0, p.position.y + 100.0 * vs, 198.0, p.size.y - 100.0 * vs - 22.0)
	_shadow(note, 2, 5.0)
	_panel(note, Color("fff3a8") if not call.is_empty() else Color("e9e4d2"), 2)
	draw_rect(Rect2(note.get_center().x - 36.0, note.position.y - 8.0, 72.0, 20.0), Color(1, 1, 1, 0.55))
	if call.is_empty():
		var idle := _marker_lines("No requests right now", 24, note.size.x - 30.0)
		for k in idle.size():
			_marker(Vector2(note.get_center().x, note.get_center().y - 14.0 + k * 32.0), String(idle[k]), 24, Color("6f7378"), 0.0)
		return
	_marker(Vector2(note.get_center().x, note.position.y + 26.0), "REQUEST", 16, Color("6f6a3a"), 0.0)
	var lines := _marker_lines(_call_text(call), 28, note.size.x - 24.0)
	for k in lines.size():
		_marker(Vector2(note.get_center().x, note.position.y + 76.0 + k * 36.0), String(lines[k]), 28, ink, 0.0)
	_marker(Vector2(note.get_center().x, note.end.y - 26.0), "+%d points" % _request_pts(), 24, Color("1f7a3a"), 0.0)

func _song_display(r: Rect2, text: String, moving: bool) -> void:
	_panel(r.grow(5.0), Color("0a0b0d"), 9)
	_grad_panel(r, 6.0, Color("dfe7d2"), Color("b9c6aa"))
	draw_colored_polygon(PackedVector2Array([r.position + Vector2(6, 4), r.position + Vector2(r.size.x * 0.45, 4), r.position + Vector2(r.size.x * 0.3, r.size.y * 0.5), r.position + Vector2(6, r.size.y * 0.5)]), Color(1, 1, 1, 0.12))
	var ink := Color("1c2a1e")
	var size := 40
	var tw := _text_w(text, size, true)
	var pad := 22.0
	var yb := r.get_center().y + _vc(font_bold, size)
	if not moving:
		_text(Vector2(r.get_center().x - tw * 0.5, yb), text, size, Color(ink, 0.55), true)
		return
	var period := tw + 220.0
	var off := fmod(float(Time.get_ticks_msec()) * 0.001 * 110.0, period)
	var copies := int(ceil(r.size.x / period)) + 1
	var xs: Array = []
	for i in text.length():
		xs.append(_text_w(text.substr(0, i), size, true))
	for c in range(-copies, 2):
		var base := r.end.x - pad - off + c * period
		for i in text.length():
			var cx: float = base + float(xs[i])
			var cw := _text_w(text.substr(i, 1), size, true)
			var a := clampf((cx - (r.position.x + pad)) / 36.0, 0.0, 1.0) * clampf(((r.end.x - pad) - (cx + cw)) / 36.0, 0.0, 1.0)
			if a > 0.0:
				_text(Vector2(cx, yb), text.substr(i, 1), size, Color(ink, a), true)

func _draw_score_panel() -> void:
	var r := r_score
	_shadow(r, 16, 12.0)
	_surface(r, 16.0, "metal_dark", Color("2b2e33"), Color("1a1c20"))
	draw_line(r.position + Vector2(16.0, 2.0), Vector2(r.end.x - 16.0, r.position.y + 2.0), Color(1, 1, 1, 0.25), 2.0)
	_panel(r, Color(0, 0, 0, 0), 16, Color(0, 0, 0, 0.6), 2)
	for p in [r.position + Vector2(22, 22), Vector2(r.end.x - 22, r.position.y + 22), Vector2(r.position.x + 22, r.end.y - 22), r.end - Vector2(22, 22)]:
		_screw(p, 7.0)
	var x := r.position.x + 40.0
	var w := r.size.x - 80.0
	var y := r.position.y
	var shown := 0
	if score_mode == "song":
		shown = score_live if playing else score_tot
	elif fin_t >= 0.0:
		shown = _fin_value()
	elif phase == "end":
		shown = score_tot
	var pts_v := song_pts
	if score_mode == "end":
		pts_v = fin_from if fin_t >= 0.0 else (score_live if playing else score_tot)
	var tgt := _gig_target()
	var fc := Color(D.FLOW_COLOR).lightened(0.3)
	var pc := Color(D.SOUND_COLOR).lightened(0.25)
	var dim := Color("8d939b")
	_draw_paper(Rect2(x, y + 872.0, w, 364.0), tgt)
	_silk(Vector2(x, y + 322.0), "NOW PLAYING", 15, Color(1, 1, 1, 0.9))
	var cur := _playing_disc()
	var song := "READY"
	var moving := false
	if cur != null:
		song = "%s  -  %s" % [cur.title, cur.band]
		moving = true
	elif resolving:
		song = "SET COMPLETE"
	_song_display(Rect2(x, y + 334.0, w, 76.0), song, moving)
	_eq_strip(Rect2(x, y + 424.0, w, 62.0))
	var meter := Rect2(x, y + 206.0, w, 56.0)
	_inset(meter, 6.0, Color("0b0c0e"))
	var frac := clampf(float(shown) / (2.0 * tgt), 0.0, 1.0)
	var gfrac := 0.0
	if score_mode == "end" and resolving and fin_t < 0.0:
		gfrac = clampf(float(pts_v) * flow_live / (2.0 * tgt), 0.0, 1.0)
	var bars := 28
	var bw := (meter.size.x - 24.0) / bars
	for k in bars:
		var on := float(k) / bars < frac
		var ghost := not on and float(k) / bars < gfrac
		var col := _score_color(float(k) / bars * 2.0 * tgt)
		var br := Rect2(meter.position.x + 12.0 + k * bw, meter.position.y + 10.0, bw - 4.0, meter.size.y - 20.0)
		_panel(br, col if on else (Color(col, 0.38) if ghost else Color(col, 0.08)), 2)
	var span := meter.size.x - 24.0
	for tier: Array in [[0.5, "TARGET", tgt], [0.75, "APPLAUSE", int(round(tgt * D.TIER_GOOD))], [1.0, "ENCORE", int(round(tgt * D.TIER_GREAT))]]:
		var tx := meter.position.x + 12.0 + span * float(tier[0])
		var hit := float(shown) >= float(tier[2])
		draw_line(Vector2(tx, meter.position.y + 4.0), Vector2(tx, meter.end.y - 4.0), Color(1, 1, 1, 0.55), 2.0)
		var lab := "%s %s" % [tier[1], _fmt_int(int(tier[2]))]
		var lw := _text_w(lab, 13, true)
		var lx := minf(tx - lw * 0.5, x + w - lw)
		_text(Vector2(lx, meter.end.y + 26.0), lab, 13, c_gold if hit else dim, true)
	var sl := _score_lcd()
	_lcd(sl, _fmt_int(shown), _score_color(float(shown)), _lcd_size(sl, 96), "888,888", "center")
	_silk(Vector2(sl.position.x + 14.0, sl.position.y + 24.0), "SCORE", 13, Color(_score_color(float(shown)), 0.55))
	_draw_cd_player(Rect2(x + w - 340.0, y + 506.0, 340.0, 340.0))
	var pl := _pts_lcd()
	var fl := _flow_lcd()
	_silk(Vector2(pl.position.x, pl.position.y - 12.0), "POINTS" if score_mode == "end" else "SONG POINTS", 14, dim)
	_silk(Vector2(fl.position.x, fl.position.y - 12.0), "FLOW", 14, dim)
	if pts_pulse > 0.0:
		_panel(pl.grow(4.0 + 12.0 * pts_pulse), Color(pc, 0.5 * pts_pulse), 14)
	if flow_pulse > 0.0:
		_panel(fl.grow(4.0 + 12.0 * flow_pulse), Color(fc, 0.5 * flow_pulse), 14)
	var lsz := _lcd_size(pl, 64)
	_lcd(pl, _fmt_int(pts_v), pc, int(lsz * (1.0 + 0.12 * pts_pulse)), "888,888")
	_lcd(fl, _fmt_flow(flow_live), fc, int(lsz * (1.0 + 0.12 * flow_pulse)), "88.88")

func _focus_slot() -> int:
	if now_slot >= 0:
		return now_slot
	if sel_slot >= 0:
		return sel_slot
	for k in D.SETLIST:
		if _case_rect(k).grow(8.0).has_point(mouse):
			return k
	if resolving:
		return mini(played.size(), D.SETLIST - 1)
	var e := tray.find(-1)
	return e if e >= 0 else -1

func _info_chip(x: float, y: float, text: String, col: Color) -> float:
	var w := _text_w(text, 12, true) + 16.0
	var cr := Rect2(x, y, w, 30.0)
	_panel(cr, col, 9, Color(D.FLOW_COLOR).lightened(0.3), 2)
	_text_center(cr, text, 12, Color.WHITE, true)
	return w

func _draw_empty_bay(r: Rect2) -> void:
	_shadow(r, 6, 4.0)
	_surface(r, 6.0, "metal_dark", Color("26292e"), Color("1a1c20"))
	_panel(r, Color(0, 0, 0, 0), 6, Color(0, 0, 0, 0.6), 1)
	for ex in [r.position.x + 18.0, r.end.x - 18.0]:
		for ey in [r.position.y + 24.0, r.end.y - 24.0]:
			_screw(Vector2(ex, ey), 7.0)
	var cols := maxi(2, int((r.size.x - 100.0) / 68.0))
	for row in 3:
		for col in cols:
			var v := Rect2(r.position.x + 80.0 + col * 68.0, r.position.y + 70.0 + row * 36.0, 52.0, 12.0)
			_inset(v, 6.0, Color("0b0c0e"))
	_text_center(Rect2(r.position.x, r.end.y - 58.0, r.size.x, 30.0), "EMPTY BAY" if r.size.x > 400.0 else "EMPTY", T_SM, Color("6f747c"), true)

func _draw_gear(r: Rect2, g: Dictionary, flash: float, slot: int = -1) -> void:
	var def: Dictionary = gear_defs[g["id"]]
	var id := String(g["id"])
	var full := _gear_full(g)
	var rr := r
	if not full and r.size.x > 400.0:
		rr = Rect2(r.position, Vector2((r.size.x - 12.0) * 0.5, r.size.y))
	if full:
		_rack_unit(rr, String(def["name"]), _gear_text(g), int(rr.position.y) + 41, flash)
	else:
		_rack_unit(rr, String(def["name"]), _gear_text(g), int(rr.position.y) + 41, flash, rr.size.x - 60.0, 30.0)
	if full:
		var ctl := Rect2(rr.position.x + 290.0, rr.position.y + 20.0, rr.size.x - 330.0, rr.size.y - 40.0)
		var tweak := slot >= 0 and _bench_kind() == "tweak"
		match String(def["look"]):
			"faders":
				_ctl_faders(ctl, g["levels"], flash, slot if tweak else -1, id == "decade_eq")
			"knobs":
				_ctl_knobs(ctl, flash)
			"tube":
				_ctl_tube(ctl, flash)
	if slot >= 0:
		var bx := rr.position.x + (44.0 if full else 30.0)
		var bw := 230.0 if full else rr.size.x - 60.0
		var st := _gear_status(g, slot)
		if st != "":
			_wrap(Vector2(bx, rr.end.y - 142.0), st, bw, 16, Color("23262b"), true)
		if bool(def.get("active", false)):
			var left := _gear_m(id) - int(g.get("used", 0))
			var label := ("USE (%d)" % left) if left > 0 else "USED"
			var can := _can_use(g)
			if id == "cd_burner" and burn_mode:
				label = "CANCEL"
				can = true
			_hw_button(Rect2(bx, rr.end.y - 100.0, bw, 52.0), label, _use_gear.bind(slot), can, Color("c9a227"), T_SM)
		if phase == "shop" and install_queue.is_empty() and bench < 0 and ui_live:
			var worth := maxi(1, int(def["price"]) / 2)
			if id == "piggy":
				worth += int(g.get("pot", 0)) * maxi(1, _gear_m(id))
			_hw_button(Rect2(rr.end.x - 126.0, rr.end.y - 50.0, 104.0, 36.0), "SELL $%d" % worth, _sell_gear.bind(slot), true, Color("6a6f77"), T_XS)
	if bool(g.get("broken", false)):
		_panel(rr, Color(0, 0, 0, 0.6), 6)
		_heavy_center(rr, "BROKEN", T_XL, c_bad.lightened(0.2))

func _playing_disc() -> Disc:
	if now_slot >= 0 and tray[now_slot] >= 0:
		return collection[tray[now_slot]]
	return null

func _ctl_faders(ctl: Rect2, levels: Array, flash: float, bay: int = -1, is_era: bool = false) -> void:
	var n := levels.size()
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
		var hit := flash > 0.0 and cur != null and (cur.era if is_era else cur.genre) == gi
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
		_text_center(Rect2(cx - cw, ctl.end.y - 30.0 + (gi % 2) * 16.0, cw * 2.0, 18.0), (D.ERAS if is_era else D.GENRE_SHORT)[gi], 11, Color("23262b") if lv != 0 else Color("6a6f77"), true)
		if bay >= 0 and lv < D.EQ_MAX:
			var col_r := Rect2(cx - cw * 0.5, ctl.position.y, cw, ctl.size.y - 30.0)
			if col_r.has_point(mouse):
				_panel(col_r, Color(c_gold, 0.18), 6, c_gold, 2)
				_tip(col_r, "Raise %s to %+d" % [(D.ERAS if is_era else D.GENRES)[gi], lv + 1])
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
	var cx := 950.0 if phase == "shop" else r_wallet.get_center().x
	var cy := 1330.0 if phase == "shop" else r_wallet.position.y - 30.0
	var r := Rect2(cx - w * 0.5, cy, w, 60.0)
	_panel(r, Color(0.08, 0.1, 0.14, 0.92 * a), 30)
	_text_center(r, message, T_LG, Color(1, 1, 1, a), true)

func _draw_held() -> void:
	if held < 0:
		return
	var d := collection[held]
	_draw_jewel(Rect2(mouse + Vector2(0.0, 6.0) - Vector2(96.0, 96.0), Vector2(192.0, 192.0)), d)

func _tip_disc(r: Rect2, d: Disc) -> void:
	if ui_live and r.has_point(mouse):
		hover_disc = d

func _draw_disc_tip(d: Disc) -> void:
	var w := 600.0
	var pad := 24.0
	var iw := w - pad * 2.0
	var body := ""
	var head := ""
	if not d.cdr:
		head = "EFFECT"
		body = _cond_text(d)
	else:
		head = "MIX"
		body = "When you play it, it picks a random album and becomes that album's genre and decade. The audience, requests and gear treat it like that CD, so it may delight them or turn them against you. It has no effect of its own."
	var fit_head := ""
	var fit_body := ""
	var fit_h := 0.0
	var pile_head := ""
	var pile_body := ""
	if phase == "show" and d.genre >= 0:
		var pg := 0
		var pe := 0
		var tip_pool: Array = draw_pile.duplicate()
		if pile_with_hand:
			for wi in wallet:
				if wi >= 0:
					tip_pool.append(wi)
		for pi in tip_pool:
			pg += _has_tag(collection[pi], false, d.genre)
			pe += _has_tag(collection[pi], true, d.era)
		pile_head = "IN YOUR HAND AND THE DRAW PILE" if pile_with_hand else "LEFT IN THE DRAW PILE"
		pile_body = "%d %s  ·  %d %s  (of %d)" % [pg, D.GENRES[d.genre], pe, D.ERAS[d.era], tip_pool.size()]
	var bh := font.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, iw, T_SM).y if body != "" else 0.0
	var h := pad + 84.0 + 44.0 + (52.0 + bh + 10.0 if body != "" else 0.0) + (fit_h) + (92.0 if pile_head != "" else 0.0) + (84.0 if d.edition != "" else 0.0) + pad - 6.0
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
	_text_i(Vector2(x, y + 64.0), "Picks a random album when played" if d.cdr else "by %s  ·  %s" % [d.band, D.LABELS[d.label]["name"]], T_SM, Color("b8c0cc"))
	y += 84.0
	var chips := [[D.GENRES[d.genre].to_upper(), Color("5d626a")], [D.ERAS[d.era], Color("5d626a")], ["%d POINTS" % d.sound, Color(D.SOUND_COLOR)], [D.LABELS[d.label]["short"].to_upper(), Color(D.LABELS[d.label]["color"])]] if not (d.genre < 0) else [["CD-R", Color(D.FLOW_COLOR).darkened(0.2)]]
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
		_text(Vector2(x, y + 34.0), head, T_XS, c_gold, true)
		_wrap(Vector2(x, y + 46.0), body, iw, T_SM, Color("e8ecf2"))
		y += 52.0 + bh + 10.0
	if pile_head != "":
		draw_line(Vector2(x, y), Vector2(x + iw, y), Color(1, 1, 1, 0.12), 2.0)
		_text(Vector2(x, y + 34.0), pile_head, T_XS, c_gold, true)
		_text(Vector2(x, y + 68.0), pile_body, T_SM, Color("e8ecf2"))
		y += 92.0
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
	_text_center(Rect2(r.position.x, r.position.y + 205.0, r.size.x, 40.0), "You played all %d gigs." % _tour_gigs() if won else "Your tour ended at gig %d of %d." % [gig_n, _tour_gigs()], T_MD, c_body)
	_hw_button(Rect2(r.get_center().x - 160.0, r.end.y - 130.0, 320.0, 86.0), "Main menu", _to_title, true, Color("3f9b5a"), T_LG)

func _to_shop(hint: Dictionary = {}) -> void:
	_make_shop(hint)
	phase = "shop"
	message_t = 0.0

func _leave_shop() -> void:
	install_queue.clear()
	install_price = 0
	install_src = -1
	pack = {}
	bench = -1
	services.clear()
	message_t = 0.0
	binder_open = false
	_back_on_road()

func _album_price(d: Disc) -> int:
	return D.ALBUM_PRICE + (1 if d.sound >= 10 else 0)

func _make_shop(hint: Dictionary = {}) -> void:
	shop_items.clear()
	var picks: Array = _random_albums(D.SHOP_ALBUMS, int(hint["genre"]) if not hint.is_empty() else -1, int(hint["era"]) if not hint.is_empty() else -1)
	for a: Dictionary in picks:
		var d := _make_disc(a)
		shop_items.append({"kind": "album", "disc": d, "price": _album_price(d), "sold": false})
	var ap: Dictionary = D.ALBUM_PACKS[rng.randi_range(0, D.ALBUM_PACKS.size() - 1)]
	shop_items.append({"kind": "album_pack", "pack": ap, "price": int(ap["price"]), "sold": false})
	var gear_ids := _random_gear_ids(D.SHOP_GEAR)
	if not hint.is_empty() and not String(hint["gear"]) in gear_ids and not String(hint["gear"]) in _owned_gear():
		if gear_ids.is_empty():
			gear_ids.append(String(hint["gear"]))
		else:
			gear_ids[0] = String(hint["gear"])
	for k in D.SHOP_GEAR:
		if k < gear_ids.size():
			shop_items.append({"kind": "gear", "gear": _make_gear(gear_ids[k]), "price": int(gear_defs[gear_ids[k]]["price"]), "sold": false})
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
			for a in _random_albums(int(ap["show"])):
				items.append(_make_disc(a))
			pack = {"kind": "album", "title": ap["name"], "pick": int(ap["pick"]), "items": items}
			pack_sel.clear()
			_pack_start()
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
			_pack_start()

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
	if cash < int(sv["price"]) or g.is_empty() or not String(g["id"]) in ["genre_eq", "decade_eq"]:
		return
	g["levels"][idx] = mini(D.EQ_MAX, int(g["levels"][idx]) + 1)
	var nm := String(D.GENRES[idx]) if String(g["id"]) == "genre_eq" else "The " + String(D.ERAS[idx])
	_say("%s is now %+d." % [nm, int(g["levels"][idx])])
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
	if rng.randf() < float(D.SERVICE_CHANCE["tweak"]) and rack.any(func(g): return not g.is_empty() and g["id"] in ["genre_eq", "decade_eq"]):
		pool.append({"kind": "tweak", "price": D.TWEAK_PRICE, "sold": false})
	_shuffle(pool)
	services = pool.slice(0, D.SERVICES_MAX)

func _install(slot: int) -> void:
	if install_queue.is_empty():
		return
	var t := _install_anchor(install_queue[0], slot)
	if t < 0:
		_say("That unit needs a bay with room for it.")
		return
	if install_price > 0:
		if cash < install_price:
			return
		cash -= install_price
		shop_items[install_src]["sold"] = true
	var g: Dictionary = install_queue.pop_front()
	_put_unit(g, t)
	comp_flash[t] = 1.0
	install_price = 0
	install_src = -1
	_sfx("page_turn")
	_say("Installed the %s." % gear_defs[g["id"]]["name"])

func _draw_shop() -> void:
	draw_rect(Rect2(-800, -800, UI_W + 1600, UI_H + 1600), Color("3a302b"))
	var x := -40.0
	while x < r_rack.position.x:
		draw_line(Vector2(x, -800.0), Vector2(x, UI_H + 800.0), Color(0, 0, 0, 0.08), 3.0)
		x += 120.0
	var sign := Rect2(450.0, 50.0, 1000.0, 130.0)
	for sx: float in [sign.position.x + 90.0, sign.end.x - 90.0]:
		draw_line(Vector2(sx, -40.0), Vector2(sx, sign.position.y), Color("5f5e5a"), 4.0)
	_shadow(sign, 12, 8.0)
	_panel(sign, Color("1d1a17"), 12, c_gold, 3)
	_panel(sign.grow(-10.0), Color(c_gold, 0.08), 8)
	_heavy_center(Rect2(sign.position.x, sign.position.y + 8.0, sign.size.x, 70.0), "THE B-SIDE", T_XL + 16, c_gold)
	var sub := "USED CDs  ·  AUDIO GEAR"
	var sub_col := Color(c_gold, 0.75)
	if not install_queue.is_empty():
		sub = "Choose a rack bay for the %s" % gear_defs[(install_queue[0] as Dictionary)["id"]]["name"]
		sub_col = Color("f4efe4")
	_text_center(Rect2(sign.position.x, sign.position.y + 80.0, sign.size.x, 36.0), sub, T_SM, sub_col, true)
	_draw_records_aisle(Rect2(60.0, 210.0, 580.0, 1190.0))
	_draw_gear_aisle(Rect2(660.0, 210.0, 580.0, 1190.0))
	_draw_work_aisle(Rect2(1260.0, 210.0, 580.0, 1190.0))
	_draw_shop_nav()

func _draw_records_aisle(w: Rect2) -> void:
	_shadow(w, 10, 12.0)
	_panel(w, Color("1c1714"), 10)
	_grad_panel(Rect2(w.position.x, w.position.y, w.size.x, 70.0), 10.0, Color(0, 0, 0, 0.5), Color(0, 0, 0, 0.0))
	_aisle_label(w, "RECORDS")
	for k in 3:
		var it: Dictionary = shop_items[k]
		var cr := Rect2(w.get_center().x - 170.0, w.position.y + 100.0 + k * 360.0, 340.0, 301.0)
		_crate_wood(Rect2(cr.position.x - 20.0, cr.end.y + 24.0, cr.size.x + 40.0, 22.0), 7 + k)
		if bool(it["sold"]):
			_heavy_center(cr, "SOLD", T_XL, Color(1, 1, 1, 0.1))
			continue
		var afford := cash >= int(it["price"])
		var hot := ui_live and afford and cr.has_point(mouse)
		var rr := Rect2(cr.position - Vector2(0.0, 10.0 if hot else 0.0), cr.size)
		if it["kind"] == "album":
			var d: Disc = it["disc"]
			_draw_case(rr, d, int(it["price"]))
			_tip_disc(cr, d)
			if ui_live and cr.has_point(mouse):
				_audition(d)
		else:
			_draw_case_pack(rr, it["pack"], int(it["price"]))
			var ap: Dictionary = it["pack"]
			_tip(cr, "%s: open it and pick %d of %d albums for your binder." % [ap["name"], int(ap["pick"]), int(ap["show"])])
		if not afford:
			_panel(rr, Color(0, 0, 0, 0.5), 6)
		if ui_live and afford:
			_hold(cr, "buy%d" % k, "Hold to buy", _buy.bind(k))

func _draw_gear_aisle(w: Rect2) -> void:
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
	_aisle_label(w, "GEAR")
	var ux := w.position.x + 30.0
	for k in 2:
		var it: Dictionary = shop_items[3 + k]
		var ur := Rect2(ux, w.position.y + 100.0 + k * 330.0, 520.0, 220.0)
		_shelf(Rect2(w.position.x + 10.0, ur.end.y + 8.0, w.size.x - 20.0, 16.0))
		if bool(it["sold"]):
			_heavy_center(ur, "SOLD", T_XL, Color(0, 0, 0, 0.25))
			continue
		var afford := cash >= int(it["price"])
		_draw_gear(ur, it["gear"], 0.0)
		var vr := ur if _gear_full(it["gear"]) else Rect2(ur.position, Vector2((ur.size.x - 12.0) * 0.5, ur.size.y))
		var picked := install_src == 3 + k
		if picked:
			_panel(vr.grow(6.0), Color(0, 0, 0, 0), 10, c_gold, 5)
		if not afford:
			_panel(vr, Color(0, 0, 0, 0.45), 6)
		_hang_tag(Vector2(ur.end.x - 70.0, ur.end.y + 38.0), "$%d" % int(it["price"]))
		if ui_live and afford and install_queue.is_empty():
			if vr.has_point(mouse):
				_panel(vr.grow(4.0), Color(0, 0, 0, 0), 10, Color(c_gold, 0.8), 3)
			_register(ur, _buy.bind(3 + k))
	var it5: Dictionary = shop_items[5]
	var bx := Rect2(ux + 30.0, w.position.y + 100.0 + 660.0, 440.0, 250.0)
	_shelf(Rect2(w.position.x + 10.0, bx.end.y + 8.0, w.size.x - 20.0, 16.0))
	if bool(it5["sold"]):
		_heavy_center(bx, "SOLD", T_XL, Color(0, 0, 0, 0.25))
	else:
		var gp: Dictionary = it5["pack"]
		var afford5 := cash >= int(it5["price"])
		var hot := ui_live and afford5 and install_queue.is_empty() and bx.has_point(mouse)
		_cardboard_box(Rect2(bx.position - Vector2(0.0, 8.0 if hot else 0.0), bx.size), String(gp["name"]), "PICK %d OF %d" % [int(gp["pick"]), int(gp["show"])])
		if not afford5:
			_panel(bx, Color(0, 0, 0, 0.45), 4)
		_hang_tag(Vector2(bx.end.x - 20.0, bx.end.y + 38.0), "$%d" % int(it5["price"]))
		_tip(bx, "%s: open it and keep %d of %d pieces of gear." % [gp["name"], int(gp["pick"]), int(gp["show"])])
		if ui_live and afford5 and install_queue.is_empty():
			_hold(bx, "buy5", "Hold to buy", _buy.bind(5))

func _draw_work_aisle(w: Rect2) -> void:
	_shadow(w, 8, 10.0)
	_surface(w, 8.0, "wood", Color("5e412c"), Color("3e2a1c"), 700.0)
	if _tex("wood") == null:
		_grain(w, 23, 900.0)
	_panel(w, Color(0, 0, 0, 0), 8, Color(0, 0, 0, 0.5), 2)
	_aisle_label(w, "WORK ORDERS")
	_draw_services(Rect2(w.position.x + 30.0, w.position.y + 100.0, w.size.x - 60.0, 640.0))
	var led := Rect2(w.position.x + 30.0, w.end.y - 250.0, w.size.x - 60.0, 220.0)
	_shadow(led, 10, 8.0)
	_surface(led, 10.0, "metal_dark", Color("2b2e33"), Color("1a1c20"))
	_panel(led, Color(0, 0, 0, 0), 10, Color(0, 0, 0, 0.6), 2)
	_silk(Vector2(led.position.x + 30.0, led.position.y + 70.0), "BINDER", T_SM, Color("8d939b"))
	_text_right(led.end.x - 30.0, led.position.y + 70.0, "%d albums" % collection.size(), T_LG, Color("e6e9ed"), true)
	_silk(Vector2(led.position.x + 30.0, led.position.y + 130.0), "SHOWS PLAYED", T_SM, Color("8d939b"))
	_text_right(led.end.x - 30.0, led.position.y + 130.0, str(gig_n), T_LG, Color("e6e9ed"), true)
	_silk(Vector2(led.position.x + 30.0, led.position.y + 190.0), "RIG", T_SM, Color("8d939b"))
	var used := 0
	for g: Dictionary in rack:
		if not g.is_empty():
			used += 1
	_text_right(led.end.x - 30.0, led.position.y + 190.0, ("%d unit" if used == 1 else "%d units") % used, T_LG, Color("e6e9ed"), true)

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

func _draw_case(r: Rect2, d: Disc, price: int = -1) -> void:
	_draw_jewel(r, d, 0.0, price)

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
			_text_center(Rect2(ins.position.x, ins.position.y + ins.size.y * 0.25 + 46.0, ins.size.x, 30.0), "PICK %d OF %d" % [int(ap["pick"]), int(ap["show"])], T_XS, Color(1, 1, 1, 0.6), true)
	var wrap := r.grow(-4.0)
	_panel(wrap, Color(1, 1, 1, 0.06), 10, Color(1, 1, 1, 0.3), 2)
	draw_line(wrap.position + Vector2(30, 6), wrap.position + Vector2(8, 60), Color(1, 1, 1, 0.35), 3.0)
	draw_line(Vector2(wrap.end.x - 40.0, wrap.end.y - 8.0), Vector2(wrap.end.x - 8.0, wrap.end.y - 50.0), Color(1, 1, 1, 0.25), 2.0)
	if price >= 0:
		_price_sticker(Vector2(r.end.x - 4.0, r.position.y + 4.0), "$%d" % price, k)

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

func _spring(u: float, damp: float, freq: float) -> float:
	if u <= 0.0:
		return 0.0
	return 1.0 - exp(-damp * u) * cos(freq * u)

func _pack_item_pos(k: int, n: int, albums: bool) -> Vector2:
	if albums:
		return Vector2(_pack_cx() + (k - (n - 1) * 0.5) * 410.0, 730.0)
	var items: Array = pack["items"]
	var widths: Array = []
	var total := 60.0 * (n - 1)
	for it in items:
		var w := 560.0 if _gear_full(it) else 274.0
		widths.append(w)
		total += w
	var x := _pack_cx() - total * 0.5
	for i in k:
		x += float(widths[i]) + 60.0
	return Vector2(x + float(widths[k]) * 0.5, 730.0)

func _pack_item_rarity(it) -> String:
	if it is Disc:
		return String((it as Disc).rarity)
	var pr := int(gear_defs[String(it["id"])]["price"])
	return "rare" if pr >= 7 else ("uncommon" if pr == 6 else "common")

func _pack_time_item(k: int) -> float:
	return D.PACK_BUILD + D.PACK_BURST_WAIT + k * D.PACK_GAP

func _pack_ready_time() -> float:
	var n := (pack["items"] as Array).size()
	return _pack_time_item(n - 1) + D.PACK_ANIM * 0.8

func _pack_ready() -> bool:
	return not pack.is_empty() and pack_t >= _pack_ready_time()

func _pack_cx() -> float:
	return lerpf(UI_W * 0.5, 950.0, pack_slide)

func _pack_c() -> Vector2:
	return Vector2(_pack_cx(), 720.0)

func _pack_start() -> void:
	pack_t = 0.0
	pack_slide = 0.0
	pack_rig_open = false
	pack_burst = false
	pack_skipped = false
	pack_revealed.clear()
	pack_sparks.clear()
	pack_fx.clear()
	for i in 90:
		pack_fx.append({"a0": rng.randf_range(0.0, TAU), "w": rng.randf_range(0.7, 2.2) * (1.0 if rng.randf() < 0.5 else -1.0), "r0": rng.randf_range(160.0, 440.0), "sz": rng.randf_range(2.0, 5.5), "ph": rng.randf_range(0.0, TAU)})

func _pack_spark(p: Vector2, v: Vector2, life: float, col: Color, r: float, drag: float = 1.6) -> void:
	pack_sparks.append({"p": p, "v": v, "t": 0.0, "life": life, "col": col, "r": r, "drag": drag})

func _pack_burst_fx() -> void:
	fin_shake = maxf(fin_shake, 0.35)
	_sfx("boom")
	var cols := [Color("ffd24a"), Color("ffffff"), Color("8fe9ff"), Color("ff9ec4")]
	for i in 150:
		_pack_spark(_pack_c(), Vector2.from_angle(rng.randf_range(0.0, TAU)) * rng.randf_range(400.0, 2000.0), rng.randf_range(0.9, 1.9), cols[rng.randi_range(0, cols.size() - 1)], rng.randf_range(3.0, 9.0))

func _pack_reveal_fx(k: int, n: int, albums: bool, rar: String) -> void:
	var rp: Dictionary = D.PACK_RARITY[rar]
	var col := Color(String(rp["col"]))
	var pos := _pack_item_pos(k, n, albums)
	var cnt := 18 if rar == "common" else (44 if rar == "uncommon" else 110)
	for i in cnt:
		_pack_spark(pos, Vector2.from_angle(rng.randf_range(0.0, TAU)) * rng.randf_range(150.0, 450.0 if rar == "common" else (800.0 if rar == "uncommon" else 1400.0)), rng.randf_range(0.6, 1.4), col.lerp(Color.WHITE, rng.randf_range(0.0, 0.6)), rng.randf_range(2.0, 6.0 if rar != "rare" else 9.0))
	if rar == "rare":
		fin_shake = maxf(fin_shake, 0.22)
		_sfx("boom")
	elif rar == "uncommon":
		if tick_player != null:
			tick_player.pitch_scale = 1.7
			tick_player.play()
	else:
		_sfx("page_turn")

func _tick_pack(delta: float) -> void:
	if pack.is_empty():
		return
	var before := pack_t
	pack_t += delta
	pack_slide = move_toward(pack_slide, 1.0 if pack_rig_open else 0.0, delta * 5.0)
	var items: Array = pack["items"]
	var n := items.size()
	var albums: bool = pack["kind"] == "album"
	if pack_t < D.PACK_BUILD:
		var step := int(pack_t * 7.0)
		if step != int(before * 7.0) and tick_player != null:
			tick_player.pitch_scale = lerpf(0.8, 2.4, pack_t / D.PACK_BUILD)
			tick_player.play()
	if not pack_burst and pack_t >= D.PACK_BUILD:
		pack_burst = true
		if not pack_skipped:
			_pack_burst_fx()
	for k in n:
		if not (k in pack_revealed) and pack_t >= _pack_time_item(k):
			pack_revealed.append(k)
			if not pack_skipped:
				_pack_reveal_fx(k, n, albums, _pack_item_rarity(items[k]))
	for i in range(pack_sparks.size() - 1, -1, -1):
		var f: Dictionary = pack_sparks[i]
		f["t"] = float(f["t"]) + delta
		var v: Vector2 = f["v"]
		v *= exp(-float(f["drag"]) * delta)
		f["v"] = v
		f["p"] = Vector2(f["p"]) + v * delta
		if float(f["t"]) >= float(f["life"]):
			pack_sparks.remove_at(i)

func _pack_glow(c: Vector2, base: float, col: Color, power: float) -> void:
	for k in 9:
		var f := float(k) / 9.0
		draw_circle(c, base * (1.0 + 0.7 * power * (1.0 - f)), Color(col, minf(0.5, 0.06 * power * (k + 1) / 9.0)))

func _base_origin() -> Vector2:
	if fin_shake > 0.0:
		return screen_origin + Vector2(sin(clock * 91.0), cos(clock * 77.0)) * 16.0 * fin_shake * ui_scale
	return screen_origin

func _hold(r: Rect2, key: String, label: String, cb: Callable) -> void:
	if not ui_live:
		return
	hold_targets.append({"rect": r, "key": key, "label": label})
	_register(r, _hold_begin.bind(key, cb, r))

func _hold_begin(key: String, cb: Callable, r: Rect2) -> void:
	hold_key = key
	hold_cb = cb
	hold_rect = r
	hold_t = 0.0

func _tick_hold(delta: float) -> void:
	if hold_key == "":
		return
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or not hold_rect.has_point(_ui_mouse()):
		hold_key = ""
		hold_t = 0.0
		return
	hold_t += delta
	if hold_t >= D.HOLD_TIME:
		var cb := hold_cb
		hold_key = ""
		hold_t = 0.0
		cb.call()

func _draw_hold() -> void:
	for tg: Dictionary in hold_targets:
		var r: Rect2 = tg["rect"]
		if hold_key == String(tg["key"]):
			var f := clampf(hold_t / D.HOLD_TIME, 0.0, 1.0)
			draw_rect(Rect2(r.position.x, r.end.y - r.size.y * f, r.size.x, r.size.y * f), Color(c_gold, 0.26))
			draw_rect(Rect2(r.position.x, r.end.y - 10.0, r.size.x * f, 10.0), c_gold)
			_panel(r.grow(4.0), Color(0, 0, 0, 0), 10, c_gold, 4)
		elif hold_key == "" and r.has_point(mouse):
			var lab := String(tg["label"])
			var w := _text_w(lab, T_SM, true) + 36.0
			var pr := Rect2(r.get_center().x - w * 0.5, minf(r.end.y + 8.0, UI_H - 56.0), w, 42.0)
			_panel(pr, Color(0.06, 0.07, 0.09, 0.94), 21, Color(c_gold, 0.6), 2)
			_text_center(pr, lab, T_SM, c_gold, true)

func _toggle_rig() -> void:
	pack_rig_open = not pack_rig_open

func _draw_rig_handle() -> void:
	var hr := Rect2(1784.0 if pack_rig_open else 2496.0, 650.0, 60.0, 120.0)
	var hot := hr.has_point(mouse)
	_panel(hr, Color("26292e") if not hot else Color("33373d"), 14, Color(c_gold, 0.7), 2)
	var cx := hr.get_center().x
	var cy := hr.get_center().y
	var dir := 1.0 if pack_rig_open else -1.0
	draw_polyline(PackedVector2Array([Vector2(cx - 9.0 * dir, cy - 18.0), Vector2(cx + 9.0 * dir, cy), Vector2(cx - 9.0 * dir, cy + 18.0)]), c_gold, 6.0, true)
	_register(hr, _toggle_rig)

func _pack_take(k: int) -> void:
	if pack.is_empty() or k in pack_sel:
		return
	pack_sel.append(k)
	_sfx("page_turn")
	if pack_sel.size() >= int(pack["pick"]):
		_take_pack()

func _skip_pack() -> void:
	if not pack.is_empty() and not pack_sel.is_empty():
		_take_pack()
		return
	pack = {}
	pack_sel.clear()

func _draw_pack() -> void:
	var items: Array = pack["items"]
	var pick := int(pack["pick"])
	var albums: bool = pack["kind"] == "album"
	var n := items.size()
	var t := pack_t
	var ready := _pack_ready()
	var full := Rect2(Vector2(-800, -800), Vector2(UI_W, UI_H) + Vector2(1600, 1600))
	var a_bg := clampf(t / 0.5, 0.0, 1.0)
	draw_rect(full, Color(0, 0, 0, a_bg))
	_register(full, func(): pass)
	if pack_rig_open:
		var dr := Rect2(1850.0, -20.0, 730.0, UI_H + 40.0)
		_surface(dr, 0.0, "metal_dark", Color("1d1f23"), Color("121316"))
		draw_line(Vector2(dr.position.x, 0.0), Vector2(dr.position.x, UI_H), Color(0, 0, 0, 0.7), 5.0)
		_draw_rack()
	_draw_rig_handle()
	var u_b := clampf(t / D.PACK_BUILD, 0.0, 1.0)
	if t < D.PACK_BUILD + 0.1:
		var pulse := 0.5 + 0.5 * sin(t * (6.0 + 10.0 * u_b))
		for k in 8:
			var f := float(k) / 8.0
			draw_circle(_pack_c(), (170.0 + f * 330.0) * (0.85 + 0.3 * pulse * u_b), Color(1.0, 0.86, 0.55, 0.05 * (1.0 - f) * (0.3 + u_b * 1.4)))
		for arm in 3:
			var pts := PackedVector2Array()
			for j in 28:
				var tt := j / 27.0
				var ang := arm * TAU / 3.0 + t * 2.6 * (1.0 + u_b * 1.5) + tt * 3.4
				var rad := lerpf(150.0, 430.0 * (1.0 - 0.45 * u_b), tt)
				pts.append(_pack_c() + Vector2(cos(ang) * rad, sin(ang) * rad * 0.82))
			draw_polyline(pts, Color(1.0, 0.92, 0.7, 0.18 + 0.4 * u_b), 3.0 + 3.0 * u_b, true)
		var cols := [Color("ffd24a"), Color("ffffff"), Color("8fe9ff"), Color("ff9ec4")]
		for i in pack_fx.size():
			var m: Dictionary = pack_fx[i]
			var ang2 := float(m["a0"]) + float(m["w"]) * t * (1.0 + 2.0 * u_b)
			var rad2 := float(m["r0"]) * (1.0 - 0.6 * u_b * u_b)
			var mp := _pack_c() + Vector2(cos(ang2) * rad2, sin(ang2) * rad2 * 0.82)
			var tw := 0.35 + 0.65 * pow(sin(t * 6.0 + float(m["ph"])), 2.0)
			var mc: Color = cols[i % cols.size()]
			draw_circle(mp, float(m["sz"]) * (1.0 + u_b) * 2.4, Color(mc, 0.12 * tw))
			draw_circle(mp, float(m["sz"]) * (1.0 + 0.5 * u_b), Color(mc, 0.85 * tw))
		var amp := 2.0 + 16.0 * u_b * u_b
		var sh := Vector2(sin(t * 63.0), cos(t * 79.0)) * amp
		var ps := lerpf(0.55, 1.0, _spring(t / 0.6, 6.0, 9.0))
		if albums:
			var pr := Rect2(_pack_c() + sh - Vector2(255.0, 226.0) * ps, Vector2(510.0, 452.0) * ps)
			_draw_case_pack(pr, {"name": pack["title"], "pick": pick, "show": n}, -1)
		else:
			var gr := Rect2(_pack_c() + sh - Vector2(300.0, 160.0) * ps, Vector2(600.0, 320.0) * ps)
			_cardboard_box(gr, String(pack["title"]), "PICK %d OF %d" % [pick, n])
	var tb := t - D.PACK_BUILD
	if tb > 0.0:
		for k in 14:
			var a := k * TAU / 14.0 + tb * 0.4
			var al := clampf(1.0 - tb / 1.0, 0.0, 1.0)
			draw_colored_polygon(PackedVector2Array([_pack_c(), _pack_c() + Vector2.from_angle(a - 0.05) * 1800.0, _pack_c() + Vector2.from_angle(a + 0.05) * 1800.0]), Color(1.0, 0.92, 0.65, 0.2 * al))
		for k in 3:
			var rt := tb - k * 0.1
			if rt > 0.0 and rt < 0.9:
				draw_arc(_pack_c(), rt * 2200.0, 0.0, TAU, 120, Color(1.0, 0.9, 0.55, 0.8 * (1.0 - rt / 0.9)), 18.0 * (1.0 - rt / 0.9) + 2.0, true)
	for k in n:
		var tk0 := _pack_time_item(k)
		if t < tk0:
			continue
		var rar0 := _pack_item_rarity(items[k])
		var rp0: Dictionary = D.PACK_RARITY[rar0]
		var col0 := Color(String(rp0["col"]))
		var pos0 := _pack_item_pos(k, n, albums)
		var u0 := (t - tk0) / D.PACK_ANIM
		var base0 := Vector2(370.0, 328.0) if albums else Vector2(560.0, 238.0)
		if not albums and not _gear_full(items[k]):
			base0 = Vector2(base0.x * 0.5 - 6.0, base0.y)
		var sc0 := _spring(u0, float(rp0["damp"]), float(rp0["freq"]))
		var beat := 1.0 + float(rp0["pulse"]) * sin(clock * float(rp0["speed"]) + k * 1.7)
		var ramp := clampf(u0 * 2.0, 0.0, 1.0)
		if rar0 == "rare":
			for r in 12:
				var ra := r * TAU / 12.0 + clock * 0.35
				draw_colored_polygon(PackedVector2Array([pos0, pos0 + Vector2.from_angle(ra - 0.07) * 480.0 * beat, pos0 + Vector2.from_angle(ra + 0.07) * 480.0 * beat]), Color(col0, 0.18 * ramp * beat))
		var glow0 := float(rp0["glow"]) * ramp * beat
		if glow0 > 0.0:
			_pack_glow(pos0, maxf(base0.x, base0.y) * 0.5 * maxf(sc0, 0.4) * beat, col0, glow0)
	for k in n:
		var tk := _pack_time_item(k)
		if t < tk:
			continue
		var it = items[k]
		var rar := _pack_item_rarity(it)
		var rp: Dictionary = D.PACK_RARITY[rar]
		var col := Color(String(rp["col"]))
		var pos := _pack_item_pos(k, n, albums)
		var u := (t - tk) / D.PACK_ANIM
		var sc := _spring(u, float(rp["damp"]), float(rp["freq"]))
		if sc < 0.06:
			continue
		var base := Vector2(370.0, 328.0) if albums else Vector2(560.0, 238.0)
		var half := not albums and not _gear_full(it)
		if half:
			base = Vector2(base.x * 0.5 - 6.0, base.y)
		var taken := k in pack_sel
		if u < 0.5:
			var ring := u / 0.5
			draw_arc(pos, maxf(base.x, base.y) * (0.4 + 1.4 * ring), 0.0, TAU, 80, Color(col, 0.6 * (1.0 - ring)), 8.0 * (1.0 - ring) + 1.0, true)
		draw_set_transform(_base_origin() + pos * ui_scale, 0.0, Vector2(ui_scale, ui_scale) * sc)
		if albums:
			_draw_case(Rect2(-Vector2(base.x, base.x * 0.886) * 0.5, Vector2(base.x, base.x * 0.886)), it as Disc)
		elif half:
			_draw_gear(Rect2(-base * 0.5, Vector2((base.x + 6.0) * 2.0, base.y)), it, 0.0)
		else:
			_draw_gear(Rect2(-base * 0.5, base), it, 0.0)
		draw_set_transform(_base_origin(), 0.0, Vector2(ui_scale, ui_scale))
		var rect := Rect2(pos - base * sc * 0.5, base * sc)
		if taken:
			draw_rect(rect, Color(0, 0, 0, 0.55))
			_heavy_center(rect, "TAKEN", T_XL, c_gold)
			_panel(rect.grow(6.0), Color(0, 0, 0, 0), 12, c_gold, 5)
		elif ready:
			var cell := Rect2(pos - base * 0.5, base)
			if albums:
				_tip_disc(Rect2(cell.position, Vector2(base.x, base.x * 0.886)), it as Disc)
				if cell.has_point(mouse):
					_audition(it as Disc)
			if pack_sel.size() < pick:
				_hold(cell, "pk%d" % k, "Hold to take", _pack_take.bind(k))
	for f: Dictionary in pack_sparks:
		var fa := clampf(1.0 - float(f["t"]) / float(f["life"]), 0.0, 1.0)
		var fc: Color = f["col"]
		draw_circle(f["p"], float(f["r"]) * 2.4, Color(fc, 0.18 * fa))
		draw_circle(f["p"], float(f["r"]) * fa + 0.5, Color(fc, 0.9 * fa))
	if tb > 0.0 and tb < 0.7:
		var fl := pow(clampf(1.0 - tb / 0.7, 0.0, 1.0), 1.6)
		draw_rect(full, Color(1.0, 0.97, 0.88, fl))
	var ta := clampf((t - D.PACK_BUILD - 0.2) / 0.5, 0.0, 1.0)
	if ta > 0.0:
		_heavy_center(Rect2(_pack_cx() - 800.0, 110.0, 1600.0, 110.0), String(pack["title"]).to_upper(), T_XL + 24, Color(c_gold, ta))
	if ready:
		_text_center(Rect2(_pack_cx() - 600.0, 236.0, 1200.0, 44.0), "Hold to take  ·  %d of %d taken" % [pack_sel.size(), pick], T_MD, Color(1, 1, 1, 0.85), true)
		_hw_button(Rect2(_pack_cx() - 110.0, 1180.0, 220.0, 92.0), "Skip", _skip_pack, true, Color("6a6f77"), T_LG)

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
	if phase != "show":
		return []
	if i in played:
		return ["PLAYED", Color("6a6f77")]
	if i in tray:
		return ["IN CHANGER", Color("3f9b5a")]
	if i in wallet:
		return ["IN HAND", Color("2e6ea6")]
	if i in discard:
		return ["DUG", Color("6a6f77")]
	return []

func _draw_binder_button() -> void:
	var r := Rect2(60.0, 1312.0, 290.0, 84.0)
	if phase == "shop":
		return
	elif phase in ["map", "fork"]:
		r = Rect2(70.0, 1336.0, 340.0, 84.0)
	_hw_button(r, "View binder (%d)" % collection.size(), _toggle_binder, true, C_LEATHER.lightened(0.15), T_MD)

func _draw_binder_overlay() -> void:
	hover_disc = null
	draw_rect(Rect2(Vector2(-800, -800), Vector2(UI_W, UI_H) + Vector2(1600, 1600)), Color(0.04, 0.05, 0.07, 0.82))
	_register(Rect2(Vector2(-800, -800), Vector2(UI_W, UI_H) + Vector2(1600, 1600)), func(): pass)
	var b := Rect2((UI_W - 1540.0) * 0.5, 130.0, 1540.0, 960.0)
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
			var r := Rect2(gx + (k % 3) * (cell + gap), page.position.y + 24.0 + (k / 3) * (cell + 44.0), cell, cell)
			var pocket := Rect2(r.position - Vector2(6.0, 6.0), Vector2(r.size.x + 12.0, r.size.y + 14.0))
			_panel(pocket, Color(1, 1, 1, 0.03), 8, Color(1, 1, 1, 0.13), 2)
			_pocket_lip(pocket)
			if n < order.size():
				var i: int = order[n]
				var d := collection[i]
				_draw_jewel(r, d)
				var st := _binder_status(i)
				if not st.is_empty():
					var tw := _text_w(String(st[0]), 13, true) + 18.0
					var tr := Rect2(r.end.x - tw + 4.0, r.position.y - 2.0, tw, 24.0)
					_panel(tr, st[1], 12, Color(1, 1, 1, 0.5), 1)
					_text_center(tr, String(st[0]), 13, Color.WHITE, true)
				if binder_pick >= 0:
					if d.edition != "":
						draw_rect(_jewel_box(r), Color(0, 0, 0, 0.6))
					else:
						if pocket.has_point(mouse):
							_panel(_jewel_box(r).grow(4.0), Color(0, 0, 0, 0), 8, c_gold, 5)
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
	_hw_button(Rect2(b.end.x - 180.0, 40.0, 180.0, 64.0), "Close", _toggle_binder, true, Color("3d4148"), T_MD)

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
		_text_i(Vector2(r.position.x + 10.0, r.position.y + 60.0), "No work orders today.", T_MD, Color(1, 1, 1, 0.45))
		return
	var th := 300.0
	for i in services.size():
		var sv: Dictionary = services[i]
		var t := Rect2(r.position.x, r.position.y + i * (th + 40.0), r.size.x, th)
		_shadow(t, 4, 6.0)
		_panel(t, Color("f6e7dc"), 3)
		var x := t.position.x + 14.0
		while x < t.end.x - 8.0:
			draw_circle(Vector2(x, t.position.y + 10.0), 3.0, Color("3e2a1c"))
			x += 18.0
		draw_line(Vector2(t.position.x + 10.0, t.position.y + 20.0), Vector2(t.end.x - 10.0, t.position.y + 20.0), Color(0, 0, 0, 0.12), 1.0)
		_text(Vector2(t.position.x + 20.0, t.position.y + 52.0), "WORK ORDER  №%03d" % (gig_n * 10 + i + 1), T_XS, Color("b03a2e"), true)
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
		_heavy(Vector2(t.position.x + 20.0, t.position.y + 110.0), title, T_LG, Color("22252a"))
		_wrap(Vector2(t.position.x + 20.0, t.position.y + 130.0), desc, t.size.x - 40.0, 20, Color("4c5058"))
		var pr := Rect2(t.end.x - 130.0, t.end.y - 80.0, 108.0, 58.0)
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

func _fmt_time(sec: int) -> String:
	return "%d:%02d" % [maxi(0, sec) / 60, maxi(0, sec) % 60]

func _start_show(v: Dictionary) -> void:
	venue = v
	gig_done = false
	set_live = false
	play_ctx = {}
	play_order = []
	sel_hand = -1
	wallet.clear()
	for i in D.HAND:
		wallet.append(-1)
	tray.clear()
	readout.clear()
	for i in D.SETLIST:
		tray.append(-1)
		readout.append({})
	draw_pile.clear()
	for i in collection.size():
		draw_pile.append(i)
	_shuffle(draw_pile)
	discard.clear()
	doomed.clear()
	_restore_gear()
	var chal: Dictionary = v.get("challenge", {})
	if String(chal.get("kind", "")) == "gear":
		for g: Dictionary in rack:
			if not g.is_empty() and String(g["id"]) == String(chal.get("gear_id", "")):
				g["broken"] = true
	for g: Dictionary in rack:
		if not g.is_empty():
			g["used"] = 0
	gate_pool = (v.get("dislikes", []) as Array).duplicate()
	_shuffle(gate_pool)
	gear_sel = -1
	burn_mode = false
	burn_marks.clear()
	peek_open = false
	held = -1
	score_tot = 0
	score_live = 0
	finale = 0
	finale_flow = 1.0
	song_pts = 0
	resolving = false
	sel_slot = -1
	set_res = {}
	flow_live = 1.0
	link_log.clear()
	digs = D.BOSS_DIGS if String(chal.get("kind", "")) == "discards" else D.DIGS
	tuner_bonus = 0
	_sync_tuner()
	dig_mode = false
	dig_marks.clear()
	booed = false
	show_cash = cash
	_reset_mixes()
	played.clear()
	call = {}
	floats.clear()
	binder_open = false
	binder_pick = -1
	binder_page = 0
	_refill()
	phase = "show"
	_new_call()
	_say("You're on. Fill all %d slots, then press PLAY." % D.SETLIST)

func _gig_target() -> int:
	var t := float(D.GIG_TARGETS[clampi(gig_n - 1, 0, D.GIG_TARGETS.size() - 1)])
	if venue.get("headliner", false):
		t *= D.HEADLINER_MULT
	if _boss_kind() == "target":
		t *= D.BOSS_TARGET
	if score_mode == "end":
		t *= D.END_TARGET_SCALE
	return int(round(t))

func _open_slot() -> int:
	return played.size() if resolving and played.size() < tray.size() else -1

func _tag_match(d: Disc, tag: Array) -> bool:
	return _tag_count(d, tag) > 0

func _bay_of(id: String) -> int:
	for k in rack.size():
		if not rack[k].is_empty() and rack[k]["id"] == id and not bool(rack[k].get("broken", false)):
			return k
	return -1

func _has_tag(d: Disc, is_era: bool, v: int) -> int:
	if is_era:
		return 1 if d.era == v else 0
	return 1 if _in_genre(d, v) else 0

func _tag_count(d: Disc, tag: Array) -> int:
	if d.genre < 0:
		return 0
	if tag[0] == "genre":
		return _has_tag(d, false, D.GENRES.find(String(tag[1])))
	return _has_tag(d, true, D.ERAS.find(String(tag[1])))

func _cell_keeps(is_genre: bool, k: int) -> bool:
	return false

func _boss_kind() -> String:
	return String((venue.get("challenge", {}) as Dictionary).get("kind", ""))

func _slot_locked(d: Disc, slot: int) -> bool:
	if _boss_kind() != "slot" or slot < 0:
		return false
	var bc: Dictionary = venue["challenge"]
	return slot == int(bc["slot"]) and not (d.genre == int(bc["genre"]) or d.era == int(bc["era"]))

func _hated_tag(d: Disc) -> String:
	if venue.is_empty() or d.genre < 0:
		return ""
	var ignored := _gate_ignored()
	for tag: Array in venue["dislikes"]:
		if tag in ignored:
			continue
		if _tag_count(d, tag) > 0:
			return String(tag[1])
	return ""

func _s_run(st: Dictionary) -> int:
	return int(round(float(int(st["base"]) + int(st["add"])) * float(st["mult"])))

func _s_add(out: Array, st: Dictionary, src: String, text: String, n: int, ci: int = -1) -> void:
	st["add"] = int(st["add"]) + n
	out.append({"src": src, "text": text, "n": n, "ci": ci, "run": _s_run(st)})

func _s_mult(out: Array, st: Dictionary, src: String, text: String, m: float, ci: int = -1) -> void:
	st["mult"] = float(st["mult"]) * m
	out.append({"src": src, "text": text, "n": 1 if m > 1.0 else -1, "ci": ci, "run": _s_run(st)})

func _cond_count(rule: Dictionary, s: int, ids: Array, prev: Disc, above: Disc, nxt: Disc) -> int:
	var half := D.SETLIST / 2
	var p := String(rule.get("cparam", ""))
	match String(rule.get("condition", "always")):
		"always":
			return 1
		"first":
			return 1 if s == 0 else 0
		"last":
			return 1 if s == D.SETLIST - 1 else 0
		"set1":
			return 1 if s < half else 0
		"set2":
			return 1 if s >= half else 0
		"odd":
			return 1 if s % 2 == 0 else 0
		"even":
			return 1 if s % 2 == 1 else 0
		"slot1", "slot2", "slot3", "slot4", "slot5", "slot6":
			return 1 if s == int(String(rule.get("condition", "")).substr(4)) - 1 else 0
		"prev_is":
			return 1 if prev != null and _nm_nb(prev, p) else 0
		"above_is":
			return 1 if above != null and _nm_nb(above, p) else 0
		"next_is":
			return 1 if nxt != null and _nm_nb(nxt, p) else 0
		"per_before":
			var c := 0
			for j in s:
				var dj := _ids_disc(ids, j)
				if dj != null and _name_matches(dj, p):
					c += 1
			return c
		"per_hand":
			var h := 0
			for w in wallet:
				if w >= 0 and _name_matches(collection[w], p):
					h += 1
			return h
	return 0

func _fire_rule(rule: Dictionary, src: Disc, s: int, ids: Array, prev: Disc, above: Disc, nxt: Disc, out: Array, st: Dictionary, fx: Dictionary, depth: int) -> bool:
	var eff := String(rule.get("effect", "none"))
	if eff == "none":
		return false
	if eff == "copy":
		if depth == 0 and prev != null and not String(prev.rule.get("effect", "none")) in ["none", "copy"]:
			var at := out.size()
			var ok := _fire_rule(prev.rule, prev, s, ids, prev, above, nxt, out, st, fx, 1)
			if ok:
				out.insert(at, {"src": "fx", "text": "Copies %s" % prev.title, "n": 0, "ci": -1, "run": _s_run(st)})
			return ok
		return false
	if not eff in ["points", "mult", "flow_add", "flow_mult", "cash"]:
		return false
	var count := _cond_count(rule, s, ids, prev, above, nxt)
	if count <= 0:
		return false
	if eff == "cash":
		var per := count if String(rule.get("condition", "")) in ["per_before", "per_hand"] else 1
		var gain := int(round(float(rule.get("value", 0.0)) * per))
		fx["cash"] = int(fx["cash"]) + gain
		out.append({"src": "fx", "text": _rule_line(rule, count, float(gain)), "n": 0, "ci": -1, "run": _s_run(st)})
		return true
	var eb := _bay_of("echo")
	var echo := D.ECHO_FLOW if eb >= 0 else 1.0
	var v := float(rule.get("value", 0.0))
	var tgt := String(rule.get("target", "self"))
	var cmult := count if String(rule.get("condition", "")) in ["per_before", "per_hand"] else 1
	if eff == "flow_add":
		var n := v * cmult * echo
		fx["fadd"] = float(fx["fadd"]) + n
		out.append({"src": "fx", "text": _rule_line(rule, count, n), "n": 0, "ci": eb, "run": _s_run(st)})
		return true
	if eff == "flow_mult":
		var m := 1.0 + (v - 1.0) * echo
		m = pow(m, cmult)
		fx["fmul"] = float(fx["fmul"]) * m
		out.append({"src": "fx", "text": _rule_line(rule, count, m), "n": 0, "ci": eb, "run": _s_run(st)})
		return true
	var amt := v * cmult if eff == "points" else pow(v, cmult)
	var line := _rule_line(rule, count, amt)
	if tgt == "self":
		if eff == "points":
			_s_add(out, st, "fx", line, int(round(amt)))
		else:
			_s_mult(out, st, "fx", line, amt)
		return true
	out.append({"src": "fx", "text": line, "n": 0, "ci": -1, "run": _s_run(st)})
	if tgt == "next":
		if s + 1 < D.SETLIST:
			(fx["nextq"] as Array).append({"slot": s + 1, "kind": eff, "value": amt, "title": src.title})
	else:
		var flt := "" if tgt == "later" else String(rule.get("tparam", ""))
		(fx["later"] as Array).append({"from": s, "kind": eff, "value": amt, "filter": flt, "title": src.title})
	return true

func _apply_buff(out: Array, st: Dictionary, q: Dictionary) -> void:
	if String(q["kind"]) == "points":
		_s_add(out, st, "carry", "From %s +%s" % [q["title"], _ff(float(q["value"]))], int(round(float(q["value"]))))
	else:
		_s_mult(out, st, "carry", "From %s x%s" % [q["title"], _ff(float(q["value"]))], float(q["value"]))

func _gear_flow(out: Array, st: Dictionary, fx: Dictionary, text: String, amt: float, ci: int) -> void:
	fx["fadd"] = float(fx["fadd"]) + amt
	out.append({"src": "fx", "text": text, "n": 0, "ci": ci, "run": _s_run(st)})

func _gear_cash(out: Array, st: Dictionary, text: String, amt: int, ci: int) -> int:
	out.append({"src": "fx", "text": text, "n": 0, "ci": ci, "run": _s_run(st)})
	return amt

func _rule_applies(r: Dictionary, d: Disc) -> bool:
	match String(r.get("applies", "any")):
		"genre":
			return d.genre >= 0 and _in_genre(d, D.GENRES.find(String(r.get("aparam", ""))))
		"decade":
			return d.era >= 0 and d.era == D.ERAS.find(String(r.get("aparam", "")))
	return true

func _rule_requires(r: Dictionary, s: int, ids: Array, prev: Disc, d: Disc) -> bool:
	match String(r.get("requires", "none")):
		"prev_same_era":
			return s > 0 and prev != null and d.era >= 0 and prev.era == d.era
		"prev2_same_genre":
			if s < 2:
				return false
			var p1 := _ids_disc(ids, s - 1)
			var p2 := _ids_disc(ids, s - 2)
			return p1 != null and p2 != null and p1.genre >= 0 and p1.genre == p2.genre
		"last_matches_first":
			if s == 0:
				return false
			var first := _ids_disc(ids, 0)
			if first == null:
				return false
			return (d.genre >= 0 and _in_genre(first, d.genre)) or (d.era >= 0 and first.era == d.era)
		"adjacent":
			var gi := D.GENRES.find(String(r.get("rparam", "")))
			for o in [s - 1, s + 1]:
				var od := _ids_disc(ids, o)
				if od != null and _in_genre(od, gi):
					return true
			return false
		"streak":
			if d.genre < 0:
				return false
			var run := 1
			var k := s - 1
			while k >= 0 and _ids_disc(ids, k) != null and _ids_disc(ids, k).genre == d.genre:
				run += 1
				k -= 1
			return run % maxi(1, int(r.get("rn", 2))) == 0
		"match_back":
			var n := maxi(1, int(r.get("rn", 2)))
			var dn := _ids_disc(ids, s - n)
			return s >= n and dn != null and d.genre >= 0 and _in_genre(dn, d.genre)
	return true

func _rule_count(r: Dictionary, e: Dictionary, d: Disc, s: int, ids: Array) -> int:
	var c := 1
	match String(r.get("per", "none")):
		"earlier_same_genre":
			c = 0
			if d.genre >= 0:
				for j in s:
					var dj2 := _ids_disc(ids, j)
					if dj2 != null and _in_genre(dj2, d.genre):
						c += 1
		"others_in_set":
			var gi := D.GENRES.find(String(r.get("aparam", ""))) if String(r.get("applies", "any")) == "genre" else d.genre
			c = 0
			if gi >= 0:
				for j in ids.size():
					var dj3 := _ids_disc(ids, j)
					if dj3 != null and _in_genre(dj3, gi):
						c += 1
				if _in_genre(d, gi):
					c -= 1
				c = maxi(0, c)
		"units_left":
			c = int(e["left"])
		"unused_discards":
			c = maxi(0, digs)
	var cap := int(r.get("cap", 0))
	if cap > 0:
		c = mini(c, cap)
	return c

func _rule_song(r: Dictionary, e: Dictionary, d: Disc, s: int, ids: Array, prev: Disc, out: Array, st: Dictionary, fx: Dictionary) -> int:
	var when := String(r.get("when", "each"))
	if when == "gig_start" or when == "gig_end":
		return 0
	if (when == "first" and s != 0) or (when == "last" and s != ids.size() - 1):
		return 0
	if not _rule_applies(r, d) or not _rule_requires(r, s, ids, prev, d):
		return 0
	var count := _rule_count(r, e, d, s, ids)
	if count <= 0:
		return 0
	var m: int = e["m"]
	var ci: int = e["ci"]
	var amt := float(r.get("amount", 0.0))
	var label := String(r.get("label", ""))
	match String(r.get("effect", "points")):
		"points":
			var v := int(round(amt * count * m))
			_s_add(out, st, "rack", "%s +%d" % [label, v], v, ci)
		"mult":
			var lm := 1.0 + (amt - 1.0) * m
			_s_mult(out, st, "rack", "%s x%s" % [label, _ff(lm)], lm, ci)
		"flow":
			var f := amt * count * m
			_gear_flow(out, st, fx, "%s +%s flow" % [label, _ff(f)], f, ci)
		"cash":
			var c := int(round(amt * count * m))
			return _gear_cash(out, st, "%s +$%d" % [label, c], c, ci)
	return 0

func _rule_gig(when: String, effect: String) -> int:
	var gm := _gear_map()
	var total := 0.0
	for id: String in gm:
		var r: Dictionary = gear_defs[id].get("rule", {})
		if String(r.get("when", "")) != when or String(r.get("effect", "")) != effect:
			continue
		var count := 1
		if String(r.get("per", "none")) == "unused_discards" and when == "gig_end":
			count = maxi(0, digs)
		total += float(r.get("amount", 0.0)) * count * int(gm[id]["m"])
	return int(round(total))

func _gear_song(gm: Dictionary, d: Disc, s: int, ids: Array, prev: Disc, hand_g: int, out: Array, st: Dictionary, fx: Dictionary) -> int:
	var cash_gain := 0
	var gi := d.genre
	var last := ids.size() - 1
	for id: String in gm:
		var e: Dictionary = gm[id]
		var g: Dictionary = e["g"]
		var m: int = e["m"]
		var ci: int = e["ci"]
		var rule: Dictionary = gear_defs[id].get("rule", {})
		if not rule.is_empty():
			cash_gain += _rule_song(rule, e, d, s, ids, prev, out, st, fx)
			continue
		match id:
			"genre_eq":
				if gi >= 0:
					var lv := int((g["levels"] as Array)[gi]) * int(_gp("genre_eq", "step")) * m
					if lv != 0:
						_s_add(out, st, "rack", "Genre EQ %+d" % lv, lv, ci)
			"decade_eq":
				if d.era >= 0:
					var lv2 := int((g["levels"] as Array)[d.era]) * int(_gp("decade_eq", "step")) * m
					if lv2 != 0:
						_s_add(out, st, "rack", "Decade EQ %+d" % lv2, lv2, ci)
			"tube":
				var tn := mini(hand_g, int(_gp("tube", "max"))) * m
				if tn > 0:
					_s_add(out, st, "rack", "Tube +%d" % tn, tn, ci)
			"tshirt":
				if s == 2:
					_s_mult(out, st, "rack", "Slot 3: no points", 0.0, ci)
					cash_gain += _gear_cash(out, st, "Merch +$%d" % (d.sound * m), d.sound * m, ci)
			"sampler":
				if s > 0 and prev != null and gi >= 0 and prev.genre >= 0:
					for pi in m:
						var pr: Array = (g["pairs"] as Array)[pi]
						if d.genre == int(pr[0]) and prev.genre == int(pr[1]):
							cash_gain += _gear_cash(out, st, "Sampler +$%d" % int(_gp("sampler", "cash")), int(_gp("sampler", "cash")), ci)
	return cash_gain

func _ids_disc(ids: Array, j: int) -> Disc:
	if j < 0 or j >= ids.size() or int(ids[j]) < 0:
		return null
	return collection[int(ids[j])]

func _score_ctx() -> Dictionary:
	var gm := _gear_map()
	return {"fx": {"fadd": 0.0, "fmul": 1.0, "cash": 0, "nextq": [], "later": []}, "req_done": false, "call_tag": (call["tag"] if not call.is_empty() else []), "gm": gm, "hand_g": _hand_genre_count() if gm.has("tube") else 0, "req": _request_pts(), "fl": 1.0 + _stored_flow(gm), "total": 0}

func _score_slot(s: int, ids: Array, ctx: Dictionary) -> Dictionary:
	var half := D.SETLIST / 2
	var gm: Dictionary = ctx["gm"]
	var fx: Dictionary = ctx["fx"]
	var fl: float = ctx["fl"]
	var hand_g: int = ctx["hand_g"]
	var req: int = ctx["req"]
	var call_tag: Array = ctx["call_tag"]
	var d: Disc = collection[int(ids[s])]
	var prev: Disc = _ids_disc(ids, s - 1)
	var above: Disc = _ids_disc(ids, D.SETLIST - 1 - s) if (s >= half or gm.has("audio")) else null
	var nxt: Disc = _ids_disc(ids, s + 1)
	var st := {"base": d.sound, "add": 0, "mult": 1.0}
	var out: Array = [{"src": "base", "text": "Points %d" % d.sound, "n": d.sound, "ci": -1, "run": d.sound}]
	var fired := false
	var cash_gain := 0
	var fl_start := fl
	fx["fadd"] = 0.0
	fx["fmul"] = 1.0
	fx["cash"] = 0
	for q: Dictionary in fx["nextq"]:
		if int(q["slot"]) == s:
			_apply_buff(out, st, q)
			fired = true
	for q: Dictionary in fx["later"]:
		if int(q["from"]) < s and (String(q["filter"]) == "" or _name_matches(d, String(q["filter"]))):
			_apply_buff(out, st, q)
			fired = true
	if not d.cdr:
		if _fire_rule(d.rule, d, s, ids, prev, above, nxt, out, st, fx, 0):
			fired = true
		cash_gain += int(fx["cash"])
	match d.edition:
		"holo", "signed", "limited":
			var en := int(D.EDITIONS[d.edition]["n"])
			_s_add(out, st, "disc", "%s +%d" % [D.EDITIONS[d.edition]["name"], en], en)
		"mint":
			cash_gain += int(D.EDITIONS["mint"]["n"])
	cash_gain += _gear_song(gm, d, s, ids, prev, hand_g, out, st, fx)
	for tag: Array in venue["likes"]:
		var lc := _tag_count(d, tag)
		if lc > 0:
			_s_add(out, st, "taste", "They love %s +%d" % [tag[1], D.LIKE * lc], D.LIKE * lc)
	var ht := _hated_tag(d)
	if ht != "":
		if _boss_kind() == "hates":
			_s_mult(out, st, "taste", "They hate %s: no points" % ht, 0.0)
		else:
			_s_mult(out, st, "taste", "They hate %s x%s" % [ht, str(D.HATE_MULT)], D.HATE_MULT)
	if not bool(ctx["req_done"]) and not call_tag.is_empty() and _tag_match(d, call_tag):
		ctx["req_done"] = true
		_s_add(out, st, "call", "Request! +%d" % req, req)
	if absf(fl - 1.0) > 0.001 and score_mode == "song":
		_s_mult(out, st, "fx", "Flow x%s" % _ff(fl), fl)
	var bc: Dictionary = venue.get("challenge", {})
	var bdc := 0
	if _boss_kind() == "genre":
		bdc = _has_tag(d, false, int(bc.get("genre", -2)))
	elif _boss_kind() == "era":
		bdc = _has_tag(d, true, int(bc.get("era", -2)))
	if bdc > 0:
		_s_mult(out, st, "boss", "Boss debuff x0.5", D.BOSS_DEBUFF_MULT)
	if _slot_locked(d, s):
		_s_mult(out, st, "boss", "Slot locked: no points", 0.0)
	var sc := _s_run(st)
	var fl_next := (fl + float(fx["fadd"])) * float(fx["fmul"])
	if absf(fl_next - fl) > 0.001:
		out.append({"src": "flowup", "text": "Flow x%s" % _ff(fl_next), "n": 1, "ci": -1, "run": sc, "flow": fl_next})
		fired = true
	ctx["fl"] = fl_next
	ctx["total"] = int(ctx["total"]) + sc
	return {"score": sc, "steps": out, "fired": fired, "cash": cash_gain, "flow_start": fl_start, "flow_end": fl_next}

func _score_set(ids: Array) -> Dictionary:
	var ctx := _score_ctx()
	var slots: Array = []
	for s in ids.size():
		slots.append(_score_slot(s, ids, ctx))
	var total := int(ctx["total"])
	var fl := float(ctx["fl"])
	var end_extra := 0
	if score_mode == "end":
		end_extra = int(round(total * fl)) - total
	return {"slots": slots, "total": total, "finale": end_extra, "finale_flow": fl}

func _one_mode() -> bool:
	return place_mode == "one"

func _preview_play(di: int, s: int) -> Dictionary:
	var ids: Array = tray.duplicate()
	ids[s] = di
	var ctx: Dictionary = (play_ctx.duplicate(true) if set_live else _score_ctx())
	var res := _score_slot(s, ids, ctx)
	return {"score": int(res["score"]), "flow": float(res["flow_end"]), "flow0": float(res["flow_start"]), "fired": bool(res["fired"])}

func _play_cd(p: int, s: int, from_pos: Vector2 = Vector2(INF, INF)) -> void:
	if not _one_mode() or resolving or playing or phase != "show" or s < 0 or tray[s] >= 0 or p < 0 or wallet[p] < 0:
		return
	var i := wallet[p]
	var d := collection[i]
	if d.cdr and d.genre < 0:
		_resolve_mix(d)
	var first := not set_live
	if first:
		set_live = true
		play_ctx = _score_ctx()
		set_res = {"slots": [], "total": 0, "finale": 0, "finale_flow": 1.0}
		(set_res["slots"] as Array).resize(D.SETLIST)
		played.clear()
		link_log.clear()
		play_order.clear()
		for k in D.SETLIST:
			play_order.append(0)
	wallet[p] = -1
	tray[s] = i
	sel_hand = -1
	sel_slot = -1
	slot_flash[s] = 1.0
	if from_pos.x != INF:
		settles.append({"disc": i, "kind": "tray", "idx": s, "from": from_pos, "t": 0.0, "w0": 232.0 * 1.1, "w1": 232.0})
	(set_res["slots"] as Array)[s] = _score_slot(s, tray, play_ctx)
	play_order[s] = _placed()
	resolving = true
	if first:
		count_t = D.COUNT_STEP * 3.0
		count_n = 4
		count_slot = s
	else:
		_start_slot(s)

func _play() -> void:
	if not _can_play():
		return
	for t in tray:
		var m: Disc = collection[t]
		if m.cdr and m.genre < 0:
			_resolve_mix(m)
	set_res = _score_set(tray)
	resolving = true
	sel_slot = -1
	played.clear()
	link_log.clear()
	count_t = D.COUNT_STEP * 3.0
	count_n = 4
	count_slot = 0

func _start_slot(s: int) -> void:
	var d := collection[tray[s]]
	result = (set_res["slots"] as Array)[s]
	flow_live = float(result["flow_start"])
	steps = (result["steps"] as Array).duplicate()
	var cl := "MIX" if d.cdr else _cond_label(d)
	var ctxt := cl if bool(result["fired"]) else ("%s: no effect" % cl)
	steps.push_front({"src": "cond", "text": ctxt, "n": 0, "ci": -1})
	if d.cdr:
		steps.push_front({"src": "mix", "text": "Mix: %s, %s" % [D.GENRES[d.genre], D.ERAS[d.era]], "n": 0, "ci": -1})
	var tot := int(result["score"])
	song_pts = int(round(float(tot) / maxf(0.001, float(result["flow_start"]))))
	steps.append({"src": "score", "text": "+%s" % _fmt_int(tot), "n": 1, "ci": -1, "run": tot})
	song_slot = s
	now_slot = s
	slot_flash[s] = 1.0
	readout[s] = {"text": "0", "pts": 0}
	step_i = 0
	step_t = D.SONG_START * _anim()
	score_live = score_tot
	eq_prev_run = 0
	rec_pop = 1.0
	playing = true
	_sfx("click")
	_music_start(d)

func _play_step(st: Dictionary) -> void:
	var n := int(st["n"])
	var ro: Dictionary = readout[song_slot]
	var src := String(st["src"])
	var col := Color(D.SOUND_COLOR).lightened(0.25) if n > 0 else (c_bad.lightened(0.25) if n < 0 else Color("c9ced6"))
	match src:
		"cond":
			col = Color("c9ced6") if String(st["text"]).ends_with("no effect") else c_gold
		"fx", "carry", "flowup":
			col = Color(D.FLOW_COLOR).lightened(0.3)
		"score":
			ro["net"] = int(st["run"])
			score_live = score_tot + int(st["run"])
			col = c_gold
		"call":
			col = c_gold
	if src == "flowup":
		flow_live = float(st["flow"])
		flow_pulse = 1.0
		_kick_eq(0.4, true)
		_tick()
	if src == "score":
		pts_pulse = 1.0
		_tick()
	if st.has("run"):
		var dl := absi(int(st["run"]) - eq_prev_run)
		eq_prev_run = int(st["run"])
		_kick_eq(clampf(float(dl) / maxf(8.0, float(_gig_target()) * 0.12), 0.2, 1.0), src in ["fx", "carry", "flowup"])
		ro["text"] = _fmt_int(int(st["run"]))
		score_live = score_tot + int(st["run"])
	if int(st["ci"]) >= 0:
		comp_flash[int(st["ci"])] = 1.0
	for f: Dictionary in floats:
		if int(f["slot"]) == song_slot:
			f["pos"] = Vector2(f["pos"]) + Vector2(0.0, -46.0)
	floats.append({"slot": song_slot, "pos": _well_center(song_slot) + Vector2(0.0, 30.0), "text": String(st["text"]), "col": col, "life": 1.3})

func _finish_song() -> void:
	playing = false
	_music_stop()
	var s := song_slot
	var i := tray[s]
	var d := collection[i]
	var got := int(result["score"])
	score_tot += got
	score_live = score_tot
	played.append(i)
	for ru: Dictionary in rack:
		if ru.is_empty() or bool(ru.get("broken", false)):
			continue
		if String(ru["id"]) == "vintage" and d.era == D.ERAS.find(_gs("vintage", "decade")):
			ru["count"] = int(ru["count"]) + 1
		elif String(ru["id"]) == "feedback" and _in_genre(d, D.GENRES.find(_gs("feedback", "genre"))):
			ru["count"] = int(ru["count"]) + 1
	link_log.append({"met": bool(result["fired"]), "above": String(d.rule.get("condition", "")) == "above_is"})
	if _boss_kind() == "destroy" and rng.randf() < D.BOSS_DESTROY:
		doomed.append(d)
		floats.append({"slot": s, "pos": _well_center(s) + Vector2(0.0, 30.0), "text": "Scratched beyond repair!", "col": c_bad.lightened(0.3), "life": 2.0})
	cash += int(result["cash"])
	readout[s] = {"text": "+%s" % _fmt_int(got), "net": got}
	now_slot = -1
	song_slot = -1
	if played.size() < D.SETLIST:
		if _one_mode():
			resolving = false
		else:
			_start_slot(played.size())
	else:
		resolving = false
		gig_done = true
		if _one_mode():
			var tot0 := int(play_ctx["total"])
			var fl0 := float(play_ctx["fl"])
			set_res["finale"] = (int(round(tot0 * fl0)) - tot0) if score_mode == "end" else 0
			set_res["finale_flow"] = fl0
		finale = int(set_res.get("finale", 0))
		finale_flow = float(set_res.get("finale_flow", 1.0))
		if finale > 0:
			fin_from = score_tot
			fin_to = score_tot + finale
			fin_boomed = false
			fin_accum = 0.0
			fin_tick_t = 0.0
			fin_t = 0.0
			resolving = true
		else:
			_end_show()

func _new_call() -> void:
	var left: Array = []
	for i in wallet + tray.slice(played.size()) + draw_pile:
		if i >= 0:
			left.append(collection[i])
	var tag: Array
	if not left.is_empty() and rng.randf() < 0.75:
		var d: Disc = left[rng.randi_range(0, left.size() - 1)]
		if d.cdr:
			d = left.filter(func(o): return not o.cdr).pick_random() if left.any(func(o): return not o.cdr) else null
		if d == null:
			d = _make_disc(albums.pick_random())
		tag = ["genre", D.GENRES[d.genre]] if rng.randf() < 0.6 else ["era", D.ERAS[d.era]]
	else:
		tag = ["genre", D.GENRES[rng.randi_range(0, D.GENRES.size() - 1)]] if rng.randf() < 0.6 else ["era", D.ERAS[rng.randi_range(0, D.ERAS.size() - 1)]]
	call = {"kind": "request", "tag": tag}
	message = "Someone shouts: \"%s\"" % _call_text(call)
	message_t = 3.5

func _call_text(cl: Dictionary) -> String:
	var v := String(cl["tag"][1])
	return "Play some %s!" % v

func _restore_gear() -> void:
	for g: Dictionary in rack:
		if not g.is_empty():
			g["broken"] = false

func _sync_tuner() -> void:
	var nb := _rule_gig("gig_start", "discards")
	digs += nb - tuner_bonus
	tuner_bonus = nb

func _burn_doomed() -> void:
	for d: Disc in doomed:
		collection.erase(d)
	doomed.clear()

func _end_show() -> void:
	_restore_gear()
	_return_held()
	playing = false
	_music_stop()
	dig_mode = false
	dig_marks.clear()
	booed = score_tot < _gig_target()
	var ratio := float(score_tot) / float(_gig_target())
	var pay := D.PAY_BOOED if booed else (D.PAY_ENCORE if ratio >= D.TIER_GREAT else (D.PAY_APPLAUSE if ratio >= D.TIER_GOOD else D.PAY_BASE))
	var gm := _gear_map()
	var gear_pay := 0
	gear_pay += _rule_gig("gig_end", "cash")
	if gm.has("piggy"):
		var pg: Dictionary = gm["piggy"]["g"]
		pg["pot"] = int(pg["pot"]) + int(_gp("piggy", "cash"))
		if venue.has("challenge") and not booed:
			gear_pay += int(pg["pot"]) * int(gm["piggy"]["m"])
			pg["pot"] = 0
	reward = {"pay": pay, "mint": cash - show_cash, "gear": gear_pay}
	cash += pay + gear_pay
	phase = "end"

func _draw_show_end() -> void:
	var r := _modal_panel(900.0, 600.0)
	var final := _is_final()
	var ratio := float(score_tot) / float(_gig_target())
	var title := "Booed off stage" if booed else ("Encore!" if ratio >= D.TIER_GREAT else ("Big applause" if ratio >= D.TIER_GOOD else "Target cleared"))
	if final and not booed:
		title = "Tour complete!"
	_heavy_center(Rect2(r.position.x, r.position.y + 40.0, r.size.x, 90.0), title, T_HERO, c_good if not booed else c_bad)
	_text_center(Rect2(r.position.x, r.position.y + 140.0, r.size.x, 40.0), "%s: %s of %s points" % [venue["name"], _fmt_int(score_tot), _fmt_int(_gig_target())], T_LG, c_ink, true)
	var sub := "The tour ends here." if booed else ("You beat the final boss. %d shows on the road." % gig_n if final else ("You beat the boss." if bool(venue.get("headliner", false)) else "%d of %d songs played · final score %s" % [played.size(), D.SETLIST, _fmt_int(score_tot)]))
	if finale > 0 and not booed:
		sub = "Flow x%s added %s · final score %s" % [_ff(finale_flow), _fmt_int(finale), _fmt_int(score_tot)]
	_text_center(Rect2(r.position.x, r.position.y + 186.0, r.size.x, 40.0), sub, T_MD, c_body)
	var x := r.position.x + 220.0
	var w := r.size.x - 440.0
	var y := r.position.y + 270.0
	_text(Vector2(x, y), "Show pay", T_MD, c_muted, true)
	_heavy_right(x + w, y, "$%d" % int(reward["pay"]), T_LG, c_ink)
	if int(reward["mint"]) > 0:
		_text(Vector2(x + w + 30.0, y), "+$%d mint" % int(reward["mint"]), T_SM, c_good, true)
	if int(reward.get("gear", 0)) > 0:
		_text(Vector2(x + w + 30.0, y + 34.0), "+$%d gear" % int(reward["gear"]), T_SM, c_good, true)
	draw_line(Vector2(x, y + 24.0), Vector2(x + w, y + 24.0), Color(c_ink, 0.2), 2.0)
	_text(Vector2(x, y + 70.0), "Cash", T_MD, c_muted, true)
	_heavy_right(x + w, y + 72.0, "$%d" % cash, T_XL, c_good)
	if not doomed.is_empty():
		var names: Array = []
		for dd: Disc in doomed:
			names.append(dd.title)
		_text_center(Rect2(r.position.x, r.position.y + 410.0, r.size.x, 30.0), "Destroyed: " + ", ".join(names), T_SM, c_bad, true)
	if booed or final:
		_hw_button(Rect2(r.get_center().x - 200.0, r.end.y - 130.0, 400.0, 86.0), "Main menu", _to_title, true, Color("3f9b5a"), T_LG)
	else:
		_hw_button(Rect2(r.get_center().x - 220.0, r.end.y - 130.0, 440.0, 86.0), "Back on the road", _to_map, true, Color("3f9b5a"), T_LG)

func _to_map() -> void:
	_burn_doomed()
	_reset_mixes()
	binder_open = false
	message_t = 0.0
	_back_on_road()

func _tag_chips(x: float, y: float, label: String, tags: Array, col: Color) -> void:
	_text(Vector2(x, y + 22.0), label, T_XS, col, true)
	var cx := x + 76.0
	for tag: Array in tags:
		var t := String(tag[1]).to_upper()
		var w := _text_w(t, T_XS, true) + 20.0
		var cr := Rect2(cx, y, w, 32.0)
		var bg := Color(D.GENRE_COLORS[D.GENRES.find(String(tag[1]))]) if tag[0] == "genre" else Color("5d626a")
		_panel(cr, bg, 12, col, 3)
		_text_center(cr, t, T_XS, Color.WHITE, true)
		cx += w + 8.0

func _make_tour() -> void:
	tour.clear()
	map_seed = rng.randi()
	var towns: Array = []
	towns.assign(D.TOWNS)
	_shuffle(towns)
	tour.append({"id": 0, "col": 0, "y": 0.5, "kind": "start", "town": String(towns.pop_back()), "next": [], "road": 0})
	var prev: Array = [0]
	var col := 1
	for gi in D.TOUR_GIGS + 1:
		var row: Array = []
		if gi == D.TOUR_GIGS:
			var head := _make_headliner()
			tour.append({"id": tour.size(), "col": col, "y": 0.5, "kind": "headliner", "town": String(towns.pop_back()), "venue": head, "hint": _gig_hint(head), "next": [], "road": 0})
			row.append(tour.size() - 1)
		else:
			var n := rng.randi_range(D.GIG_CHOICES[0], D.GIG_CHOICES[1])
			var vs: Array = range(D.VENUES.size())
			_shuffle(vs)
			for k in n:
				tour.append({"id": tour.size(), "col": col, "y": (k + 0.5) / n + rng.randf_range(-0.05, 0.05), "kind": "venue", "venue": D.VENUES[vs[k]], "hint": _gig_hint(D.VENUES[vs[k]]), "town": String(towns.pop_back()), "next": [], "road": 0})
				row.append(tour.size() - 1)
		_link_cols(prev, row)
		prev = row
		col += 1
		if gi == D.TOUR_GIGS:
			break
		var shop_col := rng.randi_range(0, D.REWARDS_BETWEEN - 1)
		for rc in D.REWARDS_BETWEEN:
			var n := rng.randi_range(D.REWARD_ROWS[0], D.REWARD_ROWS[1])
			var shop_k := rng.randi_range(0, n - 1) if rc == shop_col else -1
			var cash_k := -1
			if rc == shop_col and rng.randf() < D.CASH_CHANCE:
				cash_k = (shop_k + rng.randi_range(1, n - 1)) % n
			var rrow: Array = []
			for k in n:
				var kind := "shop" if k == shop_k else ("cash" if k == cash_k else "pickup")
				tour.append({"id": tour.size(), "col": col, "y": (k + 0.5) / n + rng.randf_range(-0.05, 0.05), "kind": kind, "stamp": _random_stamp() if kind == "pickup" else [], "hint": _shop_hint() if kind == "shop" else {}, "town": String(towns.pop_back()), "next": [], "road": 0})
				rrow.append(tour.size() - 1)
			_link_cols(prev, rrow)
			prev = rrow
			col += 1
	tour_cols = col
	for nd: Dictionary in tour:
		nd["road"] = rng.randi_range(1, 99)
	tour_at = 0
	tour_path = [0]

func _make_headliner() -> Dictionary:
	var likes: Array = []
	var g := rng.randi_range(0, D.GENRES.size() - 1)
	likes.append(["genre", D.GENRES[g]])
	likes.append(["era", D.ERAS[rng.randi_range(0, D.ERAS.size() - 1)]])
	var hate_g := (g + rng.randi_range(1, D.GENRES.size() - 1)) % D.GENRES.size()
	return {"name": D.HEADLINER_NAMES[rng.randi_range(0, D.HEADLINER_NAMES.size() - 1)], "likes": likes, "dislikes": [["genre", D.GENRES[hate_g]]], "headliner": true}

func _random_stamp() -> Array:
	var a: Dictionary = albums[rng.randi_range(0, albums.size() - 1)]
	return [int(a["genre"]), -1] if rng.randf() < 0.5 else [-1, int(a["era"])]

func _shop_hint() -> Dictionary:
	var a: Dictionary = albums[rng.randi_range(0, albums.size() - 1)]
	var ids: Array = _gear_pool()
	return {"show": "album" if rng.randf() < 0.5 else "gear", "genre": int(a["genre"]), "era": int(a["era"]), "gear": String(ids[rng.randi_range(0, ids.size() - 1)])}

func _gig_hint(v: Dictionary) -> Dictionary:
	return {"like": rng.randi_range(0, maxi(0, (v["likes"] as Array).size() - 1)), "hate": rng.randi_range(0, maxi(0, (v["dislikes"] as Array).size() - 1))}

func _tour_gigs() -> int:
	return D.LANE_GIGS * D.TOURS if D.USE_FORK else D.TOUR_GIGS + 1

func _forks_total() -> int:
	return D.TOURS

func _is_final() -> bool:
	return bool(venue.get("headliner", false)) and (not D.USE_FORK or gig_n >= _tour_gigs())

func _make_forks() -> void:
	forks_done = 0
	fork_gigs = 0
	fork_roads.clear()
	road_stops.clear()
	fork_towns.clear()

func _fork_town() -> String:
	if fork_towns.is_empty():
		fork_towns.assign(D.TOWNS)
		_shuffle(fork_towns)
	return String(fork_towns.pop_back())

func _roll_combo() -> Array:
	var total := 0
	for c: Dictionary in D.ROAD_COMBOS:
		total += int(c["weight"])
	var r := rng.randi_range(0, total - 1)
	for c: Dictionary in D.ROAD_COMBOS:
		r -= int(c["weight"])
		if r < 0:
			return c["stops"]
	return D.ROAD_COMBOS[0]["stops"]

func _extra_stops() -> Array:
	var out: Array = []
	if not D.PICKUPS_ENABLED:
		return out
	for kind: String in _roll_combo():
		if kind != "shop":
			out.append({"kind": kind, "stamp": _random_stamp(), "hint": {}, "town": ""})
	return out

func _make_lane(venues: Array, boss: String) -> Dictionary:
	var stops: Array = []
	for v: Dictionary in venues:
		stops.append_array(_extra_stops())
		stops.append({"kind": "venue", "venue": v, "stamp": [], "hint": _gig_hint(v), "town": _fork_town()})
		stops.append({"kind": "shop", "stamp": [], "hint": {}, "town": ""})
	stops.append_array(_extra_stops())
	var town := _fork_town()
	stops.append({"kind": "boss", "boss": boss, "stamp": [], "hint": {}, "town": town})
	stops.append({"kind": "shop", "stamp": [], "hint": {}, "town": ""})
	return {"town": town, "boss": boss, "stops": stops}

func _roll_fork() -> void:
	forks_done += 1
	var kinds: Array = D.BOSS_KINDS.duplicate()
	_shuffle(kinds)
	var vs: Array = range(D.VENUES.size())
	_shuffle(vs)
	var per := D.LANE_GIGS - 1
	fork_roads.clear()
	for k in 2:
		var venues: Array = []
		for j in per:
			venues.append((D.VENUES[vs[k * per + j]] as Dictionary).duplicate(true))
		fork_roads.append(_make_lane(venues, String(kinds[k])))

func _advance_road() -> void:
	binder_open = false
	if not road_stops.is_empty():
		var nd: Dictionary = road_stops.pop_front()
		if String(nd["kind"]) == "venue":
			fork_gigs += 1
			gig_n = fork_gigs
		_enter_stop(nd)
	else:
		_roll_fork()
		phase = "fork"

func _pick_road(k: int) -> void:
	road_stops = (fork_roads[k]["stops"] as Array).duplicate()
	fork_roads.clear()
	_advance_road()

func _link_cols(a: Array, b: Array) -> void:
	var fed := {}
	for i in a:
		var order: Array = b.duplicate()
		order.sort_custom(func(p, q): return absf(float(tour[p]["y"]) - float(tour[i]["y"])) < absf(float(tour[q]["y"]) - float(tour[i]["y"])))
		tour[i]["next"].append(order[0])
		fed[order[0]] = true
		if order.size() > 1 and rng.randf() < D.SECOND_ROAD:
			tour[i]["next"].append(order[1])
			fed[order[1]] = true
	for j in b:
		if fed.has(j):
			continue
		var best: int = a[0]
		for i in a:
			if absf(float(tour[i]["y"]) - float(tour[j]["y"])) < absf(float(tour[best]["y"]) - float(tour[j]["y"])):
				best = i
		tour[best]["next"].append(j)

func _reachable() -> Array:
	return tour[tour_at]["next"]

func _travel(id: int) -> void:
	if not id in _reachable():
		return
	tour_at = id
	tour_path.append(id)
	var nd: Dictionary = tour[id]
	if String(nd["kind"]) in ["venue", "headliner"]:
		gig_n = tour_path.filter(func(i): return tour[i]["kind"] in ["venue", "headliner"]).size()
	_enter_stop(nd)

func _enter_stop(nd: Dictionary) -> void:
	_sfx("page_turn")
	match String(nd["kind"]):
		"shop":
			_to_shop(nd.get("hint", {}))
		"pickup", "cash":
			_start_pickup(String(nd["kind"]), nd.get("stamp", []))
		"boss":
			_enter_boss(String(nd["boss"]))
		_:
			_start_show(nd["venue"])

func _back_on_road() -> void:
	if D.USE_FORK:
		_advance_road()
	else:
		phase = "map"

func _start_pickup(kind: String, stamp: Array = []) -> void:
	pickup = {"kind": kind, "hits": 0, "need": D.REVEAL_CLICKS if kind == "pickup" else 1}
	if kind == "cash":
		pickup["cash"] = rng.randi_range(D.CASH_REWARD[0], D.CASH_REWARD[1])
	else:
		pickup["options"] = _pickup_options(stamp)
	pickup_shake = 0.0
	message_t = 0.0
	phase = "pickup"

func _pickup_options(stamp: Array) -> Array:
	var chosen: Array = _random_albums(D.PICKUP_CHOICES, int(stamp[0]) if stamp.size() == 2 else -1, int(stamp[1]) if stamp.size() == 2 else -1)
	var opts: Array = []
	for a: Dictionary in chosen:
		opts.append({"disc": _make_disc(a)})
	var ids := _random_gear_ids(8).filter(func(id): return _can_fit(String(id)))
	if not ids.is_empty() and opts.size() > 1 and (pickups_since_gear >= D.PICKUP_GEAR_PITY or rng.randf() < D.PICKUP_GEAR_CHANCE):
		opts[rng.randi_range(1, opts.size() - 1)] = {"gear": _make_gear(String(ids[0]))}
		pickups_since_gear = 0
	else:
		pickups_since_gear += 1
	_shuffle(opts)
	return opts

func _hit_pickup() -> void:
	if int(pickup["hits"]) >= int(pickup["need"]):
		return
	pickup["hits"] = int(pickup["hits"]) + 1
	pickup_shake = 0.35
	_sfx("click")
	if int(pickup["hits"]) >= int(pickup["need"]):
		_sfx("page_turn")
		if pickup["kind"] == "cash":
			cash += int(pickup["cash"])

func _take_option(k: int) -> void:
	var o: Dictionary = (pickup["options"] as Array)[k]
	if o.has("disc"):
		var d: Disc = o["disc"]
		collection.append(d)
		_say("Added %s to your binder." % d.title)
	else:
		if _place_free(o["gear"]):
			_say("Installed the %s." % gear_defs[o["gear"]["id"]]["name"])
	pickup = {}
	_back_on_road()

func _leave_pickup() -> void:
	pickup = {}
	message_t = 0.0
	_back_on_road()

func _map_rect() -> Rect2:
	return Rect2(70.0, 50.0, 2420.0, 1270.0)

func _map_pos(nd: Dictionary) -> Vector2:
	var P := _map_rect()
	var x := P.position.x + 150.0 + int(nd["col"]) * (P.size.x - 300.0) / maxf(1.0, tour_cols - 1)
	var y := P.position.y + 170.0 + float(nd["y"]) * (P.size.y - 400.0)
	return Vector2(x, y)

func _draw_map() -> void:
	_surface(Rect2(-800.0, -800.0, UI_W + 1600.0, UI_H + 1600.0), 0.0, "wood", Color("6b4a32"), Color("4a3222"), 700.0)
	var P := _map_rect()
	_draw_map_paper(P)
	var reach := _reachable()
	for nd: Dictionary in tour:
		for j in nd["next"]:
			var done := int(nd["id"]) in tour_path and int(j) in tour_path and tour_path.find(int(j)) == tour_path.find(int(nd["id"])) + 1
			_draw_road(_map_pos(nd), _map_pos(tour[j]), done, int(nd["road"]) + int(j))
	var hover_id := -1
	for nd: Dictionary in tour:
		var id := int(nd["id"])
		var c := _map_pos(nd)
		var can := ui_live and id in reach
		var hit := Rect2(c.x - 100.0, c.y - 62.0, 200.0, 128.0)
		var over := ui_live and hit.has_point(mouse)
		if over and String(nd["kind"]) in ["venue", "headliner"]:
			hover_id = id
		_draw_stop(nd, c, id in tour_path, id == tour_at, can, can and over)
		if can:
			_register(hit, _travel.bind(id))
	_draw_map_legend(P)
	var note := Rect2(430.0, 1336.0, 520.0, 84.0)
	_shadow(note, 2, 4.0)
	_panel(note, Color("fff3a8"), 2)
	var shows := tour_path.filter(func(i): return tour[i]["kind"] in ["venue", "headliner"]).size()
	_heavy(Vector2(note.position.x + 20.0, note.position.y + 52.0), "$%d" % cash, T_XL, c_ink)
	_text(Vector2(note.position.x + 130.0, note.position.y + 36.0), "Gigs played: %d of %d" % [shows, D.TOUR_GIGS + 1], T_SM, c_body, true)
	_text(Vector2(note.position.x + 130.0, note.position.y + 66.0), "Pick the next stop on the road.", T_SM, c_body, true)
	if hover_id >= 0:
		_stop_card(tour[hover_id], _map_pos(tour[hover_id]), hover_id == tour_at)

func _boss_generic(kind: String) -> Dictionary:
	match kind:
		"genre":
			return {"name": "Genre debuffed", "text": "songs of your most common genre score half"}
		"era":
			return {"name": "Decade debuffed", "text": "songs of your most common decade score half"}
		"slot":
			return {"name": "Crowd request", "text": "one slot only takes a chosen genre or decade"}
		"hates":
			return {"name": "Angry crowd", "text": "an extra hate, and hated songs score nothing"}
		"target":
			return {"name": "High expectations", "text": "the target is %d%% higher" % int(round((D.BOSS_TARGET - 1.0) * 100.0))}
		"gear":
			return {"name": "Broken equipment", "text": "one piece of your gear is out"}
		"destroy":
			return {"name": "Rough crowd", "text": "played songs may be destroyed"}
	return {"name": "No time to dig", "text": "no discards"}

func _boss_info(c: Dictionary) -> Dictionary:
	var gen := _boss_generic(String(c["kind"]))
	match String(c["kind"]):
		"genre":
			var g := String(D.GENRES[int(c["genre"])])
			return {"name": gen["name"], "text": "%s songs score half all night." % g, "short": "%s songs score half" % g}
		"era":
			var e := String(D.ERAS[int(c["era"])])
			return {"name": gen["name"], "text": "%s songs score half all night." % e, "short": "%s songs score half" % e}
		"slot":
			var g2 := String(D.GENRES[int(c["genre"])])
			var e2 := String(D.ERAS[int(c["era"])])
			return {"name": gen["name"], "text": "Slot %d only takes %s or %s songs. Anything else scores nothing." % [int(c["slot"]) + 1, g2, e2], "short": "Slot %d needs %s or %s" % [int(c["slot"]) + 1, g2, e2]}
		"hates":
			return {"name": gen["name"], "text": "They hate %s as well, and hated songs score nothing." % String(c["hate"]), "short": "Hates score nothing"}
		"target":
			return {"name": gen["name"], "text": "The target is %d%% higher." % int(round((D.BOSS_TARGET - 1.0) * 100.0)), "short": "Target +%d%%" % int(round((D.BOSS_TARGET - 1.0) * 100.0))}
		"gear":
			var gn := String(c["name"])
			return {"name": gen["name"], "text": "Your %s is broken for the night." % gn, "short": "%s is broken" % gn}
		"destroy":
			return {"name": gen["name"], "text": "Each song you play has a %d%% chance to be destroyed for good." % int(round(D.BOSS_DESTROY * 100.0)), "short": "Songs may be destroyed"}
	return {"name": gen["name"], "text": "You get no discards tonight.", "short": "No discards"}

func _ranked(is_genre: bool) -> Array:
	var counts := {}
	for d: Disc in collection:
		if d.cdr:
			continue
		var k := d.genre if is_genre else d.era
		counts[k] = int(counts.get(k, 0)) + 1
	var ids: Array = counts.keys()
	_shuffle(ids)
	ids.sort_custom(func(a, b): return int(counts[a]) > int(counts[b]))
	return ids

func _make_boss(kind: String) -> Dictionary:
	var head := _make_headliner()
	var ch := {"kind": kind}
	match kind:
		"genre":
			ch["genre"] = int(_ranked(true)[0])
		"era":
			ch["era"] = int(_ranked(false)[0])
		"slot":
			var real: Array = collection.filter(func(o): return not o.cdr)
			var o: Disc = real[rng.randi_range(0, real.size() - 1)]
			ch["slot"] = rng.randi_range(1, D.SETLIST - 2)
			ch["genre"] = o.genre
			ch["era"] = o.era
		"hates":
			var liked: Array = (head["likes"] as Array).map(func(t): return t[1])
			var pick := -1
			for g in _ranked(true):
				if not String(D.GENRES[int(g)]) in liked and not (head["dislikes"] as Array).any(func(t): return t[1] == D.GENRES[int(g)]):
					pick = int(g)
					break
			if pick < 0:
				ch["kind"] = "target"
			else:
				ch["hate"] = D.GENRES[pick]
				(head["dislikes"] as Array).append(["genre", D.GENRES[pick]])
		"gear":
			var bays: Array = []
			for k in rack.size():
				if not rack[k].is_empty():
					bays.append(k)
			if bays.is_empty():
				ch["kind"] = "target"
			else:
				var bk := int(bays[rng.randi_range(0, bays.size() - 1)])
				ch["gear_id"] = String(rack[bk]["id"])
				ch["name"] = String(gear_defs[rack[bk]["id"]]["name"])
	head["challenge"] = ch
	return head

func _enter_boss(kind: String) -> void:
	fork_gigs += 1
	gig_n = fork_gigs
	boss_venue = _make_boss(kind)
	_sfx("page_turn")
	phase = "boss"

func _begin_boss() -> void:
	_start_show(boss_venue)

func _draw_boss() -> void:
	var full := Rect2(-800.0, -800.0, UI_W + 1600.0, UI_H + 1600.0)
	_grad_panel(full, 0.0, Color("2a1220"), Color("7a2a2a"))
	var r := _modal_panel(1200.0, 820.0)
	var ch: Dictionary = boss_venue["challenge"]
	var info := _boss_info(ch)
	_text_center(Rect2(r.position.x, r.position.y + 30.0, r.size.x, 40.0), "HEADLINER  ·  GIG %d OF %d" % [gig_n, _tour_gigs()], T_MD, c_bad, true)
	_heavy_center(Rect2(r.position.x, r.position.y + 80.0, r.size.x, 100.0), String(boss_venue["name"]), T_XL + 16, c_ink)
	_heavy_center(Rect2(r.position.x, r.position.y + 215.0, r.size.x, 60.0), String(info["name"]), T_LG, c_bad)
	_wrap(Vector2(r.position.x + 150.0, r.position.y + 300.0), String(info["text"]), r.size.x - 300.0, T_MD, c_body, true)
	var x := r.position.x + 150.0
	_tag_chips(x, r.position.y + 470.0, "LIKES", boss_venue["likes"], c_good)
	_tag_chips(x, r.position.y + 530.0, "HATES", boss_venue["dislikes"], c_bad)
	_text(Vector2(x, r.position.y + 620.0), "+%d points for a liked song   ·   a hated song scores half" % D.LIKE, 16, c_body, true)
	_hw_button(Rect2(r.get_center().x - 220.0, r.end.y - 120.0, 440.0, 86.0), "Take the stage", _begin_boss, true, Color("3f9b5a"), T_LG)

func _to_title() -> void:
	binder_open = false
	pack = {}
	message_t = 0.0
	_menu_song()
	phase = "title"

func _show_title() -> void:
	phase = "title"

func _menu_bg(art: bool = true) -> void:
	var full := Rect2(-800.0, -800.0, UI_W + 1600.0, UI_H + 1600.0)
	if not art:
		draw_rect(full, Color.BLACK)
		return
	draw_rect(full, Color("0e1018"))
	var tex := _cover_tex(String(menu_album.get("cover", "")))
	if tex != null:
		var ts := tex.get_size()
		var sc := maxf(UI_W / ts.x, UI_H / ts.y)
		var sz := ts * sc
		draw_texture_rect(tex, Rect2((Vector2(UI_W, UI_H) - sz) * 0.5, sz), false)
	draw_rect(full, Color(0.04, 0.05, 0.09, 0.6))
	_grad_panel(full, 0.0, Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.55))

func _to_kits() -> void:
	phase = "kits"

func _pick_kit(i: int) -> void:
	pending_kit = i
	phase = "decks"

func _pick_deck(i: int) -> void:
	_new_run(pending_kit, _decks()[i])

func _draw_decks() -> void:
	_menu_bg(false)
	_heavy_center(Rect2(0.0, 40.0, UI_W, 110.0), "Choose your deck", T_XL + 16, Color("f4efe4"))
	var kit: Dictionary = D.KITS[pending_kit]
	_text_center(Rect2(0.0, 150.0, UI_W, 40.0), "%s kit  ·  %s" % [String(kit["name"]), String(gear_defs[String(kit["gear"])]["name"])], T_MD, Color("b8c0cc"), true)
	var ds := _decks()
	var w := 300.0
	var h := 400.0
	var gap := 24.0
	var per := 6
	for di in ds.size():
		var dk: Dictionary = ds[di]
		var row := di / per
		var n := mini(per, ds.size() - row * per)
		var x0 := (UI_W - (n * w + (n - 1) * gap)) * 0.5
		var r := Rect2(x0 + (di % per) * (w + gap), 270.0 + row * (h + 60.0), w, h)
		var hot := ui_live and r.has_point(mouse)
		if hot:
			_panel(r.grow(8.0), Color("f2c14e"), 22)
		_shadow(r, 18, 10.0)
		_panel(r, Color("f4efe4"), 18)
		var lead := _deck_lead(dk)
		var tex: Texture2D = _cover_tex(String(lead["cover"])) if not lead.is_empty() else null
		_cd_art(Vector2(r.get_center().x, r.position.y + 118.0), 84.0, tex, clock * 0.6 if hot else 0.0)
		_heavy_center(Rect2(r.position.x, r.position.y + 224.0, w, 44.0), String(dk["name"]), T_LG, c_ink)
		_text_center(Rect2(r.position.x, r.position.y + 268.0, w, 24.0), "%d CDs  ·  %d MIX" % [_deck_size(dk), int(dk.get("mixes", 0))], 13, c_muted, true)
		_wrap(Vector2(r.position.x + 22.0, r.position.y + 322.0), String(dk.get("idea", "")), w - 44.0, 15, c_body, true)
		if ui_live:
			_register(r, _pick_deck.bind(di))
	_hw_button(Rect2(70.0, 1336.0, 260.0, 84.0), "Back", _to_kits, true, Color("6a6f77"), T_MD)

func _draw_title() -> void:
	_menu_bg(false)
	var c := Vector2(UI_W * 0.5, 470.0)
	var ctex := _cover_tex(String(menu_album.get("cover", "")))
	_draw_cd_player(Rect2(c - Vector2(280.0, 280.0), Vector2(560.0, 560.0)), ctex if ctex != null else null, clock * 0.8, true)
	_heavy_center(Rect2(0.0, 820.0, UI_W, 150.0), "Disc Engine", T_HERO + 40, Color("f4efe4"))
	_text_center(Rect2(0.0, 985.0, UI_W, 50.0), "A DJ roguelike. Lay out a set, chain your effects, win the crowd.", T_MD, Color(1, 1, 1, 0.85), true)
	_hw_button(Rect2(UI_W * 0.5 - 220.0, 1090.0, 440.0, 100.0), "Play", _to_kits, true, Color("3f9b5a"), T_XL)
	_hw_button(Rect2(UI_W * 0.5 - 180.0, 1220.0, 360.0, 80.0), "Settings", _open_settings, true, Color("6a6f77"), T_MD)

func _kit_gear(kit: Dictionary) -> Dictionary:
	return {"id": String(kit["gear"]), "used": 0, "broken": false}

func _draw_kits() -> void:
	_menu_bg(false)
	_heavy_center(Rect2(0.0, 40.0, UI_W, 110.0), "Choose your kit", T_XL + 16, Color("f4efe4"))
	var n: int = D.KITS.size()
	var w := 560.0
	var gap := 40.0
	var x0 := (UI_W - (n * w + (n - 1) * gap)) * 0.5
	for i in n:
		var kit: Dictionary = D.KITS[i]
		var r := Rect2(x0 + i * (w + gap), 170.0, w, 1130.0)
		var hot := ui_live and r.has_point(mouse)
		if hot:
			_panel(r.grow(10.0), Color("f2c14e"), 24)
		_shadow(r, 20, 12.0)
		_panel(r, Color("f4efe4"), 20)
		var x := r.position.x + 30.0
		var iw := r.size.x - 60.0
		_heavy(Vector2(x, r.position.y + 70.0), String(kit["name"]), T_XL, c_ink)
		_wrap(Vector2(x, r.position.y + 112.0), String(kit["idea"]), iw, T_SM, c_body, true)
		_text(Vector2(x, r.position.y + 290.0), "STARTING GEAR", 14, c_muted, true)
		_draw_gear(Rect2(x, r.position.y + 304.0, iw, 200.0), _kit_gear(kit), 0.5)
		_text(Vector2(x, r.position.y + 550.0), "THE DECK", 14, c_muted, true)
		_wrap(Vector2(x, r.position.y + 580.0), "Next you pick a deck: one for every genre and decade.", iw, T_SM, c_body, true)
		_wrap(Vector2(x, r.position.y + 680.0), "Every CD has one effect that reacts to the songs around it. Lay out the whole set, then press PLAY.", iw, 15, c_body, true)
		_hw_button(Rect2(r.get_center().x - 190.0, r.end.y - 110.0, 380.0, 80.0), "Pick this kit", _pick_kit.bind(i), true, Color("3f9b5a"), T_MD)
		if ui_live:
			_register(r, _pick_kit.bind(i))
	_hw_button(Rect2(70.0, 1336.0, 260.0, 84.0), "Back", _show_title, true, Color("6a6f77"), T_MD)

func _road_curve(a: Vector2, c: Vector2, b: Vector2) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 25:
		var t := i / 24.0
		pts.append(a.lerp(c, t).lerp(c.lerp(b, t), t))
	return pts

func _draw_fork() -> void:
	var full := Rect2(-800.0, -800.0, UI_W + 1600.0, UI_H + 1600.0)
	_grad_panel(full, 0.0, Color("16213d"), Color("e08a4f"))
	var g := RandomNumberGenerator.new()
	g.seed = 7
	for k in 70:
		draw_circle(Vector2(g.randf_range(0.0, UI_W), g.randf_range(0.0, 700.0)), g.randf_range(1.2, 2.6), Color(1, 1, 1, g.randf_range(0.3, 0.9)))
	draw_circle(Vector2(UI_W * 0.5, 1000.0), 260.0, Color("f6c26b", 0.85))
	draw_rect(Rect2(-800.0, 990.0, UI_W + 1600.0, 900.0), Color("1e2c24"))
	var sites := [Rect2(150.0, 190.0, 1000.0, 790.0), Rect2(1410.0, 190.0, 1000.0, 790.0)]
	var base := Vector2(UI_W * 0.5, 1500.0)
	var hover_k := -1
	for k in sites.size():
		if ui_live and (sites[k] as Rect2).has_point(mouse):
			hover_k = k
	for k in sites.size():
		var s: Rect2 = sites[k]
		var pts := _road_curve(base, Vector2(UI_W * 0.5, 1110.0), Vector2(s.get_center().x, s.end.y + 10.0))
		if k == hover_k:
			draw_polyline(pts, Color("f2c14e"), 224.0, true)
		draw_polyline(pts, Color("d8d2c0"), 206.0, true)
		draw_polyline(pts, Color("2c2f35"), 188.0, true)
		for i in range(0, pts.size() - 1, 2):
			draw_line(pts[i], pts[i + 1], Color("f2c14e"), 8.0, true)
	_heavy_center(Rect2(0.0, 40.0, UI_W, 110.0), "Choose your lane", T_XL + 16, Color("f4efe4"))
	_text_center(Rect2(0.0, 134.0, UI_W, 40.0), "Tour %d of %d  ·  %d gigs, a record shop after each" % [forks_done, _forks_total(), D.LANE_GIGS], T_SM, c_gold, true)
	var tip_nd := {}
	var tip_c := Vector2.ZERO
	for k in sites.size():
		var s: Rect2 = sites[k]
		var road: Dictionary = fork_roads[k]
		if k == hover_k:
			_panel(s.grow(12.0), Color("f2c14e"), 26)
		_shadow(s, 20, 14.0)
		_panel(s, Color("1d5c3a"), 20, Color("f4efe4"), 8)
		_panel(s.grow(-18.0), Color(0, 0, 0, 0), 14, Color("f4efe4", 0.45), 3)
		var band := Rect2(s.position.x + 36.0, s.position.y + 36.0, s.size.x - 72.0, 128.0)
		_panel(band, Color("5d626a"), 12, Color(1, 1, 1, 0.6), 3)
		_heavy(Vector2(band.position.x + 28.0, band.position.y + 70.0), "LANE %s" % ["A", "B"][k], T_XL, Color.WHITE)
		_text(Vector2(band.position.x + 30.0, band.position.y + 106.0), "toward " + String(road["town"]), T_SM, Color(1, 1, 1, 0.85), true)
		var shown: Array = (road["stops"] as Array).filter(func(n): return String(n["kind"]) in ["venue", "boss"])
		for i in shown.size():
			var nd: Dictionary = shown[i]
			var kind := String(nd["kind"])
			var row := Rect2(s.position.x + 36.0, s.position.y + 190.0 + i * 190.0, s.size.x - 72.0, 172.0)
			_panel(row, Color(0, 0, 0, 0.25), 12)
			_map_icon("headliner" if kind == "boss" else kind, Vector2(row.position.x + 80.0, row.position.y + 86.0), false, [])
			_text_right(row.end.x - 20.0, row.position.y + 34.0, "HEADLINER" if kind == "boss" else "GIG %d" % (fork_gigs + i + 1), 14, Color(1, 1, 1, 0.6), true)
			var tx := row.position.x + 170.0
			if kind == "boss":
				var bgen := _boss_generic(String(nd["boss"]))
				_heavy(Vector2(tx, row.position.y + 70.0), "Headliner", T_MD, Color.WHITE)
				_text(Vector2(tx, row.position.y + 108.0), String(bgen["name"]), T_SM, Color("f2c14e"), true)
				_wrap(Vector2(tx, row.position.y + 138.0), String(bgen["text"]), row.end.x - tx - 20.0, 15, Color(1, 1, 1, 0.8), true)
				continue
			var v: Dictionary = nd["venue"]
			var vn := String(v["name"])
			_heavy(Vector2(tx, row.position.y + 70.0), vn, T_SM if _heavy_w(vn, T_MD) > 600.0 else T_MD, Color.WHITE)
			var gh: Dictionary = nd["hint"]
			var like_t: Array = (v["likes"] as Array)[int(gh["like"])]
			var hate_t: Array = (v["dislikes"] as Array)[int(gh["hate"])]
			var cx := tx
			_text(Vector2(cx, row.position.y + 116.0), "LIKES", 13, Color("9be3a8"), true)
			cx += _text_w("LIKES", 13, true) + 10.0
			cx += _tip_chip(cx, row.position.y + 94.0, like_t, Color("9be3a8")) + 26.0
			_text(Vector2(cx, row.position.y + 116.0), "HATES", 13, Color("ffb0a6"), true)
			cx += _text_w("HATES", 13, true) + 10.0
			_tip_chip(cx, row.position.y + 94.0, hate_t, Color("ffb0a6"))
			if ui_live and row.has_point(mouse):
				tip_nd = nd
				tip_c = Vector2(row.get_center().x, row.end.y - 14.0)
		var post := Rect2(s.get_center().x - 14.0, s.end.y, 28.0, 40.0)
		draw_rect(post, Color("8a9099"))
		if ui_live:
			_register(s, _pick_road.bind(k))
	var note := Rect2(430.0, 1336.0, 520.0, 84.0)
	_shadow(note, 2, 4.0)
	_panel(note, Color("fff3a8"), 2)
	_heavy(Vector2(note.position.x + 20.0, note.position.y + 52.0), "$%d" % cash, T_XL, c_ink)
	_text(Vector2(note.position.x + 130.0, note.position.y + 36.0), "Tour %d of %d" % [forks_done, _forks_total()], T_SM, c_body, true)
	_text(Vector2(note.position.x + 130.0, note.position.y + 66.0), "Pick a lane. Gig 3 is the headliner.", T_SM, c_body, true)
	if not tip_nd.is_empty():
		_stop_card(tip_nd, tip_c, false)

func _draw_map_paper(P: Rect2) -> void:
	_shadow(P, 4, 14.0)
	_panel(P, Color("ece4cf"), 4)
	var g := RandomNumberGenerator.new()
	g.seed = map_seed
	for k in 5:
		var cx := g.randf_range(P.position.x + 200.0, P.end.x - 200.0)
		var cy := g.randf_range(P.position.y + 150.0, P.end.y - 150.0)
		var pts := PackedVector2Array()
		var rad := g.randf_range(150.0, 320.0)
		for i in 18:
			pts.append((Vector2(cx, cy) + Vector2.from_angle(TAU * i / 18.0) * rad * g.randf_range(0.7, 1.15)).clamp(P.position + Vector2(4, 4), P.end - Vector2(4, 4)))
		draw_colored_polygon(pts, Color("d8e3c0", 0.55))
	var lake := PackedVector2Array()
	var lc := Vector2(g.randf_range(P.position.x + 500.0, P.end.x - 500.0), g.randf_range(P.position.y + 250.0, P.end.y - 250.0))
	for i in 22:
		lake.append((lc + Vector2.from_angle(TAU * i / 22.0) * Vector2(170.0, 90.0) * g.randf_range(0.75, 1.1)).clamp(P.position + Vector2(4, 4), P.end - Vector2(4, 4)))
	draw_colored_polygon(lake, Color("b9d3e0"))
	draw_polyline(lake + PackedVector2Array([lake[0]]), Color("7fa6bd"), 2.0, true)
	var river := PackedVector2Array()
	var ry := g.randf_range(P.position.y + 200.0, P.end.y - 200.0)
	var x := P.position.x
	while x <= P.end.x:
		river.append(Vector2(x, ry + sin(x * 0.006 + map_seed % 7) * 60.0 + sin(x * 0.017) * 18.0))
		x += 20.0
	draw_polyline(river, Color("8fb6cc"), 7.0, true)
	var gx := P.position.x + 120.0
	while gx < P.end.x:
		draw_line(Vector2(gx, P.position.y), Vector2(gx, P.end.y), Color(0, 0, 0, 0.035), 1.0)
		gx += 240.0
	var gy := P.position.y + 120.0
	while gy < P.end.y:
		draw_line(Vector2(P.position.x, gy), Vector2(P.end.x, gy), Color(0, 0, 0, 0.035), 1.0)
		gy += 240.0
	for k in 2:
		var bx := P.position.x + P.size.x * (0.3 + k * 0.38) + g.randf_range(-60.0, 60.0)
		var yy := P.position.y
		while yy < P.end.y:
			var y2 := minf(yy + 14.0, P.end.y)
			draw_line(Vector2(bx + sin(yy * 0.01) * 30.0, yy), Vector2(bx + sin(y2 * 0.01) * 30.0, y2), Color("b07aa1", 0.45), 2.0)
			yy += 26.0
	for k in 2:
		var fx := P.position.x + P.size.x * (k + 1) / 3.0
		draw_line(Vector2(fx, P.position.y), Vector2(fx, P.end.y), Color(0, 0, 0, 0.09), 4.0)
		draw_line(Vector2(fx + 3.0, P.position.y), Vector2(fx + 3.0, P.end.y), Color(1, 1, 1, 0.3), 2.0)
	var fy := P.get_center().y
	draw_line(Vector2(P.position.x, fy), Vector2(P.end.x, fy), Color(0, 0, 0, 0.08), 4.0)
	draw_line(Vector2(P.position.x, fy + 3.0), Vector2(P.end.x, fy + 3.0), Color(1, 1, 1, 0.3), 2.0)
	var ring := Vector2(P.end.x - 330.0, P.end.y - 170.0)
	draw_arc(ring, 70.0, 0.4, TAU - 0.6, 48, Color("7a5230", 0.22), 9.0, true)
	draw_arc(ring + Vector2(4, 3), 62.0, 1.0, TAU - 1.6, 48, Color("7a5230", 0.12), 4.0, true)
	for corner in [P.position + Vector2(40.0, -12.0), Vector2(P.end.x - 160.0, P.position.y - 12.0)]:
		draw_rect(Rect2(corner, Vector2(120.0, 34.0)), Color(1, 1, 0.9, 0.55))
		draw_rect(Rect2(corner, Vector2(120.0, 34.0)), Color(0, 0, 0, 0.06), false, 1.0)

func _draw_road(a: Vector2, b: Vector2, done: bool, num: int) -> void:
	var mid := (a + b) * 0.5 + Vector2(0.0, (b.x - a.x) * 0.06 * (1.0 if num % 2 == 0 else -1.0))
	var pts := PackedVector2Array()
	for i in 17:
		var t := i / 16.0
		pts.append(a.lerp(mid, t).lerp(mid.lerp(b, t), t))
	draw_polyline(pts, Color("8a7a58", 0.55), 13.0, true)
	draw_polyline(pts, Color("f2c14e") if num % 3 != 0 else Color("fbfaf5"), 8.0, true)
	if done:
		draw_polyline(pts, Color("d7263d", 0.55), 20.0, true)
	var sc := pts[8] + Vector2(0.0, -22.0)
	var shield := PackedVector2Array([sc + Vector2(-18, -14), sc + Vector2(18, -14), sc + Vector2(18, 4), sc + Vector2(0, 16), sc + Vector2(-18, 4)])
	draw_colored_polygon(shield, Color("1f4e8c"))
	draw_polyline(shield + PackedVector2Array([shield[0]]), Color.WHITE, 2.0, true)
	draw_rect(Rect2(sc + Vector2(-18, -14), Vector2(36, 7)), Color("c0392b"))
	_text_center(Rect2(sc.x - 18.0, sc.y - 7.0, 36.0, 20.0), str(num % 99 + 1), 12, Color.WHITE, true)

func _draw_stop(nd: Dictionary, c: Vector2, visited: bool, here: bool, can: bool, hot: bool) -> void:
	var kind := String(nd["kind"])
	if can:
		draw_arc(c, 30.0 + 4.0 * sin(clock * 4.0), 0.0, TAU, 40, Color("d7263d", 0.8 if hot else 0.5), 4.0, true)
	draw_circle(c, 11.0, Color.WHITE)
	draw_arc(c, 11.0, 0.0, TAU, 24, Color("2b2e33"), 3.0, true)
	var ic := c + Vector2(0.0, -32.0)
	draw_line(c, ic, Color("5d626a"), 3.0)
	_map_icon(kind, ic, here, nd.get("stamp", []))
	_stop_label(nd, c, 1.0 if (can or here or kind == "start") else (0.55 if visited else 0.8), hot)

func _marker_font() -> Font:
	if font_marker == null:
		var path := "res://assets/fonts/PermanentMarker-Regular.ttf"
		if ResourceLoader.exists(path):
			font_marker = load(path)
		else:
			var ff := FontFile.new()
			font_marker = ff if ff.load_dynamic_font(path) == OK else font_heavy
	return font_marker

func _marker(center: Vector2, s: String, size: int, col: Color, rot: float, under: int = 0) -> void:
	var f := _marker_font()
	var w := f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_set_transform(screen_origin + center * ui_scale, rot, Vector2(ui_scale, ui_scale))
	var p := Vector2(-w * 0.5, size * 0.35)
	draw_string(f, p + Vector2(1.2, 1.0), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(col, col.a * 0.55))
	draw_string(f, p, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)
	for k in under:
		var y := size * 0.55 + k * 7.0
		draw_line(Vector2(-w * 0.5, y), Vector2(w * 0.5, y + 1.5), col, 3.0, true)
	draw_set_transform(screen_origin, 0.0, Vector2(ui_scale, ui_scale))

func _stop_label(nd: Dictionary, c: Vector2, a: float, hot: bool) -> void:
	var kind := String(nd["kind"])
	var ink := Color(0.07, 0.07, 0.09, a)
	var tilt := (int(nd["id"]) * 37 % 7 - 3) * 0.012
	var name := ""
	var sub := ""
	var sub_col := Color("d7263d")
	match kind:
		"start":
			name = String(nd["town"])
			sub = "home"
		"shop":
			name = "Record shop"
			var sh: Dictionary = nd.get("hint", {})
			if not sh.is_empty():
				var gid := String(sh["gear"])
				if String(sh["show"]) == "gear" and not gid in _owned_gear():
					sub = "Has %s" % String(gear_defs[gid]["name"])
					sub_col = Color("2e6ea6")
				else:
					sub = "Has %s %s" % [D.GENRES[int(sh["genre"])], D.ERAS[int(sh["era"])]]
					sub_col = Color(D.GENRE_COLORS[int(sh["genre"])]).darkened(0.1)
		"pickup":
			name = "Pickup"
			var st: Array = nd.get("stamp", [])
			if st.size() == 2 and int(st[0]) >= 0:
				sub = String(D.GENRES[int(st[0])])
				sub_col = Color(D.GENRE_COLORS[int(st[0])]).darkened(0.1)
		"cash":
			name = "Tip jar"
		_:
			name = String((nd["venue"] as Dictionary)["name"])
			sub = String(nd["town"])
	var fs := 28
	var w := _marker_font().get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	if w > 200.0:
		fs = maxi(16, int(fs * 200.0 / w))
	_marker(Vector2(c.x, c.y + 50.0), name, fs, ink, tilt, 2 if kind == "headliner" else (1 if hot else 0))
	if sub != "":
		var sfs := 18
		var sw := _marker_font().get_string_size(sub, HORIZONTAL_ALIGNMENT_LEFT, -1, sfs).x
		if sw > 200.0:
			sfs = maxi(12, int(sfs * 200.0 / sw))
		_marker(Vector2(c.x, c.y + 80.0), sub, sfs, Color(sub_col, a), tilt * 0.5)
	if kind in ["venue", "headliner"]:
		var v: Dictionary = nd["venue"]
		var gh: Dictionary = nd.get("hint", {})
		var likes: Array = v["likes"]
		var hates: Array = v["dislikes"]
		if not likes.is_empty():
			_marker(Vector2(c.x, c.y + 106.0), "+ " + String((likes[int(gh.get("like", 0))] as Array)[1]), 17, Color(c_good.darkened(0.2), a), tilt * 0.4)
		if not hates.is_empty():
			_marker(Vector2(c.x, c.y + 130.0), "- " + String((hates[int(gh.get("hate", 0))] as Array)[1]), 17, Color(c_bad.darkened(0.1), a), tilt * 0.4)

func _stop_card(nd: Dictionary, c: Vector2, here: bool) -> void:
	var v: Dictionary = nd["venue"]
	var head := String(nd["kind"]) == "headliner"
	var P := _map_rect()
	var tag := Rect2(c.x - 170.0, c.y + 24.0, 340.0, 196.0)
	tag.position.x = clampf(tag.position.x, P.position.x + 12.0, P.end.x - tag.size.x - 12.0)
	if tag.end.y > P.end.y - 12.0:
		tag.position.y = c.y - 60.0 - tag.size.y
	_shadow(tag, 2, 6.0)
	_panel(tag, Color(1, 1, 0.97), 3, Color("d7263d"), 3)
	var x := tag.position.x + 14.0
	_text(Vector2(x, tag.position.y + 26.0), ("HEADLINER · " if head else "GIG · ") + String(nd["town"]).to_upper(), 14, Color("b8860b") if head else Color("d7263d"), true)
	_heavy(Vector2(x, tag.position.y + 58.0), String(v["name"]), T_SM if _heavy_w(String(v["name"]), T_MD) > 300.0 else T_MD, c_ink)
	var y := tag.position.y + 92.0
	for row: Array in [["LIKES", v["likes"], c_good, "+%d points each" % D.LIKE], ["HATES", v["dislikes"], c_bad, "scores half"]]:
		_text(Vector2(x, y), "%s  ·  %s" % [row[0], row[3]], 13, row[2], true)
		var cx := x
		for t: Array in row[1]:
			cx += _tip_chip(cx, y + 8.0, t, row[2]) + 6.0
		y += 52.0
	if here:
		_text_right(tag.end.x - 12.0, tag.position.y + 22.0, "HERE", 13, Color("b8860b"), true)

func _map_icon(kind: String, ic: Vector2, here: bool = false, stamp: Array = []) -> void:
	match kind:
		"shop":
			draw_circle(ic + Vector2(2, 3), 20.0, Color(0, 0, 0, 0.3))
			draw_circle(ic, 20.0, Color("15171a"))
			for k in 3:
				draw_arc(ic, 8.0 + k * 3.5, 0.0, TAU, 24, Color(1, 1, 1, 0.12), 1.0, true)
			draw_circle(ic, 6.0, Color("e2725b"))
			draw_circle(ic, 1.8, Color("15171a"))
		"start":
			var hb := Rect2(ic - Vector2(22.0, 8.0), Vector2(44.0, 26.0))
			_panel(Rect2(hb.position + Vector2(2, 3), hb.size), Color(0, 0, 0, 0.3), 2)
			_panel(hb, Color("d9cfb6"), 2, Color("7a7260"), 2)
			draw_colored_polygon(PackedVector2Array([ic + Vector2(-27.0, -7.0), ic + Vector2(0.0, -28.0), ic + Vector2(27.0, -7.0)]), Color("b03a2e"))
			draw_rect(Rect2(ic.x - 6.0, ic.y + 2.0, 12.0, 16.0), Color("6b4a32"))
			draw_circle(ic + Vector2(3.0, 11.0), 1.4, Color("e9b949"))
			draw_rect(Rect2(hb.position.x + 4.0, hb.end.y - 9.0, 11.0, 6.0), Color("2b2e33"))
			draw_rect(Rect2(hb.end.x - 15.0, hb.end.y - 9.0, 11.0, 6.0), Color("2b2e33"))
		"pickup":
			if stamp.size() == 2:
				var sb := Rect2(ic - Vector2(26.0, 20.0), Vector2(52.0, 40.0))
				_panel(Rect2(sb.position + Vector2(2, 3), sb.size), Color(0, 0, 0, 0.3), 3)
				_panel(sb, Color("b98a55"), 3, Color("7a5a33"), 2)
				draw_rect(Rect2(sb.position.x + 20.0, sb.position.y, 12.0, 9.0), Color("e6d3a3"))
				var lab := Rect2(sb.position.x + 5.0, sb.position.y + 13.0, 42.0, 22.0)
				if int(stamp[0]) >= 0:
					_panel(lab, Color(D.GENRE_COLORS[int(stamp[0])]), 3, Color(1, 1, 1, 0.5), 1)
					_heavy_center(lab, String(D.GENRE_SHORT[int(stamp[0])]), 13, Color.WHITE)
				else:
					_panel(lab, Color("5d626a"), 3, Color(1, 1, 1, 0.5), 1)
					_heavy_center(lab, String(D.ERAS[int(stamp[1])]), 17, Color.WHITE)
			else:
				var br := Rect2(ic - Vector2(20, 16), Vector2(40, 32))
				_panel(Rect2(br.position + Vector2(2, 3), br.size), Color(0, 0, 0, 0.3), 3)
				_panel(br, Color("b98a55"), 3, Color("7a5a33"), 2)
				draw_rect(Rect2(br.position.x + 16.0, br.position.y, 8.0, br.size.y), Color("e6d3a3"))
				_heavy_center(br, "?", 20, Color("4a3222"))
		"cash":
			draw_circle(ic + Vector2(2, 3), 19.0, Color(0, 0, 0, 0.3))
			draw_circle(ic, 19.0, Color("3f9b5a"))
			draw_arc(ic, 15.0, 0.0, TAU, 32, Color(1, 1, 1, 0.5), 2.0, true)
			_heavy_center(Rect2(ic - Vector2(19, 19), Vector2(38, 38)), "$", 22, Color.WHITE)
		"headliner":
			var star := PackedVector2Array()
			for i in 10:
				star.append(ic + Vector2.from_angle(-PI / 2.0 + TAU * i / 10.0) * (26.0 if i % 2 == 0 else 11.0))
			draw_colored_polygon(star, Color("e9b949"))
			draw_polyline(star + PackedVector2Array([star[0]]), Color("8a6a10"), 2.0, true)
		_:
			draw_circle(ic + Vector2(2, 3), 14.0, Color(0, 0, 0, 0.3))
			var col := Color("e9b949") if here else (Color("d7263d") if kind == "venue" else Color("2e6ea6"))
			draw_circle(ic, 14.0, col)
			draw_circle(ic - Vector2(4, 4), 5.0, Color(1, 1, 1, 0.55))

func _tip_chip(x: float, y: float, tag: Array, ring: Color) -> float:
	var is_genre: bool = tag[0] == "genre"
	var t := String(tag[1]).to_upper() if is_genre else String(tag[1])
	var w := _text_w(t, 14, true) + 18.0
	var r := Rect2(x, y, w, 28.0)
	var bg := Color(D.GENRE_COLORS[D.GENRES.find(String(tag[1]))]) if is_genre else Color("5d626a")
	_panel(r, bg, 10, ring, 2)
	_text_center(r, t, 14, Color.WHITE, true)
	return w

func _draw_map_legend(P: Rect2) -> void:
	var r := Rect2(P.position.x + 30.0, P.position.y + 30.0, 700.0, 116.0)
	_panel(r, Color("f7f1e1"), 3, Color(c_ink, 0.5), 2)
	_panel(r.grow(-6.0), Color(0, 0, 0, 0), 2, Color(c_ink, 0.25), 1)
	_heavy(Vector2(r.position.x + 20.0, r.position.y + 46.0), "Tour Map", T_LG, c_ink)
	var items := [["venue", "Gig"], ["pickup", "Pickup"], ["cash", "Cash"], ["shop", "Record shop"], ["headliner", "Headliner"]]
	var lx := r.position.x + 30.0
	var ly := r.position.y + 84.0
	for it: Array in items:
		_map_icon(String(it[0]), Vector2(lx + 10.0, ly))
		_text(Vector2(lx + 38.0, ly + 6.0), String(it[1]), 16, c_body, true)
		lx += 38.0 + _text_w(String(it[1]), 16, true) + 34.0
	var cc := Vector2(P.end.x - 90.0, P.position.y + 90.0)
	draw_circle(cc, 46.0, Color("f7f1e1"))
	draw_arc(cc, 46.0, 0.0, TAU, 40, Color(c_ink, 0.5), 2.0, true)
	draw_colored_polygon(PackedVector2Array([cc + Vector2(0, -40), cc + Vector2(8, 0), cc + Vector2(-8, 0)]), Color("d7263d"))
	draw_colored_polygon(PackedVector2Array([cc + Vector2(0, 40), cc + Vector2(8, 0), cc + Vector2(-8, 0)]), Color(c_ink, 0.6))
	_text_center(Rect2(cc.x - 20.0, cc.y - 70.0, 40.0, 20.0), "N", 15, c_ink, true)

func _draw_pickup() -> void:
	draw_rect(Rect2(-800.0, -800.0, UI_W + 1600.0, UI_H + 1600.0), Color("050506"))
	var cx := UI_W * 0.5
	var floor_y := 1080.0
	var top := PackedVector2Array([Vector2(cx - 70.0, -40.0), Vector2(cx + 70.0, -40.0), Vector2(cx + 480.0, floor_y), Vector2(cx - 480.0, floor_y)])
	draw_polygon(top, PackedColorArray([Color(1, 0.96, 0.85, 0.22), Color(1, 0.96, 0.85, 0.22), Color(1, 0.96, 0.85, 0.05), Color(1, 0.96, 0.85, 0.05)]))
	for k in 6:
		var rx := 520.0 - k * 70.0
		var ry := 90.0 - k * 12.0
		var pool := PackedVector2Array()
		for i in 48:
			pool.append(Vector2(cx, floor_y) + Vector2(cos(TAU * i / 48.0) * rx, sin(TAU * i / 48.0) * ry))
		draw_colored_polygon(pool, Color(1, 0.95, 0.8, 0.05 + k * 0.03))
	var hits := int(pickup.get("hits", 0))
	var need := int(pickup.get("need", 1))
	var open := hits >= need
	var kind := String(pickup.get("kind", "pickup"))
	var shake := Vector2(sin(clock * 70.0), cos(clock * 53.0)) * 10.0 * pickup_shake / 0.35
	var title := "TIP JAR" if kind == "cash" else "PICKUP"
	_text_center(Rect2(0.0, 90.0, UI_W, 60.0), title, T_LG, Color(1, 0.95, 0.8, 0.8), true)
	if not open:
		var obj := Rect2(cx - 200.0, floor_y - 300.0, 400.0, 300.0)
		if kind == "cash":
			_draw_tip_jar(Vector2(cx, floor_y) + shake, false)
		else:
			_draw_package(Vector2(cx, floor_y) + shake, hits)
		var hot := obj.has_point(mouse)
		if hot:
			draw_arc(Vector2(cx, floor_y - 150.0), 230.0, 0.0, TAU, 64, Color(1, 0.95, 0.8, 0.15), 3.0, true)
		_register(obj.grow(40.0), _hit_pickup)
		var hint := "Click the jar" if kind == "cash" else "Click to open"
		_text_center(Rect2(0.0, floor_y + 90.0, UI_W, 40.0), hint, T_MD, Color(1, 1, 1, 0.75), true)
		if need > 1:
			for k in need:
				var dc := Vector2(cx - (need - 1) * 22.0 + k * 44.0, floor_y + 160.0)
				draw_circle(dc, 10.0, Color(1, 0.85, 0.4) if k < hits else Color(1, 1, 1, 0.15))
		return
	for k in 14:
		var a := TAU * k / 14.0 + clock * 0.2
		draw_line(Vector2(cx, floor_y - 260.0), Vector2(cx, floor_y - 260.0) + Vector2.from_angle(a) * 420.0, Color(1, 0.9, 0.6, 0.06), 30.0)
	var by := floor_y + 140.0
	if kind == "cash":
		_draw_tip_jar(Vector2(cx, floor_y), true)
		_heavy_center(Rect2(0.0, floor_y - 560.0, UI_W, 120.0), "+$%d" % int(pickup["cash"]), T_HERO + 20, Color("7fe0a0"))
		_hw_button(Rect2(cx - 220.0, by, 440.0, 90.0), "Back on the road", _leave_pickup, true, Color("3f9b5a"), T_LG)
		return
	_draw_pickup_options(floor_y, by)

func _draw_card_detail(dc: Vector2, d: Disc, rad: float) -> void:
	_draw_jewel(Rect2(dc - Vector2(rad, rad), Vector2(rad, rad) * 2.0), d)
	_heavy_center(Rect2(dc.x - 270.0, dc.y + rad + 72.0, 540.0, 50.0), d.title, T_LG, Color.WHITE)
	var y := dc.y + rad + 130.0
	if d.edition != "":
		var ed: Dictionary = D.EDITIONS[d.edition]
		_text_center(Rect2(dc.x - 270.0, y, 540.0, 30.0), "%s EDITION" % String(ed["name"]).to_upper(), T_SM, Color(ed["color"]).lightened(0.3), true)
		_wrap(Vector2(dc.x - 240.0, y + 40.0), String(ed["text"]), 480.0, T_SM, Color("e8ecf2"))

func _draw_pickup_options(floor_y: float, by: float) -> void:
	var cx := UI_W * 0.5
	_heavy_center(Rect2(0.0, 170.0, UI_W, 70.0), "Take one", T_XL, Color.WHITE)
	var opts: Array = pickup["options"]
	for k in opts.size():
		var o: Dictionary = opts[k]
		var dc := Vector2(cx + (k - (opts.size() - 1) * 0.5) * 560.0, 540.0)
		if o.has("disc"):
			_draw_card_detail(dc, o["disc"], 160.0)
			_hw_button(Rect2(dc.x - 160.0, 1000.0, 320.0, 80.0), "Take this CD", _take_option.bind(k), true, Color("3f9b5a"), T_MD)
		else:
			var g: Dictionary = o["gear"]
			_text_center(Rect2(dc.x - 250.0, 360.0, 500.0, 40.0), "GEAR", T_MD, c_gold, true)
			_draw_gear(Rect2(dc.x - 250.0, 420.0, 500.0, 214.0), g, 0.6 + 0.4 * sin(clock * 3.0))
			_hw_button(Rect2(dc.x - 160.0, 1000.0, 320.0, 80.0), "Install this", _take_option.bind(k), true, Color("3f9b5a"), T_MD)
	_hw_button(Rect2(cx - 150.0, by, 300.0, 70.0), "Leave them", _leave_pickup, true, Color("6a6f77"), T_MD)

func _draw_package(base: Vector2, hits: int) -> void:
	var w := 360.0
	var h := 250.0
	var body := Rect2(base.x - w * 0.5, base.y - h, w, h)
	draw_rect(Rect2(body.position + Vector2(10, 14), body.size), Color(0, 0, 0, 0.5))
	_surface(body, 4.0, "cardboard", Color("c79b63"), Color("a97e4a"), 400.0)
	_panel(body, Color(0, 0, 0, 0), 4, Color("7a5a33"), 2)
	var lift := hits * 14.0
	var lid := Rect2(body.position.x - 14.0, body.position.y - 46.0 - lift, w + 28.0, 50.0)
	draw_set_transform(lid.get_center(), deg_to_rad(-hits * 3.0), Vector2.ONE)
	var lr := Rect2(-lid.size * 0.5, lid.size)
	_surface(lr, 4.0, "cardboard", Color("d1a874"), Color("b38a55"), 400.0)
	_panel(lr, Color(0, 0, 0, 0), 4, Color("7a5a33"), 2)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var tx := base.x - 22.0
	var gap := hits * 10.0
	draw_rect(Rect2(tx, body.position.y, 44.0, h * 0.5 - gap), Color("e6d3a3", 0.95))
	draw_rect(Rect2(tx, body.position.y + h * 0.5 + gap, 44.0, h * 0.5 - gap), Color("e6d3a3", 0.95))
	if hits > 0:
		for k in 5:
			var yy := body.position.y + h * 0.5 - gap + (k % 2) * 6.0
			draw_line(Vector2(tx + k * 11.0, yy), Vector2(tx + k * 11.0 + 6.0, yy + 6.0), Color("8a6a40"), 2.0)
	_heavy_center(Rect2(body.position.x + 40.0, body.position.y + 70.0, 100.0, 110.0), "?", T_HERO, Color("4a3222", 0.7))
	_text_center(Rect2(body.end.x - 150.0, body.end.y - 70.0, 130.0, 30.0), "FRAGILE", 15, Color("b03a2e"), true)

func _draw_tip_jar(base: Vector2, empty: bool) -> void:
	var w := 230.0
	var h := 280.0
	var jar := Rect2(base.x - w * 0.5, base.y - h, w, h)
	draw_rect(Rect2(jar.position + Vector2(10, 14), jar.size), Color(0, 0, 0, 0.4))
	if not empty:
		for k in 7:
			var br := Rect2(jar.position.x + 20.0 + (k % 3) * 60.0, jar.end.y - 60.0 - (k / 3) * 46.0, 70.0, 36.0)
			_panel(br, Color("7fb98a").darkened(k * 0.04), 3, Color("3f6e48"), 1)
			_text_center(br, "$", 18, Color("2f5a38"), true)
	_panel(jar, Color(0.75, 0.88, 0.95, 0.18), 30, Color(0.85, 0.95, 1.0, 0.6), 3)
	draw_line(jar.position + Vector2(26, 30), Vector2(jar.position.x + 26.0, jar.end.y - 30.0), Color(1, 1, 1, 0.35), 6.0)
	var rim := Rect2(jar.position.x - 10.0, jar.position.y - 26.0, w + 20.0, 34.0)
	_panel(rim, Color("9aa0a6"), 8, Color("5d626a"), 2)
	var lab := Rect2(jar.position.x + 30.0, jar.position.y + 80.0, w - 60.0, 60.0)
	_panel(lab, Color("fbfaf5"), 3)
	_heavy_center(lab, "TIPS", T_LG, Color("b03a2e"))
