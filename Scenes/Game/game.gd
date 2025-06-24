extends Node2D


const MAX_AGENTS : int = 1
const AGENT : PackedScene = preload("res://Scenes/GridObjects/agent.tscn")

@onready var tile_map : TileMapLayer = get_node(^"TileMap")
@onready var timer : Timer = get_node(^"Timer")

var stack_agents : Array[GridObject] = []
var current_agent :  int = 0
@onready var turn_time : float = timer.wait_time

var dict_objects : Dictionary 

var list_brain : Array

func _ready() -> void:
	stack_agents.append($Agent)
	_fill_field()
	update_timer()
	timer.start()
	
	for tile in tile_map.get_used_cells():
		dict_objects[tile] = tile_map.get_cell_atlas_coords(tile)
	
func _fill_field() -> void:
	var SIZE_MAP : Vector2i = tile_map.get_used_rect().end
	var tiles : Array[Vector2i]
	# берём все тайлы поля и перемешиваем их
	for y in SIZE_MAP.y:
		for x in SIZE_MAP.x:
			var tile_position : Vector2i = Vector2i(x, y)
			tiles.append(tile_position)
	tiles.shuffle()
	# спавним агентов
	var index : int = 0
	while get_tree().get_node_count_in_group(&"AgentsGroup") != MAX_AGENTS:
		if tile_map.get_cell_atlas_coords(tiles[index]) == -Vector2i.ONE:
			spawn_agent(tiles[index])
		index += 1

func spawn_agent(pos : Vector2i) -> GridObject:
	var agent : GridObject = AGENT.instantiate()
	add_child(agent)
	stack_agents.append(agent)
	agent.position = Vector2i.ONE * 400
	agent.grid_position = pos
	return agent

func dead_agent(agent : GridObject) -> void:
	stack_agents.erase(agent)
	update_timer()
	agent.queue_free()
	
func get_agent(pos : Vector2i) -> GridObject:
	for node in get_tree().get_nodes_in_group(&"AgentsGroup"):
		if node.grid_position == pos:
			return node
	return null

func update_timer() -> void:
	var count_agents : int = get_tree().get_node_count_in_group(&"AgentsGroup")
	if not count_agents:
		return
	timer.wait_time = turn_time / count_agents

func _on_timer_timeout() -> void:
	#for agent in get_tree().get_nodes_in_group(&"AgentsGroup"):
		#agent.update()
	if stack_agents.is_empty():
		return
		
	var agent : GridObject = stack_agents[current_agent]
	agent.update()
	
	# Переход к следующему агенту
	if stack_agents.is_empty():
		return
	current_agent = (current_agent + 1) % stack_agents.size()
