extends Marker2D
class_name CrafterOutputSpawner

var spawner_data : SpawnerData
var item_stack_data : ItemStackData
var item_speed_upgrade_data : UpgradeStatistics
@export var item_speed_id : UpgradeID
@export var id : SpawnerID
func _ready() -> void:
	_load_save_data()

func spawn_output(item : Item, location:Vector2, direction : Vector2, amount : BigNumber):
	var new_instance_of_item : ItemObject = item.scene.instantiate()
	add_child(new_instance_of_item)
	new_instance_of_item.set_data(item,amount,item_speed_upgrade_data.get_current_multiplier().multiply(spawner_data.base_item_speed).to_float())
	new_instance_of_item.global_position=location
	new_instance_of_item.set_direction(direction)
	return amount
	
func _load_save_data():
	spawner_data = GameState.game_save.spawners[id.id_name]
	spawner_data.set_up()
	item_stack_data = GameState.game_save.stack_data
	item_speed_upgrade_data = GameState.game_save.game_upgrades.money_upgrades[item_speed_id.id_name]
	GameState.crafter_output_spawner = self
