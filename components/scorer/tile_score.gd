extends Node
class_name TileScore

enum MultKind { SPACE, ENHANCEMENT, RELIC }

var space: Space
var display_letter: String
var juice: int
var mult: int
var score: int
var beats: Array[Dictionary] = [] #{ "juice": float, "mult": float, "relic": RelicData }
