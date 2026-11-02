extends RefCounted

const CATALOG := "res://prototypes/nine_pocket/art/covers/catalog.json"
const MUSIC_DIR := "res://prototypes/nine_pocket/music"
const MUSIC_SECONDS := 5.0
const MUSIC_FADE := 0.8
const MENU_FADE := 1.5
const TEXTURES := "res://prototypes/nine_pocket/art/textures/"
const GENRES: Array[String] = ["Alternative", "Blues", "Classic Rock", "Indie", "Metal", "Psychedelic", "Punk"]
const GENRE_SHORT: Array[String] = ["ALT", "BLUES", "ROCK", "INDIE", "METAL", "PSYCH", "PUNK"]
const GENRE_COLORS: Array[String] = ["5d626a", "5d626a", "5d626a", "5d626a", "5d626a", "5d626a", "5d626a"]
const COND_WEIGHTS := {"any": 10, "set1": 5, "set2": 5, "odd": 5, "even": 5, "opener": 3, "closer": 3, "after_genre": 14, "after_decade": 12, "above_genre": 11, "above_decade": 10, "between": 6}
const COND_DECK := {"any": 5, "set1": 2, "set2": 2, "odd": 2, "even": 2, "opener": 2, "closer": 2, "after_genre": 7, "after_decade": 5, "above_genre": 5, "above_decade": 5, "between": 3}
const COND_STARS := {"any": 0, "set1": 1, "set2": 1, "odd": 1, "even": 1, "opener": 2, "closer": 3, "after_genre": 2, "after_decade": 2, "above_genre": 3, "above_decade": 3, "between": 6}
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
const SETLIST := 8
const DIGS := 3
const DIG_MAX := 1
const DIG_OFFERS := 3
const CATALOG_DATA := preload("res://prototypes/nine_pocket/album_catalog.gd")

const FLOW_MAX := 8
const COOLING: Array[int] = [3, 4, 5, 5, 6, 6]
const COOL_HEADLINER := 1
const COOL_BOSS := 1
const START_CDRS := 2
const KITS := [
	{"name": "Flow Crew", "idea": "Chain songs together and keep the flow rolling.", "gear": "xfade", "lean": ["genre", "Indie"]},
	{"name": "Showstopper", "idea": "Open big and close bigger.", "gear": "mic", "lean": ["genre", "Classic Rock"]},
	{"name": "Genre Streak", "idea": "Stack one genre and watch it snowball.", "gear": "gain", "lean": ["genre", "Punk"]},
	{"name": "Crowd Pleaser", "idea": "Steady points from variety and a full set.", "gear": "tube", "lean": ["era", "90s"]},
]
const CDR_STARS := 0
const LIKE := 2
const DISLIKE := -2
const REQUEST := 4
const CALL_CHANCE := 0.55
const REQUEST_SONGS := 2

const ENERGY_START := 20
const ENERGY_MAX := 60
const APPLAUSE := 26
const ENCORE := 42
const DIG_COST := 3

const VENUES := [
	{"name": "Basement Show", "likes": [["genre", "Punk"], ["era", "90s"]], "dislikes": [["genre", "Blues"]]},
	{"name": "Wedding Reception", "likes": [["genre", "Classic Rock"], ["era", "80s"]], "dislikes": [["genre", "Metal"]]},
	{"name": "Coffeehouse", "likes": [["genre", "Indie"], ["genre", "Alternative"]], "dislikes": [["genre", "Metal"], ["genre", "Punk"]]},
	{"name": "Biker Bar", "likes": [["genre", "Blues"], ["genre", "Classic Rock"]], "dislikes": [["genre", "Indie"]]},
	{"name": "Festival Tent", "likes": [["genre", "Psychedelic"], ["era", "10s"]], "dislikes": [["era", "60s"]]},
	{"name": "Record Store Day", "likes": [["genre", "Alternative"], ["era", "70s"]], "dislikes": [["era", "10s"]]},
]

