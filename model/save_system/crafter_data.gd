extends Resource
class_name CrafterData

signal refresh_signal

@export var id : String 
@export var current_level : float = 0
@export var selected_recipe : Recipe = null
@export var inventory : Dictionary[String,BigNumber]={}
@export var buy_price:BigNumber = BigNumber.new()
@export var upgrade_price : BigNumber = BigNumber.new()
@export var upgrade_price_increase_multiplier : float = 3.2
@export var upgrade_crafting_speed_increase : float = 2
@export var base_crafting_time_units : float = 1.0
@export var lowest_crafting_time : BigNumber = BigNumber.from_float(0.1)
var output_node:Marker2D = null

var current_upgrade_price : BigNumber
var current_crafter_crafting_units : BigNumber
var recipe_needed_units : BigNumber
# Outside data

func get_currency_data() -> CurrencyData:
	return GameState.game_save.currency_data
	
func get_crafting_speed_upgrade() -> UpgradeStatistics:
	return GameState.game_save.game_upgrades.prestige_upgrades[GameState.crafting_speed_id.id_name]
	
var item_stack_data : ItemStackData

func get_crafter_crafting_units() -> BigNumber:
	if not current_crafter_crafting_units:
		current_crafter_crafting_units = BigNumber.from_float(upgrade_crafting_speed_increase).pow_float(current_level-1).multiply(base_crafting_time_units).multiply_big(get_crafting_speed_upgrade().get_current_multiplier())
	return current_crafter_crafting_units

func set_up():
	if not get_currency_data().refresh_signal.is_connected(refresh_stats):
		get_currency_data().refresh_signal.connect(refresh_stats)
	
	if not get_crafting_speed_upgrade().refresh_signal.is_connected(refresh_stats):
		get_crafting_speed_upgrade().refresh_signal.connect(refresh_stats)
	
	item_stack_data = GameState.game_save.stack_data
	if not item_stack_data.refresh_signal.is_connected(refresh_stats):
		item_stack_data.refresh_signal.connect(refresh_stats)
	
func get_is_enabled() -> bool:
	return current_level
	
func get_buy_price()->BigNumber:
	return buy_price

func get_upgrade_price() ->BigNumber:
	if not current_upgrade_price:
		current_upgrade_price = upgrade_price.multiply_big(BigNumber.from_float(upgrade_price_increase_multiplier+1).pow_float(current_level)).floor_self()
	return current_upgrade_price

func get_crafting_progress_ratio(units_done : BigNumber) -> BigNumber:
	if not recipe_needed_units:
		var item_name = selected_recipe.get_output_key_at_index(0)
		recipe_needed_units = selected_recipe.get_output(item_name).multiply_big(item_stack_data.get_stack_amount(item_name)).multiply_big(selected_recipe.crafting_time_units)
	return units_done.modulo(recipe_needed_units).divide_big(recipe_needed_units)

func upgrade():
	var price : BigNumber
	if get_is_enabled():
		price = get_upgrade_price()
	else:
		price = get_buy_price()
	if get_currency_data().subtract_money(price):
		current_level+=1
		refresh_stats()

func refresh_stats():
	current_upgrade_price = null
	current_crafter_crafting_units = null
	recipe_needed_units = null
	refresh_signal.emit()
	pass

func set_current_level(level : float):
	current_level = level
	refresh_stats()

func add_to_inventory(item_name : String, amount : BigNumber) -> void:
	if not inventory.has(item_name):
		inventory[item_name] = amount.clone()
		return
	inventory[item_name] = inventory[item_name].add(amount)

func remove_from_inventory(item_name: String, amount: BigNumber) -> void:
	if item_name in inventory:
		# Calculate the new total
		var current_amount: BigNumber = inventory[item_name]
		var new_amount :BigNumber= current_amount.subtract(amount)
		# Define zero for comparison
		var zero := BigNumber.from_int(0)

		# Clamp to zero so we don't have negative inventory
		if new_amount.is_less(zero):
			inventory[item_name] = zero
		else:
			inventory[item_name] = new_amount

func check_if_can_spawn(item_name : String) -> bool:
	if inventory[item_name].is_less(item_stack_data.get_stack_amount(item_name)):
		return false
	return true

func spawn_output(item_name:String, position : Vector2, direction : Vector2):
	var amount = GameState.spawn_crafter_output(item_name,position,direction,item_stack_data.get_stack_amount(item_name))
	remove_from_inventory(item_name,amount)

func print_inventory():
	for item in inventory:
		print(item,inventory[item].format())
	
func revert():
	set_current_level(0)
	selected_recipe = Recipes.kebab_plate_recipe
