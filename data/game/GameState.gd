extends Node

@export_group("Upgrade ID Registry")
@export var item_speed_id : UpgradeID
@export var tap_effectiveness_id : UpgradeID
@export var spawning_speed_id : UpgradeID
@export var crafting_speed_id : UpgradeID
@export var enable_enrichers_id : UpgradeID
@export var enrichment_multiplier_id : UpgradeID
@export var max_level_enrichment_id : UpgradeID
@export var enriching_time_multiplier_upgrade_id : UpgradeID

@export_group("Object ID Registry")
@export var spawners : Array[SpawnerID] = []
@export var splitters : Array[SplitterID] = []
@export var crafters : Array[CrafterID] = []
@export var enrichers : Array[EnricherID] = []
@export var game_save : GameSave
const SAVE_FILE_PATH := "user://save_game.tres"
@export_group("Other")
var crafter_output_spawner : CrafterOutputSpawner

# SIGNALS
signal ui_off
signal crafter_selected(crafter:Crafter)
signal splitter_selected(splitter:Splitter)
signal enricher_selected(enricher:Enricher)
@warning_ignore("unused_signal")
signal tournament_data_update

func _ready() -> void:
	#DEBUG
	#purge_all_user_saves()
	load_game()

# New system
func new_save():
	game_save = GameSave.new()
		#Stack data
	create_stack_data()
	create_currency_data()
	#Upgrade data
	game_save.game_upgrades.money_upgrades[item_speed_id.id_name] = create_upgrade_entry(
		item_speed_id.id_name,
		UpgradeStatistics,
		BigNumber.from_int(100),
		3.5,
		0.05,
		GameEnums.CURRENCY_TYPE.MONEY
	)
	game_save.game_upgrades.money_upgrades[tap_effectiveness_id.id_name] = create_upgrade_entry(
		tap_effectiveness_id.id_name,
		UpgradeStatistics,
		BigNumber.from_int(100),
		1.8,
		2,
		GameEnums.CURRENCY_TYPE.MONEY
	)
	game_save.game_upgrades.prestige_upgrades[spawning_speed_id.id_name] = create_upgrade_entry(
		spawning_speed_id.id_name,
		UpgradeStatistics,
		BigNumber.from_int(10),
		2.5,
		0.05,
		GameEnums.CURRENCY_TYPE.PRESTIGE
	)
	game_save.game_upgrades.prestige_upgrades[crafting_speed_id.id_name] = create_upgrade_entry(
		crafting_speed_id.id_name,
		UpgradeStatistics,
		BigNumber.from_int(10),
		2.5,
		0.05,
		GameEnums.CURRENCY_TYPE.PRESTIGE
	)
	game_save.game_upgrades.prestige_upgrades[enable_enrichers_id.id_name] = create_upgrade_entry(
		enable_enrichers_id.id_name,
		UpgradeStatistics,
		BigNumber.from_int(1000000),
		1,
		1,
		GameEnums.CURRENCY_TYPE.PRESTIGE,
		1
	)
	game_save.game_upgrades.prestige_upgrades[max_level_enrichment_id.id_name] = create_upgrade_entry(
		max_level_enrichment_id.id_name,
		UpgradeStatistics,
		BigNumber.from_int(10000000),
		15,
		1,
		GameEnums.CURRENCY_TYPE.PRESTIGE,
		0,
		true
	)
	game_save.game_upgrades.prestige_upgrades[enrichment_multiplier_id.id_name] = create_upgrade_entry(
		enrichment_multiplier_id.id_name,
		UpgradeStatistics,
		BigNumber.from_int(100000),
		4.35,
		0.1,
		GameEnums.CURRENCY_TYPE.PRESTIGE
	)
	
	game_save.game_upgrades.prestige_upgrades[enriching_time_multiplier_upgrade_id.id_name] = create_upgrade_entry(
		enriching_time_multiplier_upgrade_id.id_name,
		UpgradeStatistics,
		BigNumber.from_int(100000),
		2.5,
		0.2,
		GameEnums.CURRENCY_TYPE.PRESTIGE
	)
	
	
	create_all_spawneners()
	for splitter in splitters:
		game_save.splitters[splitter.id_name]=create_splitter(splitter)
	create_all_crafters()
	create_all_enrichers()
	


