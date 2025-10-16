extends Marker2D

@export var navigation_node_regular:Vector2 = Vector2.ZERO
@export var navigation_node_bridge:Vector2 = Vector2.ZERO

func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	if body.has_method("set_direction"):
		await body.move_to_position(global_position, false)
		if randf()>0.5:
			body.set_direction(navigation_node_regular)
		else:
			body.set_direction(navigation_node_bridge)
