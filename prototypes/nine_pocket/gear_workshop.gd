extends Control

const D := preload("res://prototypes/nine_pocket/nine_pocket_data.gd")
const PREVIEW := preload("res://prototypes/nine_pocket/gear_preview.gd")
const GEAR_PATH := "res://prototypes/nine_pocket/data/gear.json"
const SIZES: Array[String] = ["full", "half"]
const SIZE_NAMES := {"full": "Full (a whole bay)", "half": "Half (half a bay)"}
const LOOKS: Array[String] = ["", "faders", "knobs", "tube"]
const LOOK_NAMES := {"": "None", "faders": "Faders", "knobs": "Knobs and LEDs", "tube": "Glowing tube"}
const PARAM_INFO := {
	"points": ["Points", 0.0, 50.0, 1.0],
	"max": ["Maximum", 1.0, 20.0, 1.0],
	"mult": ["Multiplier", 1.0, 10.0, 0.5],
	"flow": ["Flow", 0.0, 10.0, 0.05],
	"cash": ["Cash ($)", 0.0, 50.0, 1.0],
	"step": ["Points per step", 0.0, 10.0, 1.0],
	"store": ["Flow stored per song", 0.0, 2.0, 0.05],
	"discards": ["Discards", 0.0, 5.0, 1.0],
	"count": ["Count", 1.0, 10.0, 1.0],
	"pays": ["Request pays", 10.0, 100.0, 5.0],
	"genre": ["Genre"],
	"decade": ["Decade"],
}
const WHENS: Array[String] = ["each", "first", "last", "gig_start", "gig_end"]
const WHEN_NAMES := {"each": "Each song", "first": "The opener", "last": "The closing song", "gig_start": "Start of the gig", "gig_end": "End of the gig"}
const REQUIRES: Array[String] = ["none", "prev_same_era", "prev2_same_genre", "last_matches_first", "adjacent", "streak", "match_back"]
const REQUIRE_NAMES := {"none": "Nothing", "prev_same_era": "The song before shares its decade", "prev2_same_genre": "The last two songs share a genre", "last_matches_first": "It shares a genre or decade with the opener", "adjacent": "A neighbor on either side is a genre", "streak": "It is every Nth song in a row of its genre", "match_back": "It shares its genre with the song N back"}
const APPLIES: Array[String] = ["any", "genre", "decade"]
const APPLIES_NAMES := {"any": "Any song", "genre": "Songs of a genre", "decade": "Songs of a decade"}
const EFFECTS: Array[String] = ["points", "mult", "flow", "cash", "discards"]
const EFFECT_NAMES := {"points": "Add points", "mult": "Multiply the score", "flow": "Raise flow", "cash": "Add cash", "discards": "Add discards"}
const PERS: Array[String] = ["none", "earlier_same_genre", "others_in_set", "units_left", "unused_discards"]
const PER_NAMES := {"none": "Nothing (once)", "earlier_same_genre": "Each earlier song of the same genre", "others_in_set": "Each other song of that genre in the set", "units_left": "Each unit to its left", "unused_discards": "Each unused discard"}
const UTILITY: Array[String] = ["cd_burner", "deep_library", "sneak_peek", "tuner", "audio", "gate", "request", "octave", "sax"]
const NOTES := {
	"genre_eq": "Random fader per genre, added to every song of that genre.",
	"decade_eq": "Random fader per decade, added to every song of that decade.",
	"cd_burner": "Button, once per gig: a Mix in your hand becomes a copy of an album in your hand.",
	"looper": "Multiplies the final song if it shares a genre or decade with slot 1.",
	"overdrive": "Adds points to every song.",
	"tube": "Adds 1 point per different genre in your hand of 8 to every song, up to the maximum.",
	"phaser": "Raises flow after a song when the song before has the same decade.",
	"tuner": "Gives extra discards each gig.",
	"noise": "Adds points to every song.",
	"fog": "Raises flow after the opener.",
	"delay": "When two songs of the same genre play back to back, the next song is multiplied.",
	"merch": "Pays cash when the show ends.",
	"tip_jar": "Pays cash for each unused discard when the show ends.",
	"tshirt": "Slot 3 earns no points and pays cash equal to its base points.",
	"octave": "Random pair: songs of the first genre also count as the second.",
	"sampler": "Random pair: songs of the first genre pay cash after the second.",
	"reverb": "Each song scores +1 per earlier song of the same genre, up to the maximum.",
	"audio": "Makes 'the song above' work in slots 1 to 3 (the mirrored slot).",
	"gate": "Ignores random hated tags each gig. Off when the boss has the hates ability.",
	"request": "Requests pay more.",
	"vintage": "Stores flow for every song of its decade you play, for the rest of the run.",
	"feedback": "Stores flow for every song of its genre you play, for the rest of the run.",
	"piggy": "The pot grows each gig. Pays out when sold or when you beat a boss.",
	"deep_library": "Button, once per gig: redraw your whole hand.",
	"sneak_peek": "Button, once per gig: look at the next songs in your binder.",
	"stack_amp": "Each song of its genre scores points for every other song of that genre in the set.",
	"turntables": "Raises flow after each song of its genre.",
	"radio": "Each song of its genre pays cash.",
	"sax": "Jazz songs count as any genre for their neighbors' conditions.",
	"splitter": "Duplicates the unit to its right.",
	"wah": "Raises flow after every song, for each unit to its left in the chain.",
}
const BG := Color("1b1d21")
const PANEL := Color("23272d")
const EDGE := Color("353a42")
const ACCENT := Color("6fa8dc")
const MUTED := Color("8d939b")
const TEXT := Color("e8ecf2")
const GOOD := Color("6aa84f")
const BAD := Color("e07a5f")

