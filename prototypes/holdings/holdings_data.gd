class_name HoldingsData
extends RefCounted

const TYPES := ["cash", "labor", "equipment", "intel", "advertising"]
const TYPE_NAMES := {"cash": "Finance", "labor": "Services", "equipment": "Industry", "intel": "Tech", "advertising": "Consumer"}
const RES_NAMES := {"cash": "Cash", "labor": "Labor", "equipment": "Equipment", "intel": "Intelligence", "advertising": "Advertising"}
const TYPE_COLORS := {"cash": "4f8a5b", "labor": "4a7fb0", "equipment": "8a6d4b", "intel": "7a63b8", "advertising": "d0607a"}

const QUARTERS_PER_YEAR := 4
const YEAR_TARGETS := [20, 45, 80, 120, 165, 215, 270]

const STARTING_RESOURCES := {"cash": 4, "labor": 2, "equipment": 2, "intel": 2, "advertising": 2}

const COST_EXTRA := 1
const GATE_VALUE := 5
const GATE_RES := "equipment"
const COST_FILLER := {"cash": "labor"}
const DEFAULT_FILLER := "cash"

const LOCKED_LOTS := 3
const LOCK_PAY := 3
const STARTING_BOARD: Array[String] = []

const EVENT_TIERS := [
	{"until": 8, "tiers": ["mild"]},
	{"until": 16, "tiers": ["mild", "moderate"]},
	{"until": 999, "tiers": ["moderate", "severe"]},
]

const PATTERNS := {
	"odd": {"dice": 1, "label": "Odd", "short": "Odd", "rule": "1, 3 or 5"},
	"even": {"dice": 1, "label": "Even", "short": "Even", "rule": "2, 4 or 6"},
	"low": {"dice": 1, "label": "Low", "short": "1-3", "rule": "1-3"},
	"high": {"dice": 1, "label": "High", "short": "4-6", "rule": "4-6"},
	"exact": {"dice": 1, "label": "Exactly %d", "short": "%d", "rule": "equals %d"},
	"at_least": {"dice": 1, "label": "%d+", "short": "%d-6", "rule": "%d or higher"},
	"at_most": {"dice": 1, "label": "%d or less", "short": "1-%d", "rule": "%d or lower"},
	"any": {"dice": 1, "label": "Any", "short": "Any", "rule": "any die"},
	"pair": {"dice": 2, "label": "Pair", "short": "Pair", "rule": "two equal dice"},
	"sum_at_least": {"dice": 2, "label": "Sum %d+", "short": "Sum %d+", "rule": "two dice total %d+"},
	"sum_exactly": {"dice": 2, "label": "Sum = %d", "short": "Sum %d", "rule": "two dice total exactly %d"},
	"run": {"dice": 2, "label": "Run", "short": "Run", "rule": "two consecutive values"},
}

const RARITY_COPIES := {"common": 3, "uncommon": 2, "rare": 1}
const RARITY_COLORS := {"uncommon": "4a7fb0", "rare": "d9a13b"}

static var CARDS := {}

static var MEETING_OFFERS := {}
static var EDITIONS := {}
static var EDITION_OFFERS := {}

const POCKET_MODS := {
	"gold": {"name": "Gold", "color": "d9a13b"},
	"express": {"name": "Express", "color": "4a90d9"},
}

static var EVENTS := {}

const DATA_DIR := "res://prototypes/holdings/data/"
static var loaded := false

static func load_tables() -> void:
	if loaded:
		return
	loaded = true
	_load_cards()
	_load_events()
	_load_offers()
	var elog := _logic("editions", "text")
	for row: Dictionary in _rows("editions.csv"):
		var lg: Dictionary = elog.get(row["id"], {})
		EDITIONS[row["id"]] = {"name": row["name"], "text": row["text"], "color": String(lg.get("color", "888888"))}

