extends Node2D
class_name WordFinder

const DICTIONARY_PATH = "res://data/dictionary.txt"

const DEFAULT_MIN_WORD_LENGTH = 3

var dictionary: Dictionary = {}
var prefixes: Dictionary = {}
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
			for i in range(1, word.length() + 1):
				prefixes[word.substr(0, i)] = true

func forms_word(space: Space, token: Token) -> bool:
	if space.token != null:
		return false
	space.token = token              # logical simulate only — do NOT call place_token()
	var result := _has_word_from(space)
	space.token = null               # always restore before returning
	return result
			
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

func _is_prefix(s: String) -> bool:
	return prefixes.has(s)

func _has_word_from(must_include: Space) -> bool:
	for start in _get_connected_occupied(must_include):
		var matches = [start.token.letter]
		if relic_manager:
			matches = relic_manager.get_letter_matches(start.token.letter)
		for letter in matches:
			if _has_word_dfs([start], letter, must_include):
				return true
	return false

func _has_word_dfs(path: Array, word: String, must_include: Space) -> bool:
	if not _is_prefix(word):
		return false                 # prune: no dictionary word starts with this
	if word.length() >= min_word_length and is_word(word) and path.has(must_include):
		return true                  # early exit
	for neighbor in path[-1].links:
		if neighbor != null and neighbor.token != null and not (neighbor in path):
			var matches = [neighbor.token.letter]
			if relic_manager:
				matches = relic_manager.get_letter_matches(neighbor.token.letter)
			for letter in matches:
				path.append(neighbor)
				if _has_word_dfs(path, word + letter, must_include):
					path.pop_back()
					return true
				path.pop_back()
	return false