var units: Array = []
var sel := -1
var shown: Array[int] = []
var dirty := false
var loading := false
var filling := false
var lifts := {}
var preview: Node2D

var f_search: LineEdit
var flt_size: OptionButton
var flt_kind: OptionButton
var flt_state: OptionButton
var f_enabled: CheckBox
var list: ItemList
var count_label: Label
var f_id: LineEdit
var f_name: LineEdit
var f_text: TextEdit
var f_size: OptionButton
var f_price: SpinBox
var f_look: OptionButton
var f_kind: Label
var f_note: Label
var f_shown: Label
var params_grid: GridContainer
var param_widgets := {}
var rule_widgets := {}
var f_sentence: Label
var ppd: SpinBox
var tree: Tree
var warn_list: ItemList
var warn_units: Array[int] = []
var warn_badge: Label
var warn_badge_panel: PanelContainer
var status: Label
var confirm: ConfirmationDialog

func _sb(bg: Color, border: Color, radius: int = 4, pad: float = 6.0) -> StyleBoxFlat:
	var b := StyleBoxFlat.new()
	b.bg_color = bg
	b.border_color = border
	b.set_border_width_all(1)
	b.set_corner_radius_all(radius)
	b.content_margin_left = pad + 4.0
	b.content_margin_right = pad + 4.0
	b.content_margin_top = pad
	b.content_margin_bottom = pad
	return b

func _make_theme() -> Theme:
	var t := Theme.new()
	t.default_font_size = 15
	for cls in ["Button", "OptionButton", "MenuButton"]:
		t.set_stylebox("normal", cls, _sb(Color("30343b"), Color("454b55")))
		t.set_stylebox("hover", cls, _sb(Color("3b4048"), Color("7a808a")))
		t.set_stylebox("pressed", cls, _sb(Color("282b31"), Color("9aa0a8")))
		t.set_stylebox("disabled", cls, _sb(Color("272a30"), Color("353a42")))
		t.set_stylebox("focus", cls, _sb(Color(0, 0, 0, 0), ACCENT))
		t.set_color("font_color", cls, TEXT)
		t.set_color("font_hover_color", cls, Color.WHITE)
		t.set_color("font_pressed_color", cls, Color.WHITE)
		t.set_color("font_disabled_color", cls, Color("6a6f77"))
	for cls in ["LineEdit", "TextEdit"]:
		t.set_stylebox("normal", cls, _sb(Color("18191d"), EDGE))
		t.set_stylebox("read_only", cls, _sb(Color("1e2024"), Color("2b2e34")))
		t.set_stylebox("focus", cls, _sb(Color("18191d"), ACCENT))
		t.set_color("font_color", cls, TEXT)
		t.set_color("font_uneditable_color", cls, MUTED)
		t.set_color("caret_color", cls, Color.WHITE)
	for cls in ["ItemList", "Tree"]:
		t.set_stylebox("panel", cls, _sb(Color("18191d"), EDGE))
		t.set_stylebox("focus", cls, _sb(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))
		t.set_stylebox("selected", cls, _sb(Color("2d4a66"), ACCENT))
		t.set_stylebox("selected_focus", cls, _sb(Color("2d4a66"), ACCENT))
		t.set_color("font_color", cls, TEXT)
		t.set_color("font_selected_color", cls, Color.WHITE)
	t.set_color("title_button_color", "Tree", ACCENT)
	t.set_color("font_color", "Label", TEXT)
	t.set_color("font_color", "CheckBox", TEXT)
	return t

func _ready() -> void:
	theme = _make_theme()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_load_units()
	_run_balance()
	_refresh_all()

func _unhandled_key_input(ev: InputEvent) -> void:
	var k := ev as InputEventKey
	if k != null and k.pressed and k.ctrl_pressed and k.keycode == KEY_S:
		_save()
		get_viewport().set_input_as_handled()

func _label(t: String, col: Color = TEXT, size: int = 0) -> Label:
	var l := Label.new()
	l.text = t
	l.add_theme_color_override("font_color", col)
	if size > 0:
		l.add_theme_font_size_override("font_size", size)
	return l

func _opt(items: Array, with_all: String = "") -> OptionButton:
	var o := OptionButton.new()
	if with_all != "":
		o.add_item(with_all)
	for it in items:
		o.add_item(String(it))
	return o

func _named(keys: Array, names: Dictionary) -> Array:
	var out: Array = []
	for k in keys:
		out.append(names[k])
	return out

