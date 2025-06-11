extends Node2D


const SIZE_MAP : Vector2i = Vector2i(36, 20)
const MAX_AGENTS : int = 256
const AGENT : PackedScene = preload("res://Scenes/GridObjects/agent.tscn")

@onready var tile_map : Node2D = $TileMap
@onready var timer : Timer = $Timer

var stack_agents : Array[GridObject] = []
var current_agent :  int = 0
@onready var turn_time : float = timer.wait_time
var list_data_weights_hidden : Array
var list_data_weights_output : Array

func _ready():
	GlobalVars.stop_simulation = false
	_fill_field()
	update_timer()
	timer.start()
	
func _fill_field() -> void:
	var tiles : Array[Vector2i] = tile_map.get_used_cells()
	tiles.shuffle()
	
	var index : int = 0
	while get_tree().get_node_count_in_group(&"AgentsGroup") != MAX_AGENTS:
		if !tile_map.cellv_exists(tiles[index]):
			spawn_agent(tiles[index])
		index += 1
	
func spawn_agent(pos : Vector2i) -> GridObject:
	var agent : GridObject = AGENT.instantiate()
	add_child(agent)
	stack_agents.append(agent)
	agent.position = tile_map.map_to_local(SIZE_MAP / 2)
	agent.grid_position = pos
	
	if GlobalVars.step_simulation > 0:
		var count_brain : int = (get_tree().get_node_count_in_group(&"AgentsGroup") - 1) / (MAX_AGENTS / 8)
		agent.brain_component.weights_to_hidden = GlobalVars.weights_to_hidden_list[count_brain]
		agent.brain_component.weights_to_output = GlobalVars.weights_to_output_list[count_brain]
		
		if get_tree().get_node_count_in_group(&"AgentsGroup") / 8 != count_brain:
			agent.brain_component.mutate_weights()
		
	return agent

func dead_agent(agent : GridObject, tile_after : Vector2i = -Vector2i.ONE) -> void:
	var count_agents : int = get_tree().get_node_count_in_group(&"AgentsGroup")
	if count_agents <= 8 and !GlobalVars.stop_simulation:
		for ag in get_tree().get_nodes_in_group(&"AgentsGroup"):
			list_data_weights_hidden.append(ag.brain_component.weights_to_hidden)
			list_data_weights_output.append(ag.brain_component.weights_to_output)
		update_simulation()
		return
		
	stack_agents.erase(agent)
	update_timer()
	tile_map.layer_objects.set_cell(agent.grid_position, 0, tile_after)
	list_data_weights_hidden.append(agent.brain_component.weights_to_hidden)
	list_data_weights_output.append(agent.brain_component.weights_to_output)
	agent.queue_free()
	
func update_simulation() -> void:
	GlobalVars.weights_to_hidden_list.clear()
	GlobalVars.weights_to_output_list.clear()
	
	list_data_weights_hidden.reverse()
	list_data_weights_output.reverse()
	
	for i in range(MAX_AGENTS / 8):
		GlobalVars.weights_to_hidden_list.append(list_data_weights_hidden[i])
		GlobalVars.weights_to_output_list.append(list_data_weights_output[i])
	
	GlobalVars.step_simulation += 1
	GlobalVars.stop_simulation = true
	
func update_timer() -> void:
	return
	var count_agents : int = get_tree().get_node_count_in_group(&"AgentsGroup")
	if not count_agents:
		return
	timer.wait_time = turn_time / count_agents

func _on_timer_timeout() -> void:
	if !GlobalVars.stop_simulation:
		for agent in get_tree().get_nodes_in_group(&"AgentsGroup"):
			agent.update()
	else:
		get_tree().reload_current_scene()
	#if stack_agents.is_empty():
		#return
		#
	#var agent : GridObject = stack_agents[current_agent]
	#agent.update()
	#
	## Переход к следующему агенту
	#if stack_agents.is_empty():
		#return
	#current_agent = (current_agent + 1) % stack_agents.size()
