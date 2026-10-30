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
const HYPE_COLOR := "e9b949"
const FLOW_COLOR := "4ab3d9"

const COLLECTION := 20
const HAND := 8
const SETLIST := 5
const DIGS := 2
const DIG_MAX := 3
const BASE_SOUND := [2, 6]
const ABILITY_CHANCE := 0.4

const FLOW_MAX := 4
const SLOT_TARGETS: Array[int] = [3, 5, 7, 9, 11]
const TARGET_GROWTH := 0.15
const START_BASIC := 10
const START_CDRS := 2
const START_GENRES := 3
const START_ERAS := 3
const BASIC_POINTS := [2, 3]
const CDR_POINTS := 1
const LIKE := 2
const DISLIKE := -2
const REQUEST := 4
const REQUEST_FLOW_CHANCE := 0.3
const BAN := -3
const CALL_CHANCE := 0.55
const REQUEST_SONGS := 2
const BAN_SONGS := 3

const ENERGY_START := 50
const ENERGY_MAX := 100
const APPLAUSE := 50
const ENCORE := 80
const DIG_COST := 3

const VENUES := [
	{"name": "Basement Show", "likes": [["genre", "Punk"], ["era", "90s"]], "dislikes": [["genre", "Blues"]]},
	{"name": "Wedding Reception", "likes": [["genre", "Classic Rock"], ["era", "80s"]], "dislikes": [["genre", "Metal"]]},
	{"name": "Coffeehouse", "likes": [["genre", "Indie"], ["genre", "Alternative"]], "dislikes": [["genre", "Metal"], ["genre", "Punk"]]},
	{"name": "Biker Bar", "likes": [["genre", "Blues"], ["genre", "Classic Rock"]], "dislikes": [["genre", "Indie"]]},
	{"name": "Festival Tent", "likes": [["genre", "Psychedelic"], ["era", "10s"]], "dislikes": [["era", "60s"]]},
	{"name": "Record Store Day", "likes": [["genre", "Alternative"], ["era", "70s"]], "dislikes": [["era", "10s"]]},
]

const TOUR_GIGS := 3
const GIG_CHOICES := [1, 2]
const REWARDS_BETWEEN := 2
const REWARD_ROWS := [2, 3]
const PICKUP_CHANCE := 0.6
const SECOND_ROAD := 0.35
const REVEAL_CLICKS := 3
const CASH_REWARD := [4, 8]
const PICKUP_GEAR_CHANCE := 0.3
const HEADLINER_MULT := 1.25
const HEADLINER_NAMES: Array[String] = ["The Grand Ballroom", "Riverside Amphitheater", "The Palladium", "Starlight Arena"]
const TOWNS: Array[String] = ["Rustfield", "Lake Halcyon", "Cedar Bluff", "Port Amber", "Millbrook", "Granite Falls", "Fairhaven", "Copper Ridge", "Elk Hollow", "New Bristol", "Saltmarsh", "Pinecrest", "Wolf Creek", "Hadley", "Ironton", "Sparrow Bay", "Kettle Rock", "Brightwater", "Old Mesa", "Juniper", "Harlow", "Dunmore", "Silver Lake", "Bramblewood", "Northgate", "Canyon City", "Larkspur", "Tinley", "Marigold", "Stonebridge"]

const GIGS := 8
const TARGETS: Array[int] = [90, 120, 160, 210, 270, 350, 450, 580]
const START_CASH := 0
const REWARD_BASE := 5
const PAY_BOOED := 2
const PAY_BASE := 5
const PAY_APPLAUSE := 8
const PAY_ENCORE := 11
const BONUS_STEP := 0.25
const BONUS_MAX := 3
const RACK_SLOTS := 4
const START_RACK: Array[String] = []

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
const SORT_TEXT := {"genre": "Genre", "era": "Decade", "sound": "Points", "ability": "Ability", "band": "Band"}

const ABILITIES := {
	"opener": {"name": "Opener", "text": "+3 points in slot 1.", "chip": "+3"},
	"closer": {"name": "Closer", "text": "+3 points in slot 5.", "chip": "+3"},
	"crowd": {"name": "Crowd-Pleaser", "text": "+2 points.", "chip": "+2"},
	"bandmates": {"name": "Bandmates", "text": "+3 points if another song by this band already played tonight.", "chip": "+3"},
	"segue": {"name": "Segue", "text": "Always keeps the flow going, whatever played before it.", "chip": "FLOW"},
}

const GEAR := {
	"eq": {"name": "Graphic EQ", "text": "Each genre's fader setting is added to that genre's points.", "price": 6, "n": [0], "look": "faders"},
	"xfade": {"name": "Crossfader", "text": "When the flow breaks, it drops by 1 instead of resetting.", "price": 7, "n": [0], "look": "xfader"},
	"gain": {"name": "Gain Stage", "text": "+%d points for songs in the genre on the dial.", "price": 7, "n": [2, 3], "look": "genre_knob"},
	"comp": {"name": "Compressor", "text": "Songs from the same record label also keep the flow going.", "price": 5, "n": [0], "look": "knobs"},
	"exciter": {"name": "Exciter", "text": "+%d points for songs from the decade on the dial.", "price": 6, "n": [1, 2], "look": "era_knob"},
	"tube": {"name": "Tube Preamp", "text": "+%d points for songs without an ability.", "price": 5, "n": [2, 3, 4], "look": "tube"},
	"fog": {"name": "Fog Machine", "text": "Fire before a song: +%d flow. Twice a show.", "price": 6, "n": [1, 2], "look": "fog", "uses": 2},
	"mic": {"name": "Make Some Noise", "text": "Fire between songs: +%d crowd. Twice a show.", "price": 6, "n": [8, 12], "look": "mic", "uses": 2},
}
const EQ_MIN := -1
const EQ_MAX := 3
const EQ_START: Array[int] = [2, 1, 1, -1, -1, 0, 0]
const LEVEL_NAMES: Array[String] = ["", "MK II", "MK III"]

const EDITION_CHANCE := 0.08
const EDITIONS := {
	"holo": {"name": "Holographic", "short": "HOLO", "text": "+2 points.", "n": 2, "price": 6, "color": "a678f0"},
	"signed": {"name": "Signed", "short": "SIGNED", "text": "+3 points.", "n": 3, "price": 5, "color": "c9a227"},
	"limited": {"name": "Limited Edition", "short": "LTD", "text": "Doubles this song's points.", "n": 2, "price": 8, "color": "d4508f"},
	"remaster": {"name": "Remaster", "short": "REMASTER", "text": "Its ability triggers twice.", "n": 2, "price": 6, "color": "4a90d9"},
	"mint": {"name": "Mint Condition", "short": "MINT", "text": "+$1 each time it's played.", "n": 1, "price": 4, "color": "3fae5a"},
}

const SERVICES_MAX := 2
const SERVICE_CHANCE := {"enhance": 0.45, "tweak": 0.5, "upgrade": 0.45}
const TWEAK_PRICE := 3
const UPGRADE_PRICE := 6