func _button(t: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = t
	b.pressed.connect(cb)
	return b

func _box(child_parent: Node, bg: Color = PANEL, pad: float = 12.0) -> VBoxContainer:
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", _sb(bg, EDGE, 8, pad))
	child_parent.add_child(pc)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	pc.add_child(v)
	return v

func _section(parent: Control, title: String) -> GridContainer:
	parent.add_child(_label(title.to_upper(), ACCENT, 14))
	parent.add_child(HSeparator.new())
	var g := GridContainer.new()
	g.columns = 2
	g.add_theme_constant_override("h_separation", 12)
	g.add_theme_constant_override("v_separation", 8)
	parent.add_child(g)
	return g

func _row(grid: GridContainer, label: String, w: Control) -> void:
	var l := _label(label, Color("a8afb8"), 14)
	l.custom_minimum_size = Vector2(130.0, 0.0)
	grid.add_child(l)
	w.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_child(w)

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	add_child(margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 12)
	top.add_child(_label("GEAR WORKSHOP", TEXT, 20))
	warn_badge_panel = PanelContainer.new()
	warn_badge_panel.add_theme_stylebox_override("panel", _sb(Color("3a3d42"), Color("3a3d42"), 10, 2.0))
	warn_badge = _label("", Color.WHITE, 13)
	warn_badge_panel.add_child(warn_badge)
	top.add_child(warn_badge_panel)
	status = _label("", Color("a8afb8"), 14)
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top.add_child(status)
	top.add_child(_button("Run balance test", _on_run_balance))
	top.add_child(_button("Reload from disk", _on_reload))
	var save := _button("Save  (Ctrl+S)", _save)
	save.add_theme_stylebox_override("normal", _sb(Color("2f7d4f"), Color("43a06a")))
	save.add_theme_stylebox_override("hover", _sb(Color("379259"), Color("5cc084")))
	save.add_theme_stylebox_override("pressed", _sb(Color("286b44"), Color("43a06a")))
	top.add_child(save)
	root.add_child(top)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	root.add_child(body)

	var left_box := _box(body)
	left_box.get_parent().custom_minimum_size = Vector2(340.0, 0.0)
	left_box.get_parent().size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var lh := HBoxContainer.new()
	lh.add_child(_label("LIBRARY", ACCENT, 13))
	count_label = _label("", Color("a8afb8"), 13)
	count_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lh.add_child(count_label)
	left_box.add_child(lh)
	f_search = LineEdit.new()
	f_search.placeholder_text = "Search name or text"
	f_search.clear_button_enabled = true
	f_search.text_changed.connect(func(_t: String) -> void: _refresh_list())
	left_box.add_child(f_search)
	var filters := HBoxContainer.new()
	filters.add_theme_constant_override("separation", 6)
	flt_size = _opt(_named(SIZES, SIZE_NAMES), "All sizes")
	flt_kind = _opt(["Active", "Passive"], "All kinds")
	flt_state = _opt(["Enabled", "Disabled"], "All states")
	for o: OptionButton in [flt_size, flt_kind, flt_state]:
		o.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		o.item_selected.connect(func(_i: int) -> void: _refresh_list())
		filters.add_child(o)
	left_box.add_child(filters)
	list = ItemList.new()
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list.item_selected.connect(_on_list_selected)
	left_box.add_child(list)
	var lb := HBoxContainer.new()
	lb.add_theme_constant_override("separation", 6)
	lb.add_child(_button("New unit", _on_new))
	lb.add_child(_button("Duplicate", _on_duplicate))
	lb.add_child(_button("Delete", _on_delete))
	left_box.add_child(lb)
	confirm = ConfirmationDialog.new()
	confirm.confirmed.connect(_delete_selected)
	add_child(confirm)

	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 10)
	body.add_child(center)
	var svc := SubViewportContainer.new()
	svc.stretch = true
	svc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	svc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	svc.custom_minimum_size = Vector2(520.0, 420.0)
	var vp := SubViewport.new()
	svc.add_child(vp)
	preview = Node2D.new()
	preview.set_script(PREVIEW)
	vp.add_child(preview)
	center.add_child(svc)
	var sum := _box(center)
	sum.add_child(_label("ON THE UNIT", ACCENT, 13))
	f_shown = _label("", TEXT, 15)
	f_shown.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sum.add_child(f_shown)

	var right_box := _box(body)
	right_box.get_parent().custom_minimum_size = Vector2(460.0, 0.0)
	right_box.get_parent().size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right_box.add_child(scroll)
	var insp := VBoxContainer.new()
	insp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	insp.add_theme_constant_override("separation", 10)
	scroll.add_child(insp)

	var g1 := _section(insp, "Identity")
	f_id = LineEdit.new()
	f_id.editable = false
	_row(g1, "ID", f_id)
	f_name = LineEdit.new()
	f_name.text_changed.connect(_on_edit)
	_row(g1, "Name", f_name)
	f_enabled = CheckBox.new()
	f_enabled.text = "Appears in the game (untick to keep it as a draft)"
	f_enabled.toggled.connect(_on_edit)
	_row(g1, "Enabled", f_enabled)
	f_kind = _label("", MUTED, 14)
	_row(g1, "Kind", f_kind)
	f_note = _label("", Color("a8afb8"), 13)
	f_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	insp.add_child(f_note)

	var g2 := _section(insp, "Text on the unit")
	f_text = TextEdit.new()
	f_text.custom_minimum_size = Vector2(0.0, 90.0)
	f_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	f_text.text_changed.connect(_on_edit)
	_row(g2, "Text", f_text)
	insp.add_child(_label("Write {name} where a number below should appear, for example +{points} points.", MUTED, 12))

	var g3 := _section(insp, "Numbers and rule")
	params_grid = g3

	var g4 := _section(insp, "Shop and look")
	f_size = _opt(_named(SIZES, SIZE_NAMES))
	f_size.item_selected.connect(_on_edit)
	_row(g4, "Bay size", f_size)
	f_price = SpinBox.new()
	f_price.min_value = 1
	f_price.max_value = 30
	f_price.value_changed.connect(_on_edit)
	_row(g4, "Price ($)", f_price)
	f_look = _opt(_named(LOOKS, LOOK_NAMES))
	f_look.item_selected.connect(_on_edit)
	_row(g4, "Panel look", f_look)

	var dock := HBoxContainer.new()
	dock.custom_minimum_size = Vector2(0.0, 270.0)
	dock.add_theme_constant_override("separation", 14)
	root.add_child(dock)
	var bal := _box(dock)
	bal.get_parent().size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var bh := HBoxContainer.new()
	bh.add_theme_constant_override("separation", 10)
	bh.add_child(_label("BALANCE TEST", ACCENT, 13))
	bh.add_child(_label("Each unit alone on 60 random hands from the card catalog. $1 is worth", MUTED, 13))
	ppd = SpinBox.new()
	ppd.min_value = 0
	ppd.max_value = 20
	ppd.value = 3
	ppd.value_changed.connect(func(_v: float) -> void: _fill_tree(); _refresh_warnings())
	bh.add_child(ppd)
	bh.add_child(_label("points", MUTED, 13))
	bal.add_child(bh)
	tree = Tree.new()
	tree.columns = 7
	tree.hide_root = true
	tree.column_titles_visible = true
	tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var heads := ["Unit", "Bay", "Price", "Points lift", "Cash per gig", "Value", "Value per $"]
	for i in heads.size():
		tree.set_column_title(i, heads[i])
		tree.set_column_expand(i, i == 0)
		tree.set_column_custom_minimum_width(i, 70 if i > 0 else 150)
	tree.item_selected.connect(_on_tree_selected)
	bal.add_child(tree)
	var chk := _box(dock)
	chk.get_parent().custom_minimum_size = Vector2(420.0, 0.0)
	chk.add_child(_label("CHECKS", ACCENT, 13))
	warn_list = ItemList.new()
	warn_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	warn_list.item_selected.connect(_on_warning_clicked)
	chk.add_child(warn_list)

