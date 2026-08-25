extends Node2D
class_name SpaceContainer

const LinkScene = preload("res://components/space/link.tscn")

var bounds := Rect2()
var has_spaces := false
var _links := {}

func add_space(space: Space) -> void:
	add_child(space)
	if not has_spaces:
		bounds = Rect2(space.position, Vector2.ZERO)
		has_spaces = true
	else:
		bounds = bounds.expand(space.position)

func center_in(rect_size: Vector2) -> void:
	position = rect_size / 2.0 - bounds.get_center()

func add_link(a: Space, b: Space) -> void:
	var key = _edge_key(a, b)
	if _links.has(key):
		return
	var link := LinkScene.instantiate()
	link.z_index = -1
	add_child(link)
	link.set_endpoints(a.position, b.position)
	link.grow()
	_links[key] = link
	

func remove_links_for(space: Space, neighbors: Array) -> void:
	for neighbor in neighbors:
		if neighbor == null:
			continue
		var key = _edge_key(space, neighbor)
		if _links.has(key):
			_links[key].queue_free()
			_links.erase(key)

func _edge_key(a: Space, b: Space) -> String:
	if a.get_instance_id() < b.get_instance_id():
		return str(a.get_instance_id()) + "-" + str(b.get_instance_id())
	return str(b.get_instance_id()) + "-" + str(a.get_instance_id())
