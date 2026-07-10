extends Node2D
class_name WordFinder

const DICTIONARY_PATH = "res://data/dictionary.txt"

const DEFAULT_MIN_WORD_LENGTH = 4

var dictionary: Dictionary = {}
var relic_manager: RelicManager
var min_word_length := DEFAULT_MIN_WORD_LENGTH

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
			_dfs([start], [letter], letter, placed_space, found, seen_words)
	
	found.sort_custom(func(a, b):
		if a['word'] == b['word']:
			return _path_signature(a['path']) < _path_signature(b['path'])   # tiebreaker
		return a['word'] < b['word'])
		
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

func _dfs(path: Array, letters: Array, word: String, must_include: Space, found: Array, seen: Dictionary):
	if word.length() >= min_word_length and is_word(word) and path.has(must_include):
		var sig := word + "|" + _path_signature(path)
		if not seen.has(sig):
			seen[sig] = true
			found.append({'path': path.duplicate(), 'letters': letters.duplicate(), 'word': word})
	for neighbor in path[-1].links:
		if neighbor != null and neighbor.token != null and not (neighbor in path):
			var matches = [neighbor.token.letter]
			if relic_manager:
				matches = relic_manager.get_letter_matches(neighbor.token.letter)
			for letter in matches:
				path.append(neighbor)
				letters.append(letter)
				_dfs(path, letters, word + letter, must_include, found, seen)
				letters.pop_back()
				path.pop_back()
				
#The same word can score multiple times in a turn, but it must have a unique combination of tokens
func _path_signature(path: Array) -> String:
	var ids := []
	for s in path:
		ids.append(s.get_instance_id())
	ids.sort()
	return str(ids)
