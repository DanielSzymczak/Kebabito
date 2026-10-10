extends Resource
class_name ItemStackData

signal refresh_signal

@export var item_stack_level : Dictionary = {}
@export var item_stack_base_prices : Dictionary= {}
@export var upgrade_value_multiplier : float = 4
@export var upgrade_stack_amount_increase : float = 2

var stack_size_cache: Dictionary = {}
var currency_data : CurrencyData

func get_stack_amount(item_name: String) -> BigNumber:
	if not stack_size_cache.has(item_name):
		_recalculate_stack_cache(item_name)
	return stack_size_cache[item_name]

func get_cost(item_name : String) -> BigNumber:
	return item_stack_base_prices[item_name].multiply_big(BigNumber.from_float(upgrade_value_multiplier).pow_float(item_stack_level[item_name]))

func _recalculate_stack_cache(item_name: String):
	var level = item_stack_level.get(item_name, 0.0)
	var base = BigNumber.from_float(upgrade_stack_amount_increase)
	stack_size_cache[item_name] = base.pow_float(level)

func upgrade(item_name : String):
	if not currency_data:
		currency_data = GameState.game_save.currency_data
	
	if currency_data.subtract_money(get_cost(item_name)):
		item_stack_level[item_name]+=1
	stack_size_cache.erase(item_name)
	refresh_signal.emit()

func revert():
	for item in item_stack_level:
		item_stack_level[item]=0
	refresh_signal.emit()