func _say(t: String) -> void:
	status.text = t

func _set_dirty(v: bool) -> void:
	dirty = v
	_say("Unsaved changes" if v else status.text)

func _load_units() -> void:
	units.clear()
	if FileAccess.file_exists(GEAR_PATH):
		var data = JSON.parse_string(FileAccess.get_file_as_string(GEAR_PATH))
		if data is Array:
			for u in data:
				units.append(u)
	preview.gear_defs.clear()
	for u: Dictionary in units:
		preview.gear_defs[String(u["id"])] = u
	sel = 0 if not units.is_empty() else -1
	dirty = false
	_say("Loaded %d units" % units.size())

func _clean(v):
	if v is Dictionary:
		var out := {}
		for k in v.keys():
			out[k] = _clean(v[k])
		return out
	if v is Array:
		return v.map(func(x): return _clean(x))
	if v is float and is_equal_approx(v, roundf(v)):
		return int(v)
	return v

func _save() -> void:
	_read_form()
	var f := FileAccess.open(GEAR_PATH, FileAccess.WRITE)
	if f == null:
		_say("Could not write %s" % GEAR_PATH)
		return
	var rx := RegEx.new()
	rx.compile("\\{\\s*\\}")
	f.store_string(rx.sub(JSON.stringify(_clean(units), "\t", false), "{}", true) + "\n")
	f.close()
	dirty = false
	_say("Saved %d units" % units.size())

func _on_reload() -> void:
	_load_units()
	_run_balance()
	_refresh_all()

func _on_run_balance() -> void:
	_run_balance()
	_fill_tree()
	_refresh_warnings()

func _run_balance() -> void:
	var ids: Array = []
	for u: Dictionary in units:
		ids.append(String(u["id"]))
	lifts = preview.lift(ids, 60)
	_fill_tree()

func _refresh_all() -> void:
	_refresh_list()
	_load_form()
	_fill_tree()
	_refresh_warnings()

func _slug(t: String) -> String:
	var out := ""
	for ch in t.to_lower():
		out += ch if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9") else "_"
	while out.contains("__"):
		out = out.replace("__", "_")
	out = out.strip_edges().trim_prefix("_").trim_suffix("_")
	return out if out != "" else "unit"

func _unique_id(name: String) -> String:
	var base := _slug(name)
	var id := base
	var n := 2
	while preview.gear_defs.has(id):
		id = "%s_%d" % [base, n]
		n += 1
	return id

func _kit_uses(id: String) -> String:
	for kit: Dictionary in D.KITS:
		if String(kit["gear"]) == id:
			return String(kit["name"])
	return ""

func _add_unit(u: Dictionary) -> void:
	units.append(u)
	preview.gear_defs[String(u["id"])] = u
	f_search.text = ""
	flt_size.select(0)
	flt_kind.select(0)
	flt_state.select(0)
	sel = units.size() - 1
	_set_dirty(true)
	_refresh_list()
	_load_form()
	_refresh_one()
	f_name.grab_focus()
	f_name.select_all()

func _on_new() -> void:
	_read_form()
	var name := "New unit"
	_add_unit({
		"id": _unique_id(name),
		"name": name,
		"text": "+{amount} points per song.",
		"enabled": false,
		"size": "half",
		"price": 5,
		"look": "",
		"active": false,
		"params": {},
		"rule": {"when": "each", "requires": "none", "rparam": "", "rn": 0, "applies": "any", "aparam": "", "effect": "points", "amount": 3, "per": "none", "cap": 0, "label": "New"},
	})
	_say("Added a new unit. Name it, then set its rule.")

func _on_duplicate() -> void:
	if sel < 0 or sel >= units.size():
		return
	_read_form()
	var src: Dictionary = units[sel]
	if not src.has("rule"):
		_say("%s has behavior written in code, so it can't be duplicated. Duplicate a rule unit instead." % src["name"])
		return
	var u: Dictionary = (src as Dictionary).duplicate(true)
	u["name"] = "%s copy" % src["name"]
	u["id"] = _unique_id(String(u["name"]))
	u["enabled"] = false
	_add_unit(u)
	_say("Duplicated %s." % src["name"])

func _on_delete() -> void:
	if sel < 0 or sel >= units.size():
		return
	var u: Dictionary = units[sel]
	var kit := _kit_uses(String(u["id"]))
	if kit != "":
		_say("The %s kit starts with %s. Change the kit before deleting it." % [kit, u["name"]])
		return
	confirm.dialog_text = "Delete %s? This removes it from the game when you save." % u["name"]
	confirm.popup_centered()

func _delete_selected() -> void:
	if sel < 0 or sel >= units.size():
		return
	var id := String(units[sel]["id"])
	var nm := String(units[sel]["name"])
	units.remove_at(sel)
	preview.gear_defs.erase(id)
	lifts.erase(id)
	sel = mini(sel, units.size() - 1)
	_set_dirty(true)
	_refresh_all()
	_say("Deleted %s." % nm)

