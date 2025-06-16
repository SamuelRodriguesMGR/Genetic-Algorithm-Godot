extends GridObject


const MOUNT : Vector2i = Vector2i(0, 1)
const FOOD : Vector2i = Vector2i(0, 2)
const POSION : Vector2i = Vector2i(0, 3)
	
@onready var pushable_component : PushableComponent = get_node(^"PushableComponent") 
@onready var brain_component :  BrainComponent = get_node(^"BrainComponent")
@onready var label_energy : Label = get_node(^"LabelEnergy")
var energy_points : int = 10: set = set_health

func _ready() -> void:
	grid_position = tile_map.local_to_map(position)
	
func sensor_inputs() -> Array[float]:
	var array : Array[float]
	for vect in VECTORS:
		var target_cell : Vector2i = grid_position + vect 
		var atlas_coord : Vector2i = tile_map.get_cell_atlas_coords(target_cell)
		if atlas_coord == MOUNT or\
		is_instance_valid(get_tree().current_scene.get_agent(target_cell)):
			array.append(1)
		else:
			array.append(0)
	return array
	
func update() -> void:
	var move_dir : Vector2i = VECTORS[brain_component.predict(sensor_inputs())]
	pushable_component.try_push(move_dir)
	hurt()

func hurt() -> void:
	energy_points -= 1
	if energy_points <= 0:
		get_tree().current_scene.dead_agent(self)

func get_food(pos : Vector2i) -> void:
	energy_points += 10
	tile_map.layer_objects.erase_cell(pos)
	tile_map.layer_energy[pos.y][pos.x] = 0

func set_health(health : int) -> void:
	energy_points = health
	label_energy.text = str(health)
