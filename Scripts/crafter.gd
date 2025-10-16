extends Node2D



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("move_to_position"):
		body.move_to_position(global_position, true)
		await get_tree().create_timer(2).timeout
		body.move_to_last_position()