func _is_active(u: Dictionary) -> bool:
	return bool(u.get("active", false))

func _is_enabled(u: Dictionary) -> bool:
	return bool(u.get("enabled", true))

func _row_text(u: Dictionary) -> String:
	var t := "%s   ·   %s   ·   $%d" % [u["name"], String(u["size"]).capitalize(), int(u["price"])]
	return t if _is_enabled(u) else "(draft)  " + t

func _refresh_list() -> void:
	var q := f_search.text.strip_edges().to_lower()
	list.clear()
	shown.clear()
	for i in units.size():
		var u: Dictionary = units[i]
		if q != "" and not (String(u["name"]).to_lower().contains(q) or String(u["text"]).to_lower().contains(q)):
			continue
		if flt_size.selected > 0 and String(u["size"]) != SIZES[flt_size.selected - 1]:
			continue
		if flt_kind.selected == 1 and not _is_active(u):
			continue
		if flt_kind.selected == 2 and _is_active(u):
			continue
		if flt_state.selected == 1 and not _is_enabled(u):
			continue
		if flt_state.selected == 2 and _is_enabled(u):
			continue
		shown.append(i)
		list.add_item(_row_text(u))
		if i == sel:
			list.select(list.item_count - 1)
	count_label.text = "%d of %d" % [shown.size(), units.size()]

func _on_list_selected(idx: int) -> void:
	_read_form()
	sel = shown[idx]
	_load_form()
	_refresh_warnings()

func _on_tree_selected() -> void:
	if filling:
		return
	var it := tree.get_selected()
	if it == null:
		return
	_read_form()
	sel = int(it.get_metadata(0))
	_refresh_list()
	_load_form()

func _on_warning_clicked(idx: int) -> void:
	if idx < warn_units.size() and warn_units[idx] >= 0:
		_read_form()
		sel = warn_units[idx]
		_refresh_list()
		_load_form()

func _clear_params() -> void:
	var kids := params_grid.get_children()
	for c in kids:
		params_grid.remove_child(c)
		c.queue_free()
	param_widgets.clear()
	rule_widgets.clear()

func _load_form() -> void:
	loading = true
	_clear_params()
	if sel < 0 or sel >= units.size():
		f_id.text = ""
		f_name.text = ""
		f_text.text = ""
		preview.show_unit("")
		loading = false
		return
	var u: Dictionary = units[sel]
	f_id.text = String(u["id"])
	f_name.text = String(u["name"])
	f_enabled.button_pressed = _is_enabled(u)
	f_text.text = String(u["text"])
	f_kind.text = "Active (has a USE button)" if _is_active(u) else "Passive"
	f_note.text = ("Built from a rule, set under Numbers and rule." if u.has("rule") else "Behavior (set in code): " + String(NOTES.get(String(u["id"]), "")))
	f_size.select(SIZES.find(String(u["size"])))
	f_price.value = float(u["price"])
	f_look.select(maxi(0, LOOKS.find(String(u["look"]))))
	var params: Dictionary = u["params"]
	if u.has("rule"):
		_build_rule_rows(u["rule"])
	elif params.is_empty():
		params_grid.add_child(_label("This unit has no numbers to set.", MUTED, 13))
		params_grid.add_child(Control.new())
	for key in params.keys():
		var info: Array = PARAM_INFO.get(String(key), [String(key).capitalize(), 0.0, 100.0, 1.0])
		var w: Control
		if String(key) == "genre" or String(key) == "decade":
			var o := _opt(D.GENRES if String(key) == "genre" else D.ERAS)
			var arr: Array = D.GENRES if String(key) == "genre" else D.ERAS
			o.select(maxi(0, arr.find(String(params[key]))))
			o.item_selected.connect(_on_edit)
			w = o
		else:
			var sb := SpinBox.new()
			sb.min_value = float(info[1])
			sb.max_value = float(info[2])
			sb.step = float(info[3])
			sb.value = float(params[key])
			sb.value_changed.connect(_on_edit)
			w = sb
		var l := _label(String(info[0]) + "  {" + String(key) + "}", Color("a8afb8"), 14)
		l.custom_minimum_size = Vector2(130.0, 0.0)
		params_grid.add_child(l)
		w.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		params_grid.add_child(w)
		param_widgets[String(key)] = w
	loading = false
	_update_sentence()
	_update_preview()

func _add_row(label: String, w: Control) -> void:
	var l := _label(label, Color("a8afb8"), 14)
	l.custom_minimum_size = Vector2(130.0, 0.0)
	params_grid.add_child(l)
	w.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	params_grid.add_child(w)

func _rule_opt(keys: Array, names: Dictionary, cur: String) -> OptionButton:
	var o := _opt(_named(keys, names))
	o.select(maxi(0, keys.find(cur)))
	o.item_selected.connect(_on_rule_changed)
	return o

func _fill_aparam(applies: String, cur: String) -> void:
	var o: OptionButton = rule_widgets["aparam"]
	o.clear()
	var arr: Array = D.GENRES if applies == "genre" else (D.ERAS if applies == "decade" else [])
	for it in arr:
		o.add_item(String(it))
	o.disabled = arr.is_empty()
	if not arr.is_empty():
		o.select(maxi(0, arr.find(cur)))

