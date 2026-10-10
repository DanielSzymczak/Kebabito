extends Resource
class_name SpawnerData

signal refresh_signal

@export var id : String
@export var buy_cost: BigNumber
@export var upgrade_cost: BigNumber
@export var current_cost : BigNumber
@export var current_level: float = 0.0
@export var level_upgrade_change: float = 0.4
@export var level_price_increase: float = 1.4
@export var base_spawn_time : BigNumber = BigNumber.from_float(5.0)
@export var base_click_timer_reduction : float = 0.5
@export var base_spawn_amount : float = 1
@export var spawned_item : Item
@export var spawn_direction : Vector2
@export var base_item_speed : float = 50
@export var minimum_spawning_time : BigNumber = BigNumber.from_float(0.01)
#Upgrades
func get_tap_effectivenes_upgrade_data() -> UpgradeStatistics:
	return GameState.game_save.game_upgrades.money_upgrades[GameState.tap_effectiveness_id.id_name]

func get_spawning_speed_upgrade_data() -> UpgradeStatistics:
	return GameState.game_save.game_upgrades.prestige_upgrades[GameState.spawning_speed_id.id_name]

func get_currency_data() -> CurrencyData:
	return GameState.game_save.currency_data

func get_item_stack_data() -> ItemStackData:
	return GameState.game_save.stack_data

func get_item_speed_upgrade_data() -> UpgradeStatistics:
	return GameState.game_save.game_upgrades.money_upgrades[GameState.item_speed_id.id_name]


func set_up():
	if not get_item_stack_data().refresh_signal.is_connected(refresh_stats):
		get_item_stack_data().refresh_signal.connect(refresh_stats)
	
	if not get_spawning_speed_upgrade_data().refresh_signal.is_connected(refresh_stats):
		get_spawning_speed_upgrade_data().refresh_signal.connect(refresh_stats)
	
	if not get_tap_effectivenes_upgrade_data().refresh_signal.is_connected(refresh_stats):
		get_tap_effectivenes_upgrade_data().refresh_signal.connect(refresh_stats)

func get_current_cost() -> BigNumber:
	if not current_cost:
		if current_level:
			current_cost = upgrade_cost.multiply(pow(level_price_increase, current_level))
		else:
			current_cost = buy_cost
		current_cost.floor_self()
	return current_cost
	
func get_current_upgrade_stat():
	return BigNumber.from_float(1.0+level_upgrade_change).pow_float(current_level)

func get_current_level() -> float:
	return current_level
	
func set_current_level(new_level : float):
	current_level = new_level
	refresh_stats()

func get_spawned_item_stack_amount():
	return get_item_stack_data().get_stack_amount(get_spawned_item().name)

func get_item_stack_amount(name: String):
	return get_item_stack_data().get_stack_amount(name)

func upgrade() -> bool:
	if get_currency_data().subtract_money(get_current_cost()):
		current_level+=1
		refresh_stats()
		refresh_signal.emit()
		return true
	return false

func buy():
	if get_currency_data().subtract_money(get_current_cost()):
		current_level=1
		refresh_stats()
		refresh_signal.emit()
		return true

func refresh_stats():
	current_cost = null

func get_spawned_item() -> Item:
	return spawned_item 

func get_spawning_time():
	var item_amount = get_item_stack_data().get_stack_amount(get_spawned_item().name)
	var item_stack_ratio = base_spawn_time.multiply_big(item_amount.divide(base_spawn_amount))
	var spawning_time =  item_stack_ratio.divide_big(get_spawning_speed_upgrade_data().get_current_multiplier().multiply_big(get_current_upgrade_stat()))
	return spawning_time.max(minimum_spawning_time)

func get_click_power():
	return get_tap_effectivenes_upgrade_data().get_current_multiplier().multiply(base_click_timer_reduction)

func is_enabled() -> bool:
	return current_level

func revert():
	set_current_level(0)
	
