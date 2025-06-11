extends GridObject


enum {MOUNT, FOOD, POSION}
const ACTIONS : Array[Vector2i] = [
	-Vector2i.ONE,  Vector2i.UP, Vector2i(1, -1),
	Vector2i.LEFT, Vector2i.ZERO, Vector2i.RIGHT, 
	Vector2i(-1, 1), Vector2i.DOWN, Vector2i.ONE
	]
	
@onready var pushable_component : Node = get_node(^"PushableComponent") 
var energy_points : int = 20: set = set_health

func sensor_inputs() -> Array[float]:
	var array : Array[float]
	array.resize(25)  # Устанавливаем размер массива
	array.fill(0)     # Заполняем нулями
	
	# направления и количество энергии
	for vect in range(VECTORS.size()):
		var neighbor : Vector2i = grid_position + VECTORS[vect]
		var tile_data : TileData = tile_map.layer_objects.get_cell_tile_data(neighbor)
		
		array[vect] = 1 # пустые
		if tile_data:
			var index_object : int = tile_data.get_custom_data("type")
			if index_object in [0, 1]:
				array[vect] = index_object
			elif index_object == 2:
				array[vect + 16] = 1
			
		array[vect + 8] = tile_map.layer_energy[neighbor.y][neighbor.x] / 10 # энергия
		
	array[24] = float(energy_points) / 200.0
	return array
	
func update() -> void:
	var move_dir : Vector2i = VECTORS.pick_random()
	pushable_component.try_push(move_dir)
	hurt()

func hurt() -> void:
	energy_points -= 1
	if energy_points <= 0:
		get_tree().current_scene.dead_agent(self, Vector2i(1, 1))

func get_food(pos : Vector2i) -> void:
	energy_points += 10
	tile_map.layer_objects.erase_cell(pos)
	tile_map.layer_energy[pos.y][pos.x] = 0

func set_health(health : int) -> void:
	energy_points = health
