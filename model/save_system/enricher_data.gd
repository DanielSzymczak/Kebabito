extends Resource
class_name EnricherData

signal refresh_signal

@export var id : String 
@export var selected_item : Item = Items.get_item(ItemsRegistry.small_rollo_id)
@export var input_index : int = 0
@export var output_index : int = 1
@export var enriching_time_units : float = 5
@export var enriching_speed_multiplier : float = 1.5
@export var current_level : float
@export var buy_price : BigNumber
@export var upgrade_price : BigNumber
@export var upgrade_price_multiplier : float

var currency_data : CurrencyData

var max_enrichment_level_upgrade : UpgradeStatistics
var enrichment_multiplier_upgrade : UpgradeStatistics
var enriching_time_multiplier_upgrade : UpgradeStatistics

var max_enrichment_level : BigNumber
var enrichment_multiplier : BigNumber
var enriching_time_multiplier : BigNumber
var current_upgrade_price : BigNumber

func get_enriching_time_units() -> BigNumber:
	return get_enriching_time_multiplier().multiply(enriching_time_units).multiply_big(BigNumber.from_float(enriching_speed_multiplier).pow_float(current_level-1))

func get_enriching_time_multiplier() -> BigNumber: 
	if not enriching_time_multiplier:
		enriching_time_multiplier =  enriching_time_multiplier_upgrade.get_current_multiplier()
	return enriching_time_multiplier
	
func get_max_enrichment_level() -> BigNumber:
	if not max_enrichment_level:
		max_enrichment_level = max_enrichment_level_upgrade.get_current_multiplier().add(BigNumber.from_int(1))
	return max_enrichment_level
	
func get_enrichment_multiplier() -> BigNumber:
	if not enrichment_multiplier:
		enrichment_multiplier = enrichment_multiplier_upgrade.get_current_multiplier()
	return enrichment_multiplier
	
func set_up():
	currency_data = GameState.game_save.currency_data
	
	max_enrichment_level_upgrade = GameState.game_save.game_upgrades.prestige_upgrades[GameState.max_level_enrichment_id.id_name]
	if not max_enrichment_level_upgrade.refresh_signal.is_connected(refresh_stats):
		max_enrichment_level_upgrade.refresh_signal.connect(refresh_stats)
	
	enrichment_multiplier_upgrade = GameState.game_save.game_upgrades.prestige_upgrades[GameState.enrichment_multiplier_id.id_name]
	if not enrichment_multiplier_upgrade.refresh_signal.is_connected(refresh_stats):
		enrichment_multiplier_upgrade.refresh_signal.connect(refresh_stats)
	pass

	enriching_time_multiplier_upgrade = GameState.game_save.game_upgrades.prestige_upgrades[GameState.enriching_time_multiplier_upgrade_id.id_name]
	if not enriching_time_multiplier_upgrade.refresh_signal.is_connected(refresh_stats):
		enriching_time_multiplier_upgrade.refresh_signal.connect(refresh_stats)
	pass
	
func refresh_stats():
	max_enrichment_level = null
	enrichment_multiplier = null
	enriching_time_multiplier = null
	current_upgrade_price = null
	refresh_signal.emit()
	pass

func set_current_level(level : float):
	current_level = level
	refresh_stats()

func get_buy_price()->BigNumber:
	return buy_price

func get_upgrade_price() ->BigNumber:
	if not current_upgrade_price:
		current_upgrade_price = upgrade_price.multiply_big(BigNumber.from_float(upgrade_price_multiplier+1).pow_float(current_level)).floor_self()
	return current_upgrade_price

func get_is_enabled() -> bool:
	return current_level

func upgrade():
	var price : BigNumber
	if get_is_enabled():
		price = get_upgrade_price()
	else:
		price = get_buy_price()
	if currency_data.subtract_money(price):
		current_level+=1
		refresh_stats()

func get_item_enriching_time() -> BigNumber:
	return selected_item.enriching_time_units.divide_big(get_enriching_time_units())

func revert():
	set_current_level(0)