static func _rows(file: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var f := FileAccess.open(DATA_DIR + file, FileAccess.READ)
	if f == null:
		push_error("Holdings: can't open %s" % (DATA_DIR + file))
		return out
	var header := f.get_csv_line()
	var line_no := 1
	while not f.eof_reached():
		var cells := f.get_csv_line()
		line_no += 1
		if cells.size() == 0 or (cells.size() == 1 and cells[0].strip_edges() == ""):
			continue
		if cells[0].strip_edges().begins_with("#"):
			continue
		var row := {"_line": line_no}
		for i in header.size():
			row[header[i].strip_edges()] = cells[i].strip_edges() if i < cells.size() else ""
		out.append(row)
	return out

static func _logic(table: String, text_col: String) -> Dictionary:
	var out := {}
	for row: Dictionary in _rows(table + "_logic.csv"):
		out[row["id"]] = row
	var src := {}
	for row: Dictionary in _rows(table + ".csv"):
		var text := String(row.get(text_col, ""))
		if table == "events" and String(row.get("weak_text", "")) != "":
			text += " | " + String(row["weak_text"])
		if not out.has(row["id"]):
			push_warning("Holdings: %s has no generated logic for '%s' (%s.csv line %d). Ask Claude to generate it." % [table, row["id"], table, int(row["_line"])])
		elif String(out[row["id"]]["source_text"]) != text:
			push_warning("Holdings: text of '%s' in %s.csv changed since its logic was generated. Ask Claude to regenerate %s_logic.csv." % [row["id"], table, table])
	return out

static func _ints(v: Variant) -> Variant:
	if v is float and v == floorf(v):
		return int(v)
	if v is Array:
		var a: Array = []
		for x in v:
			a.append(_ints(x))
		return a
	if v is Dictionary:
		var d := {}
		for k in v:
			d[k] = _ints(v[k])
		return d
	return v

static func _json(row: Dictionary, col: String, file: String, empty: Variant) -> Variant:
	var text := String(row.get(col, ""))
	if text == "":
		return empty
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		push_error("Holdings: bad JSON in %s line %d, column '%s': %s" % [file, int(row["_line"]), col, text])
		return empty
	return _ints(parsed)

static func _yes(row: Dictionary, col: String) -> bool:
	return ["yes", "true", "1", "y", "x"].has(String(row.get(col, "")).to_lower())

static func _sector_key(name: String) -> String:
	for k: String in TYPE_NAMES:
		if TYPE_NAMES[k].to_lower() == name.to_lower() or k == name.to_lower():
			return k
	return name

static func _load_cards() -> void:
	var logic := _logic("cards", "text")
	for row: Dictionary in _rows("cards.csv"):
		var lg: Dictionary = logic.get(row["id"], {"_line": 0})
		var c := {
			"name": row["name"],
			"type": _sector_key(row["sector"]),
			"value": int(row["value"]),
			"rarity": row["rarity"] if row["rarity"] != "" else "common",
			"text": row["text"],
		}
		var p := {}
		if row["pattern"] != "":
			p["kind"] = row["pattern"]
			if row["pattern_param"] != "":
				p["param"] = int(row["pattern_param"])
		c["pattern"] = p
		if String(lg.get("short", "")) != "":
			c["short"] = lg["short"]
		if String(lg.get("tags", "")) != "":
			var tags: Array = []
			for t in String(lg["tags"]).split(";", false):
				tags.append(t.strip_edges())
			c["tags"] = tags
		if _yes(row, "chain_left"):
			c["chain_left"] = true
		if _yes(row, "copy_left"):
			c["copy_left"] = true
		c["effects"] = _json(lg, "effects", "cards_logic.csv", [])
		var trig: Dictionary = _json(lg, "triggers", "cards_logic.csv", {})
		if not trig.is_empty():
			c["triggers"] = trig
		var pas: Dictionary = _json(lg, "passive", "cards_logic.csv", {})
		if not pas.is_empty():
			c["passive"] = pas
		c["art"] = _json(lg, "art", "cards_logic.csv", {})
		CARDS[row["id"]] = c

static func _load_events() -> void:
	var logic := _logic("events", "text")
	for row: Dictionary in _rows("events.csv"):
		var lg: Dictionary = logic.get(row["id"], {"_line": 0})
		var e := {"name": row["name"], "tier": row["tier"], "category": row["category"], "full": row["weak_text"] != "", "text": row["text"]}
		if row["weak_text"] != "":
			e["weak_text"] = row["weak_text"]
		for col in ["mods", "weak", "penalty"]:
			var v: Array = _json(lg, col, "events_logic.csv", [])
			if not v.is_empty():
				e[col] = v
		var cond: Dictionary = _json(lg, "condition", "events_logic.csv", {})
		if not cond.is_empty():
			e["condition"] = cond
		EVENTS[row["id"]] = e

static func _load_offers() -> void:
	var logic := _logic("offers", "text")
	for row: Dictionary in _rows("offers.csv"):
		var lg: Dictionary = logic.get(row["id"], {})
		var o := {"name": row["name"], "text": row["text"], "icon": String(lg.get("icon", "card"))}
		if String(lg.get("edition", "")) != "":
			o["edition"] = lg["edition"]
			EDITION_OFFERS[row["id"]] = o
		else:
			MEETING_OFFERS[row["id"]] = o
