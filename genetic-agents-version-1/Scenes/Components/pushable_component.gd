class_name PushableComponent extends Node


enum {MOUNT, FOOD, POSION}

var tween : Tween = null

func try_push(dir : Vector2i) -> bool:
	var target_cell : Vector2i = owner.grid_position + dir
	
	var agent : GridObject = owner.tile_map.get_agent(target_cell)
	if agent:
		animate_push_fail(dir)
		return false
	
	var tile_data : TileData = owner.tile_map.layer_objects.get_cell_tile_data(target_cell)
	if tile_data:
		var atlas_coord : Vector2i = owner.tile_map.cellv_atlas(target_cell)
		var index_object : int = tile_data.get_custom_data("type")
		
		if index_object == MOUNT:
			animate_push_fail(dir)
			return false
		
		if index_object == FOOD:
			owner.grid_position = target_cell
			owner.get_food(target_cell)
			return true
			
		if index_object == POSION:
			get_tree().current_scene.dead_agent(owner, atlas_coord)
			return true
	
	owner.grid_position = target_cell
	return true

func animate_push_fail(dir : Vector2):
	if tween != null and tween.is_running():
		return
	
	const DURATION: float = 0.1
	
	var pos: Vector2 = Vector2(owner.grid_position * GridObject.GRID_SIZE + GridObject.GRID_SIZE / 2)
	
	# Play the animation
	tween = create_tween() .set_trans(Tween.TRANS_SINE) .set_ease(Tween.EASE_OUT)
	tween.tween_property(owner, ^"position", pos + Vector2(dir), DURATION)
	tween.tween_property(owner, ^"position", pos, DURATION)
