extends RefCounted

const CATALOG := "res://prototypes/nine_pocket/art/covers/catalog.json"
const MUSIC_DIR := "res://prototypes/nine_pocket/music"
const MUSIC_SECONDS := 4.0
const MUSIC_FADE := 0.8
const MENU_FADE := 1.5
const TEXTURES := "res://prototypes/nine_pocket/art/textures/"
const GENRES: Array[String] = ["Pop", "Rock", "Hip-Hop", "Jazz"]
const GENRE_SHORT: Array[String] = ["POP", "ROCK", "HIPHOP", "JAZZ"]
const GENRE_COLORS: Array[String] = ["5d626a", "5d626a", "5d626a", "5d626a"]
const COND_WEIGHTS := {"plain": 6, "set1": 3, "set2": 3, "odd": 2, "even": 2, "opener": 3, "closer": 3, "after_genre": 7, "after_decade": 6, "above_genre": 7, "above_decade": 7, "hype": 10, "boost": 8, "fans": 8, "anthem": 8, "mirror": 5}
const RARITY_WEIGHTS := {"common": 20, "uncommon": 55, "rare": 25}
const CARDS_PATH := "res://prototypes/nine_pocket/data/cards.json"
const COND_POINTS := {"plain": 12, "set1": 6, "set2": 6, "odd": 6, "even": 6, "opener": 8, "closer": 8, "after_genre": 7, "after_decade": 7, "above_genre": 7, "above_decade": 7, "hype": 4, "boost": 4, "fans": 4, "anthem": 4, "mirror": 4}
const SET_BONUS := 10
const SIDE_BONUS := 8
const OPENER_MULT := 2.0
const CLOSER_MULT := 3.0
const AFTER_MULT := 2.0
const ABOVE_MULT := 3.0
const AMP_ADD := 1.5
const SURGE_MULT := 2.5
const FANS_FLOW := 1.0
const ECHO_FLOW := 1.5
const ANTHEM_ADD := 8
const HATE_MULT := 0.5
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
const SETLIST := 6
const DIGS := 3
const DIG_MAX := 1
const DIG_OFFERS := 3
const CATALOG_DATA := preload("res://prototypes/nine_pocket/album_catalog.gd")

const FLOW_MAX := 6
const GIG_TARGETS: Array[int] = [60, 110, 200, 360, 650, 1150]
const HEADLINER_MULT := 1.25
const BOSS_TARGET := 1.3
const TIER_GOOD := 1.5
const TIER_GREAT := 2.0
const EQ_UNIT := 3
const DECK_SIZE := 24
const DECK_THEME := 6
const KITS := [
	{"name": "Chain Gang", "idea": "Buff the next song and build long chains.", "gear": "echo", "lean": ["genre", "Jazz"]},
	{"name": "Showstopper", "idea": "Open big and close bigger.", "gear": "mic", "lean": ["genre", "Rock"]},
	{"name": "Genre Streak", "idea": "Stack one genre and watch it snowball.", "gear": "gain", "lean": ["genre", "Pop"]},
	{"name": "Crowd Pleaser", "idea": "Steady points from variety and a full set.", "gear": "tube", "lean": ["era", "90s"]},
]
const CDR_POINTS := 3
const LIKE := 5
const REQUEST := 10
const CALL_CHANCE := 0.55
const REQUEST_SONGS := 2


const VENUES := [
	{"name": "Basement Show", "likes": [["genre", "Rock"], ["era", "90s"]], "dislikes": [["genre", "Jazz"]]},
	{"name": "Wedding Reception", "likes": [["genre", "Pop"], ["era", "80s"]], "dislikes": [["genre", "Hip-Hop"]]},
	{"name": "Coffeehouse", "likes": [["genre", "Jazz"], ["genre", "Pop"]], "dislikes": [["genre", "Rock"]]},
	{"name": "Block Party", "likes": [["genre", "Hip-Hop"], ["genre", "Pop"]], "dislikes": [["genre", "Jazz"]]},
	{"name": "Festival Tent", "likes": [["genre", "Rock"], ["era", "10s"]], "dislikes": [["era", "60s"]]},
	{"name": "Record Store Day", "likes": [["genre", "Hip-Hop"], ["era", "70s"]], "dislikes": [["era", "10s"]]},
]

const USE_FORK := true
const BOSS_EVERY := 3
const TOUR_BOSSES := 2
const BOSS_DEBUFF_MULT := 0.5
const BOSS_DESTROY := 0.2
const BOSS_DIGS := 1
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
const SORT_TEXT := {"genre": "Genre", "era": "Decade", "sound": "Points", "band": "Band"}

const GEAR := {
	"eq": {"name": "Graphic EQ", "text": "Each genre's fader setting (x3) is added to that genre's songs.", "price": 6, "n": [0], "look": "faders"},
	"gain": {"name": "Gain Stage", "text": "+%d points for songs in the genre on the dial.", "price": 7, "n": [3, 6], "look": "genre_knob"},
	"exciter": {"name": "Exciter", "text": "+%d points for songs from the decade on the dial.", "price": 6, "n": [3, 6], "look": "era_knob"},
	"tube": {"name": "Tube Preamp", "text": "+%d points for songs with no effect.", "price": 5, "n": [4, 8, 12], "look": "tube"},
	"mic": {"name": "Make Some Noise", "text": "Your closing song scores x%d.", "price": 6, "n": [2, 3], "look": "knobs"},
	"pitch": {"name": "Pitch Control", "text": "After and above decade effects accept a decade one step either side.", "price": 6, "n": [0], "look": "knobs"},
	"echo": {"name": "Echo Unit", "text": "Flow gains from effects are 50% bigger.", "price": 6, "n": [0], "look": "knobs"},
}
const EQ_MIN := -1
const EQ_MAX := 3
const EQ_START: Array[int] = [2, 1, 0, -1]
const LEVEL_NAMES: Array[String] = ["", "MK II", "MK III"]

const EDITION_CHANCE := 0.08
const EDITIONS := {
	"holo": {"name": "Holographic", "short": "HOLO", "text": "+3 points on a hit.", "n": 3, "price": 6, "color": "a678f0"},
	"signed": {"name": "Signed", "short": "SIGNED", "text": "+5 points on a hit.", "n": 5, "price": 5, "color": "c9a227"},
	"limited": {"name": "Limited Edition", "short": "LTD", "text": "+8 points on a hit.", "n": 8, "price": 8, "color": "d4508f"},
	"mint": {"name": "Mint Condition", "short": "MINT", "text": "+$1 each time it's played.", "n": 1, "price": 4, "color": "3fae5a"},
}

const SERVICES_MAX := 2
const SERVICE_CHANCE := {"enhance": 0.45, "tweak": 0.5, "upgrade": 0.45}
const TWEAK_PRICE := 3
const UPGRADE_PRICE := 6
