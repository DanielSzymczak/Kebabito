extends Marker2D

@export var navigation_node_regular:Marker2D = null
@export var navigation_node_bridge:Marker2D = null

@export var navigation_set:Dictionary[Item,bool]

func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	if body.has_method("set_direction"):
		if body.item in navigation_set.keys() and navigation_set[body.item]:
			body.set_direction(navigate_to(navigation_node_bridge))
		else:
			body.set_direction(navigate_to(navigation_node_regular))

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

func set_navigation_items(new_navigation_set : Dictionary[Item,bool]):
	navigation_set = new_navigation_set
	pass
