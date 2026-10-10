extends Node2D
class_name Crafter


@export var crafter_navigation_nodes:Array[CrafterNode] = []
@export var navigate_clockwise : bool = false

# Nodes
@export var game:Game = null
@onready var crafting_direction_sprite: Sprite2D = $CraftingDirectionSprite
@onready var crafting_bar: ProgressBar = $ProgressBar
@onready var output_spawning_timer: Timer = $Output_Spawning_Timer
@onready var spawning_bar: ProgressBar = $SpawningBar

@export var id : CrafterID
var crafter_data : CrafterData
@export var crafting_speed_upgrade_id : UpgradeID
var item_stack_data : ItemStackData

var press_time := 0.0
var pressed := false
var is_crafting : bool = false
var progress_bar_unit_data := BigNumber.new()

var craft_progress_seconds := BigNumber.from_int(0)
const MAX_TAP_TIME := 0.25

enum STATE {INPUT,OUTPUT}

func _ready() -> void:
	_load_save_data()

	crafter_navigation_nodes[0].current_state = STATE.INPUT
	crafter_navigation_nodes[1].current_state = STATE.OUTPUT
	if navigate_clockwise:
		crafter_navigation_nodes[0].regular_direction = Vector2.UP.rotated(rotation)
		crafter_navigation_nodes[1].regular_direction = Vector2.DOWN.rotated(rotation)
	else:
		crafter_navigation_nodes[0].regular_direction = Vector2.DOWN.rotated(rotation)
		crafter_navigation_nodes[1].regular_direction = Vector2.UP.rotated(rotation)
	crafter_data.output_node = crafter_navigation_nodes[1]
	crafting_bar.min_value = 0
	crafting_bar.max_value = 1
	crafting_bar.value = 0
	crafting_bar.visible = false

func _process(delta: float) -> void:
	if not output_spawning_timer.is_stopped():
		# Calculate percentage: (Time Elapsed / Total Wait Time) * 100
		var progress = (1.0 - output_spawning_timer.time_left / output_spawning_timer.wait_time) * 100
		spawning_bar.value = progress
	else:
		spawning_bar.value = 0
		
	if crafter_data.current_level == 0.0 or crafter_data.selected_recipe == null or is_crafting == false:
		return

	var crafter_power = crafter_data.get_crafter_crafting_units()
	var work_done_this_frame = crafter_power.multiply(delta)

	craft_progress_seconds = craft_progress_seconds.add(work_done_this_frame)
	progress_bar_unit_data = progress_bar_unit_data.add(work_done_this_frame)
	var cost_per_recipe = crafter_data.selected_recipe.crafting_time_units

	if cost_per_recipe.is_less(craft_progress_seconds):
		var crafts_to_do = craft_progress_seconds.divide_big(cost_per_recipe).floor_self()
		_process_batch_crafting(crafts_to_do)
		craft_progress_seconds = craft_progress_seconds.subtract(cost_per_recipe.multiply_big(crafts_to_do))

	var progress_ratio = (crafter_data.get_crafting_progress_ratio(progress_bar_unit_data)).to_float()
	if progress_ratio > 1.0:
		progress_bar_unit_data = craft_progress_seconds.clone()
	crafting_bar.value = clamp(progress_ratio, 0.0, 1.0)
	crafting_bar.visible = true
	check_if_can_craft()

func flip_crafter_node_states():
	crafter_data.output_node = crafter_navigation_nodes[1] if crafter_data.output_node == crafter_navigation_nodes[0] else crafter_navigation_nodes[0]
	var temp = crafter_navigation_nodes[0].current_state
	crafter_navigation_nodes[0].current_state=crafter_navigation_nodes[1].current_state
	crafter_navigation_nodes[1].current_state = temp
	crafting_direction_sprite.flip_h = !crafting_direction_sprite.flip_h

func select_recipe(new_recipe : Recipe) -> void:
	crafter_data.selected_recipe=new_recipe
	crafter_navigation_nodes[0].select_recipe(new_recipe)
	crafter_navigation_nodes[1].select_recipe(new_recipe)
	crafter_data.refresh_stats()
	check_if_can_craft()

func _on_area_2d_area_entered(area: Area2D) -> void:
	var body : ItemObject = area.get_parent()
	if  body.item.name in crafter_data.selected_recipe.get_input_dict_strings().keys():
		crafter_data.add_to_inventory(body.item.name,body.get_amount())
		body.queue_free()
		check_if_can_craft()

func _process_batch_crafting(batch_amount: BigNumber) -> void:
	var recipe : Recipe = crafter_data.selected_recipe

	var min_available_crafts : BigNumber = null
	for item_name in recipe.get_input_dict_strings():
		var temp = crafter_data.inventory[item_name].divide_big(recipe.get_input(item_name))
		if min_available_crafts == null:
			min_available_crafts = temp.clone()
		min_available_crafts = min_available_crafts.min(temp)
	min_available_crafts.floor_self()

	min_available_crafts = min_available_crafts.min(batch_amount)

	for item_name in recipe.get_input_dict_strings():
		crafter_data.remove_from_inventory(item_name,recipe.get_input(item_name).multiply_big(min_available_crafts))

	for item_name in recipe.get_output_dict_strings():
		crafter_data.add_to_inventory(item_name,recipe.get_output(item_name).multiply_big(min_available_crafts))
	check_if_can_spawn()

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

func _on_clickable_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		
		if event.pressed:
			press_time = Time.get_ticks_msec()
			pressed = true
		
		else:
			if not pressed:
				return
			
			pressed = false
			
			var duration := (Time.get_ticks_msec() - press_time) / 1000.0
			
			if duration <= MAX_TAP_TIME:
				GameState.select_crafter(self)

func upgrade():
	crafter_data.upgrade()
	if crafter_data.get_is_enabled():
		crafter_navigation_nodes[0].enable()
		crafter_navigation_nodes[1].enable()
		modulate = Color(1,1,1)


func _load_save_data():
	crafter_data = GameState.game_save.crafters[id.id_name]
	if crafter_data.get_is_enabled() == false:
		modulate = Color(0.5, 0.5, 0.5)
	else:
		select_recipe(crafter_data.selected_recipe)
	item_stack_data = GameState.game_save.stack_data
	crafter_data.set_up()
	for item in Items.all_items:
		if not crafter_data.inventory.has(item.name):
			crafter_data.inventory[item.name] = BigNumber.new()
	check_if_can_craft()
		
func check_if_can_craft():
	if crafter_data.selected_recipe == null:
		is_crafting = false
		return
	var recipe_dict = crafter_data.selected_recipe.get_input_dict_strings()
	for key in recipe_dict:
		if crafter_data.inventory[key].is_less(recipe_dict[key]):
			is_crafting = false
			return
	is_crafting = true

func get_next_spawnable_item() -> String:
	var zero = BigNumber.new() 
	
	for item_name in crafter_data.inventory:
		if crafter_data.selected_recipe.get_input(item_name).is_greater(zero):
			continue
			
		if crafter_data.check_if_can_spawn(item_name):
			return item_name
			
	return ""

func check_if_can_spawn() -> void:
	if get_next_spawnable_item() != "":
		if output_spawning_timer.is_stopped():
			output_spawning_timer.start(0)
	else:
		output_spawning_timer.stop()

func _on_output_spawning_timer_timeout() -> void:
	var item_to_spawn = get_next_spawnable_item()
	if item_to_spawn != "":
		crafter_data.spawn_output(item_to_spawn,global_position,navigate_to(crafter_data.output_node))
		item_to_spawn = get_next_spawnable_item()
	if item_to_spawn == "":
		output_spawning_timer.stop()
