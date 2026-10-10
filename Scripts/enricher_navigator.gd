extends Marker2D
class_name EnricherNavigatorNode

var selected_item : Item
var is_busy : bool = false
@export var navigation_vector : Marker2D = null
var current_state = GameEnums.STATE.OUTPUT
var regular_direction : Vector2
var max_enrichment_level : BigNumber = BigNumber.new()

func _on_area_2d_area_entered(area: Area2D) -> void:
	var body : ItemObject = area.get_parent()
	if current_state == GameEnums.STATE.INPUT:
		if not is_busy and body.item.name == selected_item.name and max_enrichment_level.is_greater(BigNumber.from_float(body.enrichement_level)):
			if body.has_method("set_direction"):
				body.set_direction(navigate_to(navigation_vector))
				is_busy = true
				return
	if body.has_method("set_direction"):
		body.set_direction(regular_direction)

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