func _build_rule_rows(r: Dictionary) -> void:
	rule_widgets["when"] = _rule_opt(WHENS, WHEN_NAMES, String(r["when"]))
	_add_row("When", rule_widgets["when"])
	rule_widgets["applies"] = _rule_opt(APPLIES, APPLIES_NAMES, String(r["applies"]))
	_add_row("Fires for", rule_widgets["applies"])
	rule_widgets["aparam"] = OptionButton.new()
	rule_widgets["aparam"].item_selected.connect(_on_rule_changed)
	_add_row("  which one  {aparam}", rule_widgets["aparam"])
	_fill_aparam(String(r["applies"]), String(r["aparam"]))
	rule_widgets["requires"] = _rule_opt(REQUIRES, REQUIRE_NAMES, String(r["requires"]))
	_add_row("Only if", rule_widgets["requires"])
	rule_widgets["rparam"] = _opt(D.GENRES)
	rule_widgets["rparam"].select(maxi(0, D.GENRES.find(String(r.get("rparam", "")))))
	rule_widgets["rparam"].item_selected.connect(_on_rule_changed)
	_add_row("  which genre  {rparam}", rule_widgets["rparam"])
	var rn := SpinBox.new()
	rn.min_value = 1.0
	rn.max_value = 6.0
	rn.step = 1.0
	rn.value = maxf(1.0, float(r.get("rn", 2)))
	rn.value_changed.connect(_on_edit)
	rule_widgets["rn"] = rn
	_add_row("  N  {rn}", rn)
	_sync_condition_rows()
	rule_widgets["effect"] = _rule_opt(EFFECTS, EFFECT_NAMES, String(r["effect"]))
	_add_row("Effect", rule_widgets["effect"])
	var amt := SpinBox.new()
	amt.min_value = 0.0
	amt.max_value = 100.0
	amt.step = 0.05
	amt.value = float(r["amount"])
	amt.value_changed.connect(_on_edit)
	rule_widgets["amount"] = amt
	_add_row("Amount  {amount}", amt)
	rule_widgets["per"] = _rule_opt(PERS, PER_NAMES, String(r["per"]))
	_add_row("Multiplied by", rule_widgets["per"])
	var cap := SpinBox.new()
	cap.min_value = 0.0
	cap.max_value = 20.0
	cap.step = 1.0
	cap.value = float(r["cap"])
	cap.value_changed.connect(_on_edit)
	rule_widgets["cap"] = cap
	_add_row("Count limit  {cap}  (0 = none)", cap)
	var lab := LineEdit.new()
	lab.text = String(r["label"])
	lab.text_changed.connect(_on_edit)
	rule_widgets["label"] = lab
	_add_row("Label on the song", lab)
	f_sentence = _label("", Color("a8afb8"), 13)
	f_sentence.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_add_row("Reads as", f_sentence)

func _sync_condition_rows() -> void:
	var req: String = REQUIRES[(rule_widgets["requires"] as OptionButton).selected]
	(rule_widgets["rparam"] as OptionButton).disabled = req != "adjacent"
	(rule_widgets["rn"] as SpinBox).editable = req in ["streak", "match_back"]

func _sentence(r: Dictionary) -> String:
	var who := "any song"
	if String(r["applies"]) != "any" and String(r["aparam"]) != "":
		who = "%s songs" % r["aparam"]
	var when := String(r["when"])
	var when_text: String = {"each": "", "first": " as the opener", "last": " as the closing song", "gig_start": " at the start of the gig", "gig_end": " at the end of the gig"}[when]
	var cond := ""
	var n := int(r.get("rn", 2))
	match String(r["requires"]):
		"prev_same_era":
			cond = " if the song before shares its decade"
		"prev2_same_genre":
			cond = " if the last two songs share a genre"
		"last_matches_first":
			cond = " if it shares a genre or decade with the opener"
		"adjacent":
			cond = " if adjacent to a %s song" % String(r.get("rparam", ""))
		"streak":
			cond = " if it is every %s song in a row of its genre" % _ordinal(n)
		"match_back":
			cond = " if it shares its genre with the song %d back" % n
	var amt := float(r["amount"])
	var amt_text: String = preview._ff(amt)
	var eff: String = {"points": "+%s points", "mult": "x%s", "flow": "+%s flow", "cash": "+$%s", "discards": "+%s discards"}[String(r["effect"])] % amt_text
	var per := String(r["per"])
	if per != "none":
		eff += " for " + String(PER_NAMES[per]).to_lower()
	if when == "gig_start" or when == "gig_end":
		var lead := when_text.trim_prefix(" ")
		return "%s%s: %s." % [lead.left(1).to_upper(), lead.substr(1), eff]
	return "Fires for %s%s%s: %s." % [who, when_text, cond, eff]

func _ordinal(n: int) -> String:
	return "%d%s" % [n, "th" if n % 100 in [11, 12, 13] else {1: "st", 2: "nd", 3: "rd"}.get(n % 10, "th")]

func _update_sentence() -> void:
	if f_sentence == null or rule_widgets.is_empty() or sel < 0 or sel >= units.size() or not units[sel].has("rule"):
		return
	f_sentence.text = _sentence(units[sel]["rule"])

func _on_rule_changed(_i: int) -> void:
	if loading:
		return
	_sync_condition_rows()
	var applies: String = APPLIES[(rule_widgets["applies"] as OptionButton).selected]
	var o: OptionButton = rule_widgets["aparam"]
	var cur := o.get_item_text(o.selected) if o.item_count > 0 and o.selected >= 0 else ""
	loading = true
	_fill_aparam(applies, cur)
	loading = false
	_on_edit()