# Inside GameState.gd
func save_game():
	if not game_save: return

	var err = ResourceSaver.save(game_save, SAVE_FILE_PATH, 0) 
	
	if err != OK:
		print("Save failed: ", error_string(err))
	else:
		print("Game saved successfully without bundling flags.")

func load_game():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var loaded_data = ResourceLoader.load(SAVE_FILE_PATH,"")
		
		if loaded_data is GameSave:
			game_save = loaded_data
			print("Game Loaded Successfully")
			print("loaded", loaded_data.currency_data.get_total_earnings().format())
			return
		else:
			push_error("Save file exists but is not a GameSave resource!")
	
	print("No save found. Starting new game.")
	new_save()
	
# Helpers
func create_spawner(id : SpawnerID,
	buy_cost : BigNumber, 
	upgrade_cost : BigNumber, 
	item : Item, 
	base_spawn_time : BigNumber, 
	base_click_timer_reduction : float,
	spawn_direction : Vector2
	) -> SpawnerData:
	var s = SpawnerData.new()
	s.id = id.id_name
	s.buy_cost= buy_cost
	s.upgrade_cost = upgrade_cost
	s.spawned_item = item
	print(item)
	s.base_spawn_time = base_spawn_time
	s.base_click_timer_reduction = base_click_timer_reduction
	s.spawn_direction = spawn_direction
	return s

func create_all_spawneners():
	game_save.spawners[spawners[0].id_name]=create_spawner(
	spawners[0],
	BigNumber.new(0,0),
	BigNumber.new(1,2),
	Items.get_item(Items.small_rollo_id),
	BigNumber.from_float(10),
	1,
	Vector2.DOWN)
	
	game_save.spawners[spawners[1].id_name]=create_spawner(
	spawners[1],
	BigNumber.new(0.15,7),
	BigNumber.new(0.5,7),
	Items.get_item(Items.small_rollo_id),
	BigNumber.from_float(5.0),
	2,
	Vector2.UP)
	
	game_save.spawners[spawners[2].id_name]=create_spawner(
	spawners[2],
	BigNumber.new(0,0),
	BigNumber.new(1,2),
	Items.get_item(Items.small_rollo_id),
	BigNumber.from_float(10),
	1,
	Vector2.DOWN)
	
	game_save.spawners[spawners[3].id_name]=create_spawner(
	spawners[3],
	BigNumber.new(0.15,7),
	BigNumber.new(0.5,7),
	Items.get_item(Items.small_rollo_id),
	BigNumber.from_float(5.0),
	2,
	Vector2.UP)
	
	# output spawner values are meaningless
	game_save.spawners[spawners[4].id_name]=create_spawner(
	spawners[4],
	BigNumber.new(0,0),
	BigNumber.new(1,2),
	Items.get_item(Items.small_rollo_id),
	BigNumber.from_float(5.0),
	0.5,
	Vector2.DOWN)

func create_upgrade_entry(
	upgrade_name:String,
	upgrade_stats_type : GDScript,
	base_cost : BigNumber,
	level_price_increase : float,
	level_change : float,
	currency_type : GameEnums.CURRENCY_TYPE = GameEnums.CURRENCY_TYPE.MONEY,
	max_level : float = 0,
	is_additive : bool = false
	) -> Resource:
		
	var res : UpgradeStatistics = upgrade_stats_type.new()
	
	if not res is UpgradeStatistics:
		push_error("Type passed to create_upgrade_entry is not an UpgradeStatistics!")
		return null
	res.name = upgrade_name
	res.current_level= 0
	res.base_cost = base_cost
	res.level_price_increase = level_price_increase
	res.level_change = level_change
	res.currency_type = currency_type
	res.max_level = max_level
	res.is_additive = is_additive
	return res

func create_splitter(id: SplitterID) -> SplitterData:
	var s =SplitterData.new()
	s.id = id.id_name
	
	for item in Items.all_items:
		s.backward_items_set[item] = false
		s.forward_items_set[item] = false
	return s

func create_crafter(id : CrafterID, buy_price : BigNumber, upgrade_price : BigNumber, upgrade_price_increase_multiplier : float, upgrade_crafting_speed_increase : float) -> CrafterData:
	var s = CrafterData.new()
	s.id = id.id_name
	s.buy_price = buy_price.clone()
	s.upgrade_price = upgrade_price.clone()
	s.upgrade_crafting_speed_increase = upgrade_crafting_speed_increase
	s.upgrade_price_increase_multiplier = upgrade_price_increase_multiplier
	s.selected_recipe = Recipes.kebab_plate_recipe
	return s

