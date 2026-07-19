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

static func weight_of(candidate) -> int:
	var r = candidate.get("rarity")   # null on resources with no rarity (tokens)
	return weight(r) if r != null else 1

static func pick_weighted(candidates: Array):
	if candidates.is_empty():
		return null
	var total := 0
	for c in candidates:
		total += weight_of(c)
	if total <= 0:
		return candidates[randi() % candidates.size()]
	var r := randi() % total
	for c in candidates:
		r -= weight_of(c)
		if r < 0:
			return c
	return candidates[-1]
