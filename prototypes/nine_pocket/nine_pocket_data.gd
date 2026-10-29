extends RefCounted

const CATALOG := "res://prototypes/nine_pocket/art/covers/catalog.json"
const TEXTURES := "res://prototypes/nine_pocket/art/textures/"
const GENRES: Array[String] = ["Alternative", "Blues", "Classic Rock", "Indie", "Metal", "Psychedelic", "Punk"]
const GENRE_SHORT: Array[String] = ["ALT", "BLUES", "ROCK", "INDIE", "METAL", "PSYCH", "PUNK"]
const GENRE_COLORS: Array[String] = ["6a4bb5", "1f4e79", "b4532a", "2f6b4f", "3a3d42", "d4508f", "c0392b"]
const ERAS: Array[String] = ["60s", "70s", "80s", "90s", "00s", "10s"]
const LABELS := [
	{"name": "Rust Belt Records", "short": "Rust Belt", "color": "b4532a"},
	{"name": "Lighthouse Sound", "short": "Lighthouse", "color": "1f4e79"},
	{"name": "Comet Tapes", "short": "Comet", "color": "d9821c"},
	{"name": "Night Owl", "short": "Night Owl", "color": "2f6b4f"},
]

const SOUND_COLOR := "3fae5a"
const ENERGY_COLOR := "8a63d2"

const COLLECTION := 20
const HAND := 8
const SETLIST := 5
const DIGS := 2
const DIG_MAX := 3
const BASE_SOUND := [2, 5]
const ABILITY_CHANCE := 0.65

const GIGS := 8
const TARGETS: Array[int] = [90, 120, 160, 210, 270, 350, 450, 580]
const START_CASH := 0
const REWARD_BASE := 5
const BONUS_STEP := 0.25
const BONUS_MAX := 3
const RACK_SLOTS := 4
const START_RACK: Array[String] = ["eq", "xfade"]

const SHOP_ALBUMS := 2
const SHOP_GEAR := 2
const ALBUM_PRICE := 3
const ABILITY_PREMIUM := 1
const ALBUM_PACKS := [
	{"name": "Sampler", "price": 4, "show": 3, "pick": 1},
	{"name": "Box Set", "price": 7, "show": 4, "pick": 2},
]
const GEAR_PACKS := [
	{"name": "Grab Box", "price": 6, "show": 3, "pick": 1},
	{"name": "Studio Bundle", "price": 11, "show": 3, "pick": 2},
]

const SORT_KEYS: Array[String] = ["genre", "era", "sound", "ability", "band"]
const SORT_TEXT := {"genre": "Genre", "era": "Decade", "sound": "Sound", "ability": "Ability", "band": "Band"}

const ABILITIES := {
	"doubleshot": {"name": "Doubleshot", "text": "×2 Sound if it's the same decade as the previous song.", "gain": "sound", "chip": "×2"},
	"one_hit": {"name": "One Hit Wonder", "text": "×1.1 Sound for every earlier play. Resets when another song by this band plays.", "gain": "sound", "chip": "×1.1"},
	"opener": {"name": "Opener", "text": "+2 Energy if it's the first song.", "gain": "energy", "chip": "+2"},
	"closer": {"name": "Closer", "text": "×2 Sound if it's the last song.", "gain": "sound", "chip": "×2"},
	"crowd": {"name": "Crowd-Pleaser", "text": "+1 Energy.", "gain": "energy", "chip": "+1"},
	"segue": {"name": "Segue", "text": "+4 Sound if the next song is the same genre.", "gain": "sound", "chip": "+4"},
	"slow_jam": {"name": "Slow Jam", "text": "+8 Sound, then −1 Energy.", "gain": "sound", "chip": "+8"},
	"deep_cut": {"name": "Deep Cut", "text": "+6 Sound if Energy is 2 or less.", "gain": "sound", "chip": "+6"},
	"bandmates": {"name": "Bandmates", "text": "+1 Energy if another song by this band is in the set.", "gain": "energy", "chip": "+1"},
}

const GEAR := {
	"eq": {"name": "Graphic EQ", "text": "Each genre's fader setting is added to that genre's Sound.", "price": 6, "n": [0], "look": "faders"},
	"xfade": {"name": "Crossfader", "text": "+%d Energy when a song shares a genre or decade with the one before.", "price": 7, "n": [1, 2], "look": "xfader"},
	"gain": {"name": "Gain Stage", "text": "×%d Sound for songs in the genre on the dial.", "price": 7, "n": [2, 3], "look": "genre_knob"},
	"comp": {"name": "Compressor", "text": "+%d Sound for every song.", "price": 5, "n": [1, 2, 3], "look": "knobs"},
	"exciter": {"name": "Exciter", "text": "+%d Energy for songs from the decade on the dial.", "price": 6, "n": [1, 2], "look": "era_knob"},
	"tube": {"name": "Tube Preamp", "text": "+%d Sound for songs without an ability.", "price": 5, "n": [3, 5, 7], "look": "tube"},
}
const EQ_MIN := -1
const EQ_MAX := 3
const EQ_START: Array[int] = [2, 1, 1, -1, -1, 0, 0]
const LEVEL_NAMES: Array[String] = ["", "MK II", "MK III"]

const EDITION_CHANCE := 0.08
const EDITIONS := {
	"holo": {"name": "Holographic", "short": "HOLO", "text": "+1 Energy.", "gain": "energy", "n": 1, "price": 6, "color": "a678f0"},
	"signed": {"name": "Signed", "short": "SIGNED", "text": "+4 Sound.", "gain": "sound", "n": 4, "price": 5, "color": "c9a227"},
	"limited": {"name": "Limited Edition", "short": "LTD", "text": "×2 Sound.", "gain": "sound", "n": 2, "price": 8, "color": "d4508f"},
	"remaster": {"name": "Remaster", "short": "REMASTER", "text": "Its ability triggers twice.", "gain": "sound", "n": 2, "price": 6, "color": "4a90d9"},
	"mint": {"name": "Mint Condition", "short": "MINT", "text": "+$1 each time it's played.", "gain": "cash", "n": 1, "price": 4, "color": "3fae5a"},
}

const SERVICES_MAX := 2
const SERVICE_CHANCE := {"enhance": 0.45, "tweak": 0.5, "upgrade": 0.45}
const TWEAK_PRICE := 3
const UPGRADE_PRICE := 6