func create_enricher(id : EnricherID, buy_price : BigNumber, upgrade_price : BigNumber, upgrade_price_increase_multiplier : float) -> EnricherData:
	var s = EnricherData.new()
	s.id = id.id_name
	s.buy_price = buy_price
	s.upgrade_price = upgrade_price
	s.upgrade_price_multiplier = upgrade_price_increase_multiplier
	s.set_up()
	return s
	
func create_all_crafters():
	var crafter_prices : Dictionary[CrafterID,BigNumber] = {
		crafters[0]:BigNumber.from_float(5),
		crafters[1]:BigNumber.from_float(350),
		crafters[2]:BigNumber.from_float(5500),
		crafters[3]:BigNumber.from_float(35000),
		crafters[4]:BigNumber.from_float(135000),
		#crafters[5]:BigNumber.from_float(650000),
		#crafters[6]:BigNumber.from_float(1250000),
		}
	for crafter in crafters:
		game_save.crafters[crafter.id_name] = create_crafter(crafter,
		crafter_prices[crafter],
		crafter_prices[crafter].multiply(2),
		2.2,
		2)

func create_stack_data():
	var upgrade_costs : Dictionary[String,BigNumber] = {
		Items.small_rollo_id.id_name:BigNumber.new(1,2),
		Items.kebab_plate_id.id_name:BigNumber.new(0.25,4),
		Items.baklava_id.id_name:BigNumber.new(0.15,5),
		Items.shish_kebab_id.id_name:BigNumber.new(0.5,6),
		Items.kebab_box_id.id_name:BigNumber.new(0.25,7),
		Items.onigiri_id.id_name:BigNumber.new(0.75,8),
	}
	
	game_save.stack_data = ItemStackData.new()
	
	for item_name in upgrade_costs:
		game_save.stack_data.item_stack_level[item_name]=0
		game_save.stack_data.item_stack_base_prices[item_name] = upgrade_costs[item_name]

func create_currency_data():
	game_save.currency_data = CurrencyData.new()
	game_save.currency_data.money = BigNumber.from_int(1000000000)
	game_save.currency_data.prestige = BigNumber.new(100000000)
	game_save.currency_data.total_earnings = BigNumber.new(20000000)

func create_all_enrichers():
	var enricher_prices : Dictionary[EnricherID,BigNumber] = {
		enrichers[0]:BigNumber.new(1,6)
	}
	
	for enricher_id in enrichers:
		game_save.enrichers[enricher_id.id_name] = create_enricher(
			enricher_id,
			enricher_prices[enricher_id],
			enricher_prices[enricher_id].multiply(3),
			2.5
		)
		
func _on_timer_timeout() -> void:
	save_game()

func spawn_crafter_output(item_name : String, location:Vector2, direction : Vector2, amount : BigNumber):
	var item = Items.get_item_by_name(item_name)
	return crafter_output_spawner.spawn_output(item,location,direction,amount)

func select_crafter(crafter:Crafter):
	ui_off.emit()
	crafter_selected.emit(crafter)
func select_splitter(splitter:Splitter):
	ui_off.emit()
	splitter_selected.emit(splitter)
func select_enricher(enricher:Enricher):
	ui_off.emit()
	enricher_selected.emit(enricher)

func purge_all_user_saves() -> void:
	var dir = DirAccess.open("user://")
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		# Loop through every file in the user folder
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".res"):
				dir.remove(file_name)
				print("Deleted file: ", file_name)
			file_name = dir.get_next()
			
	else:
		push_error("An error occurred when trying to access the path.")
		
	# Wipe memory and restart
	game_save = null
	new_save()
	print("All .res save files purged.")

func prestige():
	for spawner in spawners:
		game_save.spawners[spawner.id_name].revert()
	for crafter in crafters:
		game_save.crafters[crafter.id_name].revert()
	for splitter in splitters:
		game_save.splitters[splitter.id_name].revert()
	for enricher in enrichers:
		game_save.enrichers[enricher.id_name].revert()
		
	game_save.stack_data.revert()
	game_save.game_upgrades.revert()
	game_save.currency_data.revert()
	
	# NEW: Force a save to disk immediately so the hard drive matches the cache
	save_game() 
	
	get_tree().reload_current_scene()
	
