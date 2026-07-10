extends Node
class_name NumberUtilGlobal

static func format(n: int) -> String:
	if abs(n) >= 1000000000:
		return _to_scientific(n)
	return _with_commas(n)

static func short_format(n: int) -> String:
	if abs(n) >= 1_000_000_000_000:            # 1 trillion or more
		return ("-" if n < 0 else "") + "1T+"

	var num := float(abs(n))
	var suffixes := ["", "k", "M", "B"]         # capped at B
	var tier := 0
	while num >= 1000.0 and tier < suffixes.size() - 1:
		num /= 1000.0
		tier += 1

	var s: String
	if tier == 0:
		s = str(int(num))          # under 1000: plain integer
	elif num < 10.0:
		s = "%.1f" % num           # single-digit scaled: "1.2k"
	else:
		s = str(int(num))          # 10+ scaled: floor, no decimal → "25k", "999B"

	if s.ends_with(".0"):
		s = s.substr(0, s.length() - 2)

	return ("-" if n < 0 else "") + s + suffixes[tier]
	
static func _with_commas(n: int) -> String:
	var s := str(abs(n))
	var out := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "," + out
	return ("-" if n < 0 else "") + out
	
static func _to_scientific(n: int) -> String:
	var e := int(floor(log(abs(n)) / log(10.0)))
	return "%.2fe%d" % [n / pow(10.0, e), e]
