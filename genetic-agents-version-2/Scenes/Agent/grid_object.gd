class_name GridObject extends Node


const GRID_SIZE : Vector2i = Vector2i(16, 16)
const VECTORS : Array[Vector2i] = [
	-Vector2i.ONE,  Vector2i.UP, Vector2i(1, -1),
	Vector2i.LEFT, Vector2i.RIGHT, 
	Vector2i(-1, 1), Vector2i.DOWN, Vector2i.ONE
	]

@onready var tile_map : Node2D = get_tree().current_scene.get_node(^"TileMap")

var grid_position : Vector2i: set = set_grid_pos

func _enter_tree():
	add_to_group(&"GridObjects")
	
func set_grid_pos(pos : Vector2i) -> void:
	grid_position = pos
	create_tween()\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.tween_property(self, ^"position", Vector2(grid_position * GRID_SIZE + GRID_SIZE / 2), 0.3)
