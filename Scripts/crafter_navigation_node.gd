extends Marker2D

class_name CrafterNode

enum STATE {INPUT,OUTPUT}
@export var current_state = STATE.INPUT

@export var navigation_node_regular:Vector2 = Vector2.ZERO
@export var navigation_node_crafter:Vector2 = Vector2.ZERO

func _on_area_2d_2_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	if body.has_method("set_direction"):
		if randf()>0.5:
			body.set_direction(navigation_node_regular)
		else:
			body.set_direction(navigation_node_crafter)
