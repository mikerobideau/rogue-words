extends RefCounted

const ROUNDS := 7
const START_CASH := 30
const SHOP_DISCS := 8
const SHOP_PACKS := 4
const SHOP_SLEEVES := 2
const REROLL_BASE := 2
const WORKSHOP_ORDERS := 5
const CLEAR_REWARD: Array[int] = [6, 7, 8, 9, 10, 11, 12]
const ROUND_FACTOR: Array[float] = [0.5, 0.8, 1.1, 1.4, 1.8, 2.2, 2.7]
const CALIBRATION_SHEETS := 200
const MIN_TARGET := 4

const SOUND_COLOR := "3fae5a"
const MULT_COLOR := "8a63d2"
const BASE_SOUND: Array[int] = [2, 4, 6]

const GENRES: Array[String] = ["Alternative", "Blues", "Classic Rock", "Indie", "Metal", "Psychedelic", "Punk"]
const GENRE_COLORS: Array[String] = ["6a4bb5", "1f4e79", "b4532a", "2f6b4f", "3a3d42", "d4508f", "c0392b"]
const CATALOG := "res://prototypes/nine_pocket/art/covers/catalog.json"
const ERAS: Array[String] = ["60s", "70s", "80s", "90s", "00s", "10s"]
const LABELS := [
	{"name": "Rust Belt Records", "short": "Rust Belt", "color": "b4532a", "trim": "2b2b2b"},
	{"name": "Lighthouse Sound", "short": "Lighthouse", "color": "1f4e79", "trim": "f2c14e"},
	{"name": "Comet Tapes", "short": "Comet", "color": "d9821c", "trim": "5b2a86"},
	{"name": "Night Owl", "short": "Night Owl", "color": "2f6b4f", "trim": "efe6c8"},
]
const RARITIES: Array[String] = ["Common", "Uncommon", "Rare"]
const RARITY_SHORT: Array[String] = ["COM", "UNC", "RARE"]
const RARITY_COLORS: Array[String] = ["9aa3ad", "4a90d9", "e9b949"]
const RARITY_WEIGHTS: Array[int] = [70, 25, 5]
const CONDITIONS: Array[String] = ["Worn", "Good", "Mint"]
const CONDITION_COLORS: Array[String] = ["8a8f98", "7fa7c9", "e9b949"]
const CONDITION_WEIGHTS: Array[int] = [30, 50, 20]
const RUNTIME_MIN := 28
const RUNTIME_MAX := 79

const SELL_BASE: Array[int] = [1, 3, 6]
const BUY_MULT := 2
const ABILITY_PREMIUM := 2

const ZONES: Array[String] = ["any", "corner", "edge", "center", "row0", "row1", "row2", "col0", "col1", "col2", "pair"]
const ZONE_WEIGHTS: Array[int] = [6, 3, 3, 1, 1, 1, 1, 1, 1, 1, 3]
const ZONE_TEXT := {"any": "", "corner": " in a corner", "edge": " on an edge", "center": " in the center", "row0": " in the top row", "row1": " in the middle row", "row2": " in the bottom row", "col0": " in the left column", "col1": " in the middle column", "col2": " in the right column"}
const RULE_N := {
	"sound": {"any": 3, "corner": 6, "edge": 6, "center": 14, "row": 7, "col": 7, "pair": 5},
	"mult": {"any": 1, "corner": 2, "edge": 2, "center": 5, "row": 2, "col": 2, "pair": 2},
}

const JUDGE_ADJ := {
	"genre:0": "Brooding", "genre:1": "Soulful", "genre:2": "Classic", "genre:3": "Indie", "genre:4": "Headbanging", "genre:5": "Groovy", "genre:6": "Rowdy",
	"era:0": "Sixties", "era:1": "Seventies", "era:2": "Eighties", "era:3": "Nineties", "era:4": "Y2K", "era:5": "Modern",
	"label:0": "Blue-Collar", "label:1": "Seafaring", "label:2": "Cosmic", "label:3": "Nocturnal",
	"rarity:1": "Picky", "rarity:2": "Snobbish", "cond:1": "Tidy", "cond:2": "Fussy",
}
const JUDGE_NOUN := {
	"genre:0": "Outsider", "genre:1": "Bluesman", "genre:2": "Rocker", "genre:3": "Hipster", "genre:4": "Metalhead", "genre:5": "Mystic", "genre:6": "Punk",
	"era:0": "Beatnik", "era:1": "Disco Fan", "era:2": "Synth Kid", "era:3": "Grunge Kid", "era:4": "Millennial", "era:5": "Zoomer",
	"label:0": "Steelworker", "label:1": "Lighthouse Keeper", "label:2": "Astronomer", "label:3": "Night Owl",
	"rarity:1": "Collector", "rarity:2": "Connoisseur", "cond:1": "Inspector", "cond:2": "Appraiser",
}

