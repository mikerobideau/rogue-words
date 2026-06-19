extends Node2D
class_name WordFinder

const MIN_WORD_LENGTH := 2

const DICTIONARY_PATH = "res://data/dictionary.txt"
var dictionary: Dictionary = {}
var relic_manager: RelicManager

func _ready():
	_load_dictionary()
	
func _load_dictionary():
	var file = FileAccess.open(DICTIONARY_PATH, FileAccess.READ)
	if file == null:
		push_error('Dictionary file not found.')
		return
	while not file.eof_reached():
		var word = file.get_line().strip_edges().to_upper()
		if word.length() > 0:
			dictionary[word] = true
			
func is_word(word: String) -> bool:
	return dictionary.has(word.to_upper())

func find_words(placed_space: Space):
	var found := []
	var seen_words := {}
	
	var start_spaces := _get_connected_occupied(placed_space)
	
	for start in start_spaces:
		var matches = [start.token.letter]
		if relic_manager:
			matches = relic_manager.get_letter_matches(start.token.letter)
		for letter in matches:
			_dfs([start], letter, placed_space, found, seen_words)
		
	return found
	
func _get_connected_occupied(start: Space) -> Array:
	var visited = {start: true}
	var queue := [start]
	while queue.size() > 0:
		var current = queue.pop_front()
		for neighbor in current.links:
			if neighbor != null and neighbor.token != null and not visited.has(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)
	return visited.keys()

func _dfs(path: Array, word: String, must_include: Space, found: Array, seen: Dictionary):
	if word.length() >= MIN_WORD_LENGTH and is_word(word) and path.has(must_include):
		if not seen.has(word):
			found.append({'path': path.duplicate(), 'word': word})
	for neighbor in path[-1].links:
		if neighbor != null and neighbor.token != null and not (neighbor in path):
			var matches = [neighbor.token.letter]
			if relic_manager:
				matches = relic_manager.get_letter_matches(neighbor.token.letter)
			for letter in matches:
				path.append(neighbor)
				_dfs(path, word + letter, must_include, found, seen)
				path.pop_back()
