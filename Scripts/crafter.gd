extends Node2D

@export var crafting_time:float = 1
@export var selected_recipe : Recipe = null
@export var crafter_navigation_nodes:Array[CrafterNode] = []
@export var inventory : Dictionary[String,float]={}

# Nodes
@export var spawner:Marker2D = null
@export var game:Node2D = null

enum STATE {INPUT,OUTPUT}
var output_node:Marker2D = null


func _ready() -> void:
	crafter_navigation_nodes[0].current_state = STATE.INPUT
	crafter_navigation_nodes[1].current_state = STATE.OUTPUT
	output_node=crafter_navigation_nodes[1]


func flip_crafter_node_states():
	output_node = crafter_navigation_nodes[1] if output_node == crafter_navigation_nodes[0] else crafter_navigation_nodes[0]
	var temp = crafter_navigation_nodes[0].current_state
	crafter_navigation_nodes[0].current_state=crafter_navigation_nodes[1].current_state
	crafter_navigation_nodes[1].current_state = temp

func select_recipe(new_recipe : Recipe) -> void:
	selected_recipe=new_recipe
	crafter_navigation_nodes[0].select_recipe(new_recipe)
	crafter_navigation_nodes[1].select_recipe(new_recipe)
	inventory.clear()

func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	if  body.id in selected_recipe.get_input_dict().keys():
		if body.id not in inventory.keys():
			inventory[body.id]=0
		inventory[body.id]+=body.ammount
		body.queue_free()
	craft()
	
func craft()->void:
	for key in selected_recipe.get_input_dict():
		if inventory.get(key) == null:
			return
		if inventory.get(key)<selected_recipe.recipe_input_string_dict.get(key):
			return
			
	for key in selected_recipe.recipe_input_string_dict.keys():
		remove_from_inventory(key,selected_recipe.recipe_input_string_dict.get(key))
	for key in selected_recipe.recipe_outputs.keys():
		spawner.spawn_item(key,self.global_position,navigate_to(output_node))
		await get_tree().create_timer(crafting_time).timeout

func remove_from_inventory(key: String, amount: float) -> void:
	if key in inventory:
		inventory[key] = max(inventory[key] - amount, 0)

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


func _on_clickable_area_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if Input.is_action_just_pressed("Selected"):
		game.select_crafter(self)
