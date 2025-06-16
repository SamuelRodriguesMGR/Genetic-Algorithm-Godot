class_name PushableComponent extends Node


var tween : Tween = null

func try_push(dir : Vector2i) -> bool:
	# Нужная позиция
	var target_cell : Vector2i = owner.grid_position + dir
	# Проверка на других агентов
	var agent : GridObject = get_tree().current_scene.get_agent(target_cell)
	if is_instance_valid(agent):
		animate_push_fail(dir)
		return false
	# Проверка на тайлы
	var atlas_coord : Vector2i = owner.tile_map.get_cell_atlas_coords(target_cell)
	if atlas_coord != -Vector2i.ONE:
		if atlas_coord == owner.MOUNT:
			animate_push_fail(dir)
			return false
		
		#if atlas_coord == FOOD:
			#owner.grid_position = target_cell
			#owner.get_food(target_cell)
			#return true
			
		#if atlas_coord == POSION:
			#get_tree().current_scene.dead_agent(owner, atlas_coord)
			#return true
	
	owner.grid_position = target_cell
	return true

func animate_push_fail(dir : Vector2) -> void:
	if tween != null and tween.is_running():
		return
	
	const DURATION: float = 0.1
	
	var pos: Vector2 = Vector2(owner.grid_position * GridObject.GRID_SIZE)
	
	# Play the animation
	tween = create_tween() .set_trans(Tween.TRANS_SINE) .set_ease(Tween.EASE_OUT)
	tween.tween_property(owner, ^"position", pos + Vector2(dir), DURATION)
	tween.tween_property(owner, ^"position", pos, DURATION)
