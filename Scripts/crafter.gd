extends Node2D

@export var crafter_navigation_nodes:Array[CrafterNode] = []
enum STATE {INPUT,OUTPUT}

func _ready() -> void:
	crafter_navigation_nodes[0].current_state = STATE.INPUT
	crafter_navigation_nodes[0].current_state = STATE.OUTPUT

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("move_to_position"):
		body.move_to_position(global_position, true)
		await get_tree().create_timer(2).timeout
		body.move_to_last_position()

func flip_crafter_node_states():
	var temp = crafter_navigation_nodes[0].current_state
	crafter_navigation_nodes[0].current_state=crafter_navigation_nodes[1].current_state
	crafter_navigation_nodes[1].current_state = temp
