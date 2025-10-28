extends Marker2D

@export var navigation_node_regular:Marker2D = null
@export var navigation_node_bridge:Marker2D = null

func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	if body.has_method("set_direction"):
		if randf()>0.5:
			body.set_direction(navigate_to(navigation_node_regular))
		else:
			body.set_direction(navigate_to(navigation_node_bridge))

func navigate_to(node : Marker2D)->Vector2:
	var output: Vector2 = node.global_position - self.global_position
	var threshold = 10
	output.x = clamp_with_threshold(output.x, threshold)
	output.y = clamp_with_threshold(output.y, threshold)
	return output
	
func clamp_with_threshold(value: float, threshold: float) -> int:
	if abs(value) < threshold:
		return 0
	return 1 if value > 0 else -1