const USE_FORK := true
const BOSS_EVERY := 3
const TOUR_BOSSES := 2
const BOSS_DEBUFF := -2
const BOSS_DESTROY := 0.2
const BOSS_DIGS := 1
const BOSS_HATE_MULT := 2
const BOSS_KINDS: Array[String] = ["genre", "era", "slot", "hates", "target", "gear", "destroy", "discards"]
const ROAD_COMBOS := [
	{"stops": ["pickup", "pickup"], "weight": 25},
	{"stops": ["pickup", "shop"], "weight": 40},
	{"stops": ["cash", "pickup"], "weight": 20},
	{"stops": ["shop", "pickup"], "weight": 15},
]
const TOUR_GIGS := 3
const GIG_CHOICES := [1, 2]
const REWARDS_BETWEEN := 2
const REWARD_ROWS := [2, 3]
const CASH_CHANCE := 0.5
const SECOND_ROAD := 0.35
const REVEAL_CLICKS := 3
const CASH_REWARD := [4, 8]
const PICKUP_GEAR_CHANCE := 0.3
const PICKUP_GEAR_PITY := 2
const PICKUP_CHOICES := 3
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
const ALBUM_PACKS := [
	{"name": "Sampler", "price": 4, "show": 3, "pick": 1},
	{"name": "Box Set", "price": 7, "show": 4, "pick": 2},
]
const GEAR_PACKS := [
	{"name": "Grab Box", "price": 6, "show": 3, "pick": 1},
	{"name": "Studio Bundle", "price": 11, "show": 3, "pick": 2},
]

const SORT_KEYS: Array[String] = ["genre", "era", "sound", "band"]
const SORT_TEXT := {"genre": "Genre", "era": "Decade", "sound": "Stars", "band": "Band"}

const GEAR := {
	"eq": {"name": "Graphic EQ", "text": "Each genre's fader setting is added to that genre's hits.", "price": 6, "n": [0], "look": "faders"},
	"xfade": {"name": "Crossfader", "text": "A miss halves your flow instead of resetting it.", "price": 7, "n": [0], "look": "xfader"},
	"gain": {"name": "Gain Stage", "text": "+%d on a hit for songs in the genre on the dial.", "price": 7, "n": [1, 2], "look": "genre_knob"},
	"comp": {"name": "Compressor", "text": "The first miss each show doesn't break your flow.", "price": 5, "n": [0], "look": "knobs"},
	"exciter": {"name": "Exciter", "text": "+%d on a hit for songs from the decade on the dial.", "price": 6, "n": [1, 2], "look": "era_knob"},
	"tube": {"name": "Tube Preamp", "text": "+%d on a hit for songs with no stars.", "price": 5, "n": [1, 2, 3], "look": "tube"},
	"fog": {"name": "Fog Machine", "text": "Fire before a song: +%d flow. Twice a show.", "price": 6, "n": [1, 2], "look": "fog", "uses": 2},
	"mic": {"name": "Make Some Noise", "text": "Fire between songs: +%d audience score. Twice a show.", "price": 6, "n": [4, 6], "look": "mic", "uses": 2},
	"pitch": {"name": "Pitch Control", "text": "After and above decade conditions accept a decade one step either side.", "price": 6, "n": [0], "look": "knobs"},
	"echo": {"name": "Echo Unit", "text": "A hit on the closing song pays double.", "price": 6, "n": [0], "look": "knobs"},
}
const EQ_MIN := -1
const EQ_MAX := 3
const EQ_START: Array[int] = [2, 1, 1, -1, -1, 0, 0]
const LEVEL_NAMES: Array[String] = ["", "MK II", "MK III"]

const EDITION_CHANCE := 0.08
const EDITIONS := {
	"holo": {"name": "Holographic", "short": "HOLO", "text": "+1 on a hit.", "n": 1, "price": 6, "color": "a678f0"},
	"signed": {"name": "Signed", "short": "SIGNED", "text": "+2 on a hit.", "n": 2, "price": 5, "color": "c9a227"},
	"limited": {"name": "Limited Edition", "short": "LTD", "text": "+3 on a hit.", "n": 3, "price": 8, "color": "d4508f"},
	"mint": {"name": "Mint Condition", "short": "MINT", "text": "+$1 each time it's played.", "n": 1, "price": 4, "color": "3fae5a"},
}

const SERVICES_MAX := 2
const SERVICE_CHANCE := {"enhance": 0.45, "tweak": 0.5, "upgrade": 0.45}
const TWEAK_PRICE := 3
const UPGRADE_PRICE := 6