func _read_form() -> void:
	if loading or sel < 0 or sel >= units.size():
		return
	var u: Dictionary = units[sel]
	u["name"] = f_name.text
	u["enabled"] = f_enabled.button_pressed
	u["text"] = f_text.text
	u["size"] = SIZES[f_size.selected]
	u["price"] = int(f_price.value)
	u["look"] = LOOKS[f_look.selected]
	if u.has("rule") and not rule_widgets.is_empty():
		var r: Dictionary = u["rule"]
		r["when"] = WHENS[(rule_widgets["when"] as OptionButton).selected]
		r["requires"] = REQUIRES[(rule_widgets["requires"] as OptionButton).selected]
		var ro: OptionButton = rule_widgets["rparam"]
		r["rparam"] = ro.get_item_text(ro.selected) if r["requires"] == "adjacent" else ""
		r["rn"] = int((rule_widgets["rn"] as SpinBox).value) if r["requires"] in ["streak", "match_back"] else 0
		r["applies"] = APPLIES[(rule_widgets["applies"] as OptionButton).selected]
		var ao: OptionButton = rule_widgets["aparam"]
		r["aparam"] = "" if String(r["applies"]) == "any" or ao.item_count == 0 else ao.get_item_text(ao.selected)
		r["effect"] = EFFECTS[(rule_widgets["effect"] as OptionButton).selected]
		r["amount"] = (rule_widgets["amount"] as SpinBox).value
		r["per"] = PERS[(rule_widgets["per"] as OptionButton).selected]
		r["cap"] = int((rule_widgets["cap"] as SpinBox).value)
		r["label"] = (rule_widgets["label"] as LineEdit).text
	var params: Dictionary = u["params"]
	for key in param_widgets.keys():
		var w: Control = param_widgets[key]
		if w is OptionButton:
			params[key] = (w as OptionButton).get_item_text((w as OptionButton).selected)
		else:
			params[key] = (w as SpinBox).value

func _on_edit(_v = null) -> void:
	if loading:
		return
	_read_form()
	_update_sentence()
	_set_dirty(true)
	_update_preview()
	_refresh_one()

func _refresh_one() -> void:
	var id := String(units[sel]["id"])
	var r: Dictionary = preview.lift([id], 40)
	lifts[id] = r[id]
	_fill_tree()
	_refresh_warnings()
	var row := shown.find(sel)
	if row >= 0:
		list.set_item_text(row, _row_text(units[sel]))
	if flt_state.selected > 0:
		_refresh_list()

func _update_preview() -> void:
	if sel < 0 or sel >= units.size():
		return
	var u: Dictionary = units[sel]
	preview.show_unit(String(u["id"]))
	f_shown.text = preview._gear_fmt(u)

func _gig_cash(u: Dictionary) -> float:
	var p: Dictionary = u["params"]
	var r: Dictionary = u.get("rule", {})
	if not r.is_empty():
		if String(r["when"]) == "gig_end" and String(r["effect"]) == "cash":
			return float(r["amount"]) * (2.0 if String(r["per"]) == "unused_discards" else 1.0)
		return 0.0
	if String(u["id"]) == "piggy":
		return float(p.get("cash", 0.0))
	return 0.0

func _value(id: String, u: Dictionary) -> float:
	var l: Dictionary = lifts.get(id, {"points": 0.0, "cash": 0.0})
	return float(l["points"]) + (float(l["cash"]) + _gig_cash(u)) * ppd.value

func _ratio(u: Dictionary) -> float:
	return _value(String(u["id"]), u) / maxf(1.0, float(u["price"]))

func _median_ratio() -> float:
	var rs: Array = []
	for u: Dictionary in units:
		if not String(u["id"]) in UTILITY and _value(String(u["id"]), u) > 0.0:
			rs.append(_ratio(u))
	if rs.is_empty():
		return 0.0
	rs.sort()
	return float(rs[rs.size() / 2])

func _fill_tree() -> void:
	if tree == null:
		return
	filling = true
	tree.clear()
	var root := tree.create_item()
	var med := _median_ratio()
	for i in units.size():
		var u: Dictionary = units[i]
		var id := String(u["id"])
		var l: Dictionary = lifts.get(id, {"points": 0.0, "cash": 0.0})
		var util := id in UTILITY
		var it := tree.create_item(root)
		it.set_metadata(0, i)
		it.set_text(0, String(u["name"]))
		it.set_text(1, String(u["size"]).capitalize())
		it.set_text(2, "$%d" % int(u["price"]))
		it.set_text(3, "utility" if util else "%+.1f" % float(l["points"]))
		it.set_text(4, "%.1f" % (float(l["cash"]) + _gig_cash(u)))
		it.set_text(5, "-" if util else "%.1f" % _value(id, u))
		it.set_text(6, "-" if util else "%.2f" % _ratio(u))
		for c in 7:
			it.set_text_alignment(c, HORIZONTAL_ALIGNMENT_LEFT if c < 2 else HORIZONTAL_ALIGNMENT_RIGHT)
		if not util and med > 0.0:
			var r := _ratio(u)
			var col := TEXT
			if r > med * 2.0:
				col = BAD
			elif r < med * 0.5:
				col = Color("e6c24a")
			it.set_custom_color(6, col)
		if i == sel:
			it.select(0)
	filling = false

func _placeholders(t: String) -> Array:
	var out: Array = []
	var rx := RegEx.new()
	rx.compile("\\{(\\w+)\\}")
	for m in rx.search_all(t):
		out.append(m.get_string(1))
	return out

