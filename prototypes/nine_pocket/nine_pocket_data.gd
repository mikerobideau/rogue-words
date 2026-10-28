extends RefCounted

const ROUNDS := 7
const START_CASH := 30
const SHOP_DISCS := 5
const SHOP_PACKS := 2
const SHOP_SLEEVES := 2
const REROLL_BASE := 2
const TRADER_OFFERS := 7
const CLEAR_REWARD: Array[int] = [6, 7, 8, 9, 10, 11, 12]
const ROUND_FACTOR: Array[float] = [0.4, 0.6, 0.85, 1.1, 1.4, 1.7, 2.0]
const CALIBRATION_SHEETS := 200
const CALIBRATION_FOCUS := 0.25
const MIN_TARGET := 4

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
const RARITY_POINTS: Array[int] = [0, 1, 3]
const RARITY_COLORS: Array[String] = ["9aa3ad", "4a90d9", "e9b949"]
const RARITY_WEIGHTS: Array[int] = [70, 25, 5]
const CONDITIONS: Array[String] = ["Worn", "Good", "Mint"]
const CONDITION_POINTS: Array[int] = [0, 1, 2]
const CONDITION_WEIGHTS: Array[int] = [30, 50, 20]
const RUNTIME_MIN := 28
const RUNTIME_MAX := 79

const SELL_BASE: Array[int] = [1, 3, 6]
const BUY_MULT := 2
const ABILITY_PREMIUM := 2

const CATEGORIES: Array[String] = ["cohesion", "variety", "chronology", "rarity", "condition", "label", "runtime", "showcase"]
const CAT := {
	"cohesion": {"name": "Cohesion", "adj": "Devoted", "noun": "Purist"},
	"variety": {"name": "Variety", "adj": "Eclectic", "noun": "DJ"},
	"chronology": {"name": "Chronology", "adj": "Nostalgic", "noun": "Archivist"},
	"rarity": {"name": "Rarity", "adj": "Snobbish", "noun": "Collector"},
	"condition": {"name": "Condition", "adj": "Fussy", "noun": "Appraiser"},
	"label": {"name": "Label", "adj": "Loyal", "noun": "Superfan"},
	"runtime": {"name": "Runtime", "adj": "Marathon", "noun": "Listener"},
	"showcase": {"name": "Showcase", "adj": "Flashy", "noun": "Curator"},
}

const ABILITY_WEIGHTS := {
	"flat": [5, 2, 1], "per_attr": [4, 4, 3], "distinct": [3, 3, 2], "neighbor_match": [4, 3, 2], "era_step": [3, 2, 1],
	"runtime": [2, 1, 0], "slot_bonus": [3, 2, 1], "self_mint": [2, 1, 0], "cond_balance": [0, 2, 2],
	"retrigger_left": [0, 2, 2], "retrigger_nbrs": [0, 0, 2], "double": [0, 0, 3], "cash": [2, 2, 2],
	"gen_cash": [1, 1, 1], "gen_pack": [0, 1, 2], "sold_cash": [1, 1, 1], "sold_rare": [0, 1, 1],
}
const ABILITY_WHEN := {"gen_cash": "placed", "gen_pack": "placed", "sold_cash": "sold", "sold_rare": "sold"}
const SCOPES: Array[String] = ["row", "column", "neighbors", "sheet", "binder"]
const SCOPE_TEXT := {"row": "its row", "column": "its column", "neighbors": "neighboring slots", "sheet": "this sheet", "binder": "your binder"}
const ATTR_TEXT := {"era": "decade", "genre": "genre", "label": "label"}
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

const TRADERS: Array[String] = ["Vinyl Vic", "Dee the Digger", "Mail-Order Mo", "The Crate Queen", "Basement Bob", "Swap-Meet Sal", "Indie Ida", "Pawnshop Pete"]
const TRADER_RARITY: Array[int] = [30, 45, 25]

