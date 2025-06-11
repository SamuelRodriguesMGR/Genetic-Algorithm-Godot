extends Node2D


@onready var layer_field : TileMapLayer = $LayerField
@onready var layer_objects : TileMapLayer = $LayerObjects

var layer_energy : Array[Array] 

func _ready() -> void:
	random_energy()
	
func random_energy() -> void:
	var region_size : Vector2i = layer_objects.get_used_rect().size
	
	for y in region_size.y:
		var row : Array[float] = []
		for x in region_size.x:
			# позиция тайла относительно начала
			var tile_position : Vector2i = Vector2i(x, y)
			var tile_data : TileData = layer_objects.get_cell_tile_data(tile_position)
			
			if tile_data:
				var index_object : float = tile_data.get_custom_data("type")
				if index_object == 1:
					row.append(randi_range(1, 10))
				else:
					row.append(0)
			else:
				row.append(0)
				
		layer_energy.append(row)

func cellv_exists(pos: Vector2i) -> bool:
	return layer_objects.get_cell_tile_data(pos) != null
	
func cellv_atlas(pos : Vector2i) -> Vector2i:
	return layer_objects.get_cell_atlas_coords(pos)
	
func get_agent(pos : Vector2i) -> GridObject:
	for node in get_tree().get_nodes_in_group(&"AgentsGroup"):
		if node.grid_position == pos:
			return node
	return null

func map_to_local(pos : Vector2i) -> Vector2:
	return layer_field.map_to_local(pos)

func local_to_map(pos : Vector2) -> Vector2i:
	return layer_field.local_to_map(pos)

func get_used_cells() -> Array[Vector2i]:
	return layer_field.get_used_cells()
