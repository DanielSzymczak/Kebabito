extends Resource
class_name UpgradeStatistics

signal refresh_signal

@export var currency_type : GameEnums.CURRENCY_TYPE
@export var name : String
@export var base_cost: BigNumber
@export var current_level: float = 0.0
@export var level_price_increase: float = 1.4
@export var level_change: float = 0.4
@export var max_level : float = 0
@export var is_additive : bool = false

func get_currency_data() -> CurrencyData:
	return GameState.game_save.currency_data
	
func get_current_multiplier() -> BigNumber:
	if is_additive:
		return BigNumber.from_float(level_change * current_level)
	return BigNumber.from_float(level_change+1).pow_float(current_level)
	
func get_current_price() -> BigNumber:
	return base_cost.multiply_big(BigNumber.from_float(level_price_increase+1).pow_float(current_level))
	
func upgrade():
	print(GameState.game_save.game_upgrades.money_upgrades[GameState.tap_effectiveness_id.id_name],GameState.tap_effectiveness_id.id_name)
	print(self,name)
	get_currency_data().refresh_signal.connect(refresh_stats)
	if currency_type == GameEnums.CURRENCY_TYPE.MONEY:
		if get_currency_data().subtract_money(get_current_price()):
			current_level+=1
			refresh_stats()
			refresh_signal.emit()
	elif currency_type == GameEnums.CURRENCY_TYPE.PRESTIGE:
		if get_currency_data().subtract_prestige(get_current_price()):
			current_level+=1
			refresh_stats()
			refresh_signal.emit()

func has_max_level() -> bool:
	return max_level

func get_current_level() ->float:
	return current_level

func set_current_level(level:float):
	current_level=level
	refresh_stats()

func refresh_stats():
	pass
	
func revert():
	set_current_level(0)
