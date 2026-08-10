extends RefCounted
class_name TileScore

enum MultKind { SPACE, ENHANCEMENT, RELIC }

var space: Space
var display_letter: String
var base: int
var mult: int
var score: int
var mults: Array[Dictionary] = []