const ABILITY_WEIGHTS := {
	"flat": [3, 1, 0], "row_match": [4, 3, 2], "col_match": [4, 3, 2], "nbr_match": [5, 3, 2], "diag_match": [2, 2, 1],
	"nbr_filter": [4, 3, 2], "slot": [4, 3, 2], "era_step": [2, 2, 1], "row_distinct": [2, 2, 1], "line_all": [0, 2, 3],
	"x_nbrs": [0, 0, 2], "boost_row": [1, 2, 2], "boost_col": [1, 2, 2], "retrigger_left": [0, 2, 2], "retrigger_above": [0, 1, 2],
	"retrigger_nbrs": [0, 0, 2], "runtime": [1, 0, 0], "cash": [1, 1, 1], "gen_cash": [1, 1, 1], "gen_pack": [0, 1, 1],
	"sold_cash": [1, 1, 1], "sold_rare": [0, 1, 1],
}
const ABILITY_WHEN := {"gen_cash": "placed", "gen_pack": "placed", "sold_cash": "sold", "sold_rare": "sold"}
const MATCH_ATTRS: Array[String] = ["genre", "genre", "era", "era", "label"]
const ATTR_TEXT := {"era": "decade", "genre": "genre", "label": "label", "cond": "condition", "rarity": "rarity"}
const SORT_KEYS: Array[String] = ["price", "genre", "era", "label", "rarity", "cond"]
const SORT_TEXT := {"price": "Price", "genre": "Genre", "era": "Decade", "label": "Label", "rarity": "Rarity", "cond": "Condition"}
const RUNTIME_STEP := 20
const AMP_BONUS := 2

const PACKS := {
	"bargain": {"name": "Bargain Bin", "price": 6, "discs": 4, "rarity": [80, 18, 2], "cash": [0, 3], "color": "c0392b", "trim": "f4d03f"},
	"estate": {"name": "Estate Sale", "price": 12, "discs": 5, "rarity": [55, 35, 10], "cash": [1, 5], "color": "2e6ea6", "trim": "ffffff"},
	"box": {"name": "Box Set", "price": 20, "discs": 4, "rarity": [0, 50, 50], "cash": [2, 8], "color": "23262b", "trim": "e9b949"},
}

const SLEEVES := {
	"echo": {"name": "Echo", "text": "The disc here activates twice.", "price": 5, "color": "3fa7a0"},
	"amp": {"name": "Amplifier", "text": "+2 to every number in this disc's ability.", "price": 4, "color": "c4553f"},
	"polish": {"name": "Polish", "text": "The disc here counts as Mint.", "price": 3, "color": "9ad1e6"},
	"grade": {"name": "Grader", "text": "The disc here counts one rarity higher.", "price": 4, "color": "4a90d9"},
	"wild": {"name": "Wildcard", "text": "The disc here counts as every genre.", "price": 4, "color": "d4508f"},
	"gold": {"name": "Gold Sleeve", "text": "Gain $2 each time the disc here activates.", "price": 3, "color": "e9b949"},
}

const JOBS := {
	"remix": {"name": "Remix", "price": 4, "weight": 3, "color": "d4508f"},
	"remaster": {"name": "Remaster", "price": 3, "weight": 3, "color": "e07b2a"},
	"relabel": {"name": "Relabel", "price": 3, "weight": 2, "color": "1f4e79"},
	"repress": {"name": "Re-press", "price": 4, "weight": 2, "color": "3fa7a0"},
	"signed": {"name": "Signed Edition", "price": 8, "weight": 2, "color": "c9a227"},
	"picture": {"name": "Picture Disc", "price": 9, "weight": 2, "color": "8a63d2"},
	"platinum": {"name": "Platinum Edition", "price": 14, "weight": 1, "color": "aeb8c4"},
}
const EDITIONS := {
	"signed": {"name": "Signed", "text": "+6 Sound when it activates.", "kind": "sound", "n": 6, "color": "c9a227"},
	"picture": {"name": "Picture Disc", "text": "+2 Mult when it activates.", "kind": "mult", "n": 2, "color": "8a63d2"},
	"platinum": {"name": "Platinum", "text": "×2 Mult when it activates.", "kind": "xmult", "n": 2, "color": "aeb8c4"},
}
const EDITION_SELL := 2