func _validate() -> Array:
	var out: Array = []
	var names := {}
	var med := _median_ratio()
	var genres_with_cards := {}
	if preview.albums.size() > 0:
		for a: Dictionary in preview.albums:
			genres_with_cards[D.GENRES[int(a["genre"])]] = true
	for i in units.size():
		var u: Dictionary = units[i]
		var nm := String(u["name"]).strip_edges()
		var id := String(u["id"])
		if not _is_enabled(u) and _kit_uses(id) != "":
			out.append({"text": "%s: disabled, but the %s kit starts with it" % [nm, _kit_uses(id)], "idx": i})
		if nm == "":
			out.append({"text": "%s has no name" % id, "idx": i})
		elif names.has(nm.to_lower()):
			out.append({"text": "%s has the same name as another unit" % nm, "idx": i})
		names[nm.to_lower()] = true
		var params: Dictionary = u["params"]
		var rule: Dictionary = u.get("rule", {})
		var used := _placeholders(String(u["text"]))
		for ph in used:
			if not params.has(ph) and not (not rule.is_empty() and ph in ["amount", "cap", "aparam", "rparam", "rn"]):
				out.append({"text": "%s: text uses {%s} but the unit has no such number" % [nm, ph], "idx": i})
		if not rule.is_empty():
			for pr in _rule_problems(u):
				out.append({"text": "%s: %s" % [nm, pr], "idx": i})
			if not "amount" in used:
				out.append({"text": "%s: the amount is not shown in the text" % nm, "idx": i})
			if String(rule.get("requires", "")) == "adjacent" and not "rparam" in used:
				out.append({"text": "%s: the neighbor genre is not shown in the text" % nm, "idx": i})
			if String(rule.get("requires", "")) in ["streak", "match_back"] and not "rn" in used:
				out.append({"text": "%s: the number N is not shown in the text" % nm, "idx": i})
			if int(rule["cap"]) > 0 and not "cap" in used:
				out.append({"text": "%s: the count limit is not shown in the text" % nm, "idx": i})
		for key in params.keys():
			if not key in used and key != "genre" and key != "decade":
				out.append({"text": "%s: the number %s is not shown in the text" % [nm, key], "idx": i})
		var shown_text: String = preview._gear_fmt(u)
		if String(u["size"]) == "half" and shown_text.length() > 100:
			out.append({"text": "%s: text may overflow a Half unit (%d characters, about 100 fit)" % [nm, shown_text.length()], "idx": i})
		if String(u["size"]) == "half" and nm.length() > 16:
			out.append({"text": "%s: a long name shrinks to fit a Half unit" % nm, "idx": i})
		if String(u["size"]) == "full" and String(u["look"]) == "":
			out.append({"text": "%s: a Full unit has no panel look, so its right side is blank" % nm, "idx": i})
		var wanted: Array = []
		for key in ["genre"]:
			if params.has(key):
				wanted.append(String(params[key]))
		if not rule.is_empty():
			if String(rule["applies"]) == "genre":
				wanted.append(String(rule["aparam"]))
			if String(rule.get("requires", "")) == "adjacent":
				wanted.append(String(rule.get("rparam", "")))
		for gname: String in wanted:
			if gname != "" and not genres_with_cards.has(gname):
				out.append({"text": "%s: the catalog has no %s cards yet, so its lift is 0" % [nm, gname], "idx": i})
		if not id in UTILITY and med > 0.0:
			var r := _ratio(u)
			if r > med * 2.0:
				out.append({"text": "%s: value per $ is %.1fx the median (strong for its price)" % [nm, r / med], "idx": i})
			elif r < med * 0.5 and _value(id, u) > 0.0:
				out.append({"text": "%s: value per $ is %.1fx the median (weak for its price)" % [nm, r / med], "idx": i})
			elif _value(id, u) <= 0.0:
				out.append({"text": "%s: no measured value in the test hands" % nm, "idx": i})
	return out

func _rule_problems(u: Dictionary) -> Array:
	var r: Dictionary = u["rule"]
	var out: Array = []
	var when := String(r["when"])
	var eff := String(r["effect"])
	var gig := when == "gig_start" or when == "gig_end"
	if when == "gig_start" and not eff in ["discards", "cash"]:
		out.append("at the start of a gig a rule can only add discards or cash")
	elif when == "gig_end" and eff != "cash":
		out.append("at the end of a gig a rule can only add cash")
	elif not gig and eff == "discards":
		out.append("adding discards only works at the start of a gig")
	if eff == "mult" and float(r["amount"]) < 1.0:
		out.append("a multiplier below 1 makes songs score less")
	if String(r["per"]) == "unused_discards" and when != "gig_end":
		out.append("'each unused discard' only works at the end of a gig")
	if gig and String(r["per"]) in ["earlier_same_genre", "others_in_set", "units_left"]:
		out.append("that scaling needs songs, so it only works on song rules")
	if gig and (String(r["requires"]) != "none" or String(r["applies"]) != "any"):
		out.append("'only if' and 'fires for' are ignored at the start or end of a gig")
	if String(r["applies"]) != "any" and String(r["aparam"]) == "":
		out.append("pick which genre or decade it fires for")
	if String(r["requires"]) == "adjacent" and String(r.get("rparam", "")) == "":
		out.append("pick the neighbor genre")
	if String(r["requires"]) == "streak" and int(r.get("rn", 0)) < 2:
		out.append("a run needs N of at least 2")
	if String(r["requires"]) == "match_back" and int(r.get("rn", 0)) < 1:
		out.append("pick how many songs back to look")
	if eff == "mult" and String(r["per"]) != "none":
		out.append("a multiplier ignores the scaling")
	if not gig and String(r["label"]).strip_edges() == "":
		out.append("the label shown on the song is empty")
	return out

func _refresh_warnings() -> void:
	var w: Array = _validate()
	warn_list.clear()
	warn_units.clear()
	for e: Dictionary in w:
		warn_list.add_item(String(e["text"]))
		warn_units.append(int(e["idx"]))
	if w.is_empty():
		warn_list.add_item("No problems found")
		warn_units.append(-1)
	warn_badge.text = "%d checks" % w.size() if not w.is_empty() else "all clear"
	warn_badge_panel.add_theme_stylebox_override("panel", _sb(Color("7a4a2a") if not w.is_empty() else Color("2f6b4f"), Color("3a3d42"), 10, 2.0))
