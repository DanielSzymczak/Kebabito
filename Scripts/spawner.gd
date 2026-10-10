extends Marker2D
class_name Spawner


@onready var texture_progress_bar: TextureProgressBar = $Visuals/TextureProgressBar
@onready var visuals: Node2D = $Visuals
@export var id : SpawnerID
@export var item_speed_id : UpgradeID
@export var tap_effectivenes_id : UpgradeID
@export var spawning_speed_upgrade_id : UpgradeID

var spawner_data : SpawnerData
var item_speed_upgrade_data : UpgradeStatistics
var elapsed = BigNumber.new()

func _ready() -> void:
	_load_save_data()
	

	
func _process(delta):
	var dynamic_timer_time =  spawner_data.get_spawning_time()
	if spawner_data.is_enabled():
		elapsed = elapsed.add(BigNumber.from_float(delta))
	
	if not elapsed.is_less(dynamic_timer_time):
		elapsed = BigNumber.new()
		spawn_item(spawner_data.get_spawned_item(),global_position,spawner_data.spawn_direction,spawner_data.get_spawned_item_stack_amount())

	texture_progress_bar.value = (elapsed.divide_big(dynamic_timer_time)).multiply(100).to_float()


func spawn_item(item : Item, location:Vector2 = self.global_position, direction = Vector2(0,1), amount : BigNumber = BigNumber.new()):
	# ... checks ...
	
	var new_instance_of_item = item.scene.instantiate()
	
	add_child(new_instance_of_item) 
	
	new_instance_of_item.set_data(item, spawner_data.get_item_stack_amount(item.name), (spawner_data.get_item_speed_upgrade_data().get_current_multiplier()).multiply(spawner_data.base_item_speed).to_float())
	
	new_instance_of_item.global_position = location
	new_instance_of_item.rotation = rotation
	new_instance_of_item.set_direction(direction)
	
	return amount
 
func squish():
	var t = create_tween()
	t.tween_property(visuals, "scale", Vector2(1, 0.9), 0.05)
	t.tween_property(visuals, "scale", Vector2.ONE, 0.1).set_delay(0.05)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("Selected"):
		if spawner_data.is_enabled():
			elapsed = elapsed.add(spawner_data.get_click_power())
			squish()

func _load_save_data():
	spawner_data = GameState.game_save.spawners[id.id_name]
	spawner_data.set_up()
	if not spawner_data.refresh_signal.is_connected(_on_data_refreshed):
		spawner_data.refresh_signal.connect(_on_data_refreshed)
	_update_visual_state()

func _on_data_refreshed() -> void:
	_update_visual_state()

func _update_visual_state() -> void:
	if spawner_data.is_enabled():
		modulate = Color.WHITE # Normal look
	else:
		modulate = Color(0.5, 0.5, 0.5) # Grayed out
