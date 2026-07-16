class_name Rarity
extends RefCounted

enum Type { COMMON, UNCOMMON, RARE, LEGENDARY }

const WEIGHTS := {
	Type.COMMON: 100,
	Type.UNCOMMON: 40,
	Type.RARE: 12,
	Type.LEGENDARY: 3,
}

const NAMES := {
	Type.COMMON: "Common",
	Type.UNCOMMON: "Uncommon",
	Type.RARE: "Rare",
	Type.LEGENDARY: "Legendary",
}

static func to_text(r: Type) -> String:
	return NAMES.get(r, "Unknown")

const COLORS := {
	Type.COMMON: Color(0.7, 0.7, 0.7),
	Type.UNCOMMON: Color(0.3, 0.8, 0.4),
	Type.RARE: Color(0.3, 0.5, 0.9),
	Type.LEGENDARY: Color(0.9, 0.6, 0.2),
}

static func weight(r: Type) -> int: return WEIGHTS[r]
static func color(r: Type) -> Color: return COLORS[r]
