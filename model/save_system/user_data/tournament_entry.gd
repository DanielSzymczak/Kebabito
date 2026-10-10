extends Resource
class_name TournamentData
const MAX_PLAYERS : float = 50
const TOURNAMENT_DURATION_DAY = 3

@export var league : GameEnums.TOURNAMENT_LEAGUE
@export var was_claimed : bool = false
@export var time_started : float
@export var leaderboard : Dictionary[String,BigNumber]
@export var player_traits : Dictionary[String,PlayerTraits]
# Money section
@export var total_spending: float = 0
@export var purchases_made: float = 0

func get_time_left() -> BigNumber:
	var total_duration_seconds := TOURNAMENT_DURATION_DAY * 24 * 60 * 60
	var end_timestamp := time_started + total_duration_seconds
	var current_timestamp := int(Time.get_unix_time_from_system())
	var seconds_left: int = max(0, end_timestamp - current_timestamp)
	var time_left_bn = BigNumber.from_int(seconds_left)
	return time_left_bn
	
func claim_tournament():
	was_claimed = true
	GameState.tournament_data_update.emit()
	
func purchase_made(purchase : Purchase):
	total_spending += purchase.price
	purchases_made+=1
	
func generate_tournament(ideal_stats : PlayerTraits):
	var bots : Array[PlayerTraits] = []
	var total_types = 6 
	
	# Step 1: Generate the pool of 100 random source bots
	for i in range(100):
		var random_type = randi() % total_types as GameEnums.BOT_PLAYER_TYPES
		bots.append(generate_bot_traits(random_type))
	
	# This array will hold our finalized, ordered candidates for selection
	var sorted_source_pool : Array[PlayerTraits] = []
	
	# Step 2: Establish Priority Ordering
	if ideal_stats:
		print("Got ideal stats! Sorting pool by distance profile...")
		var bot_distance_pool: Array[Dictionary] = []
		
		for bot in bots:
			var distance = _calculate_profile_distance(bot, ideal_stats)
			bot_distance_pool.append({
				"bot_traits": bot,
				"distance": distance
			})
		
		bot_distance_pool.sort_custom(func(a, b): return a["distance"] < b["distance"])
		
		# Transfer sorted elements into our source pool
		for element in bot_distance_pool:
			sorted_source_pool.append(element["bot_traits"])
	else:
		print("No ideal stats found. Using raw random pool sequencing...")
		sorted_source_pool = bots

	# --- Step 2.5: UNIFIED CAP-ENFORCING SELECTION ENGINE ---
	var selected_bots : Array[PlayerTraits] = []
	var selection_tally := {} # Tracks counts specifically during the selection phase
	const MAX_PER_TYPE := 15
	
	# PASS 1: Select up to 49 bots while strictly honoring the Max 15 cap per type
	for bot in sorted_source_pool:
		if selected_bots.size() >= 49:
			break
			
		var type = bot.bot_type
		var current_count: int = selection_tally.get(type, 0)
		
		if current_count < MAX_PER_TYPE:
			selected_bots.append(bot)
			selection_tally[type] = current_count + 1

	# PASS 2: Emergency Safety Fallback
	# If the 100-bot pool was heavily skewed and Pass 1 failed to reach 49 items,
	# we fill remaining slots with skipped items regardless of cap to prevent a soft-lock.
	if selected_bots.size() < 49:
		print("WARNING: Skewed bot pool distribution. Relaxing caps to fill remaining slots...")
		for bot in sorted_source_pool:
			if selected_bots.size() >= 49:
				break
			if not bot in selected_bots:
				selected_bots.append(bot)

	# --- Step 3: DYNAMIC ARCHETYPE NAMING ENGINE ---
	var archetype_names = {
		GameEnums.BOT_PLAYER_TYPES.WHALE: "Whale",
		GameEnums.BOT_PLAYER_TYPES.CASUAL: "Casual",
		GameEnums.BOT_PLAYER_TYPES.FTP_GRINDER: "FtpGrinder",
		GameEnums.BOT_PLAYER_TYPES.PREMIUM: "Premium",
		GameEnums.BOT_PLAYER_TYPES.DEALTAKER: "Dealtaker",
		GameEnums.BOT_PLAYER_TYPES.RANDOM: "Random"
	}
	
	var type_counters := {}
	
	for bot in selected_bots:
		var type = bot.bot_type
		
		if not type_counters.has(type):
			type_counters[type] = 1
		else:
			type_counters[type] += 1
			
		var fallback_string: String = archetype_names.get(type, "Bot") 
		var bot_name = "%s_%d" % [fallback_string, type_counters[type]]
		
		add_player(bot, bot_name)

	# --- Step 4: CONSOLE LOBBY ANALYSIS BREAKDOWN ---
	print("=============================================")
	print("      TOURNAMENT CREATED: ROOM LOBBY POOL    ")
	print("=============================================")
	var verified_total := 0
	for type in type_counters:
		var readable_name: String = archetype_names.get(type, "Unknown Bot Type")
		var total_count: int = type_counters[type]
		verified_total += total_count
		print(" -> %s: %d  " % [readable_name, total_count])
	print("Total Bot Competitors Registered: ", verified_total)
	print("=============================================")
		
func _calculate_profile_distance(bot: PlayerTraits, ideal: PlayerTraits) -> float:
	var total_deviation := 0.0
	total_deviation += abs(bot.impulsive - ideal.impulsive)
	total_deviation += abs(bot.long_sesions - ideal.long_sesions)
	total_deviation += abs(bot.checks_app_often - ideal.checks_app_often)
	total_deviation += abs(bot.willingness_to_pay - ideal.willingness_to_pay)
	total_deviation += abs(bot.dealtaker - ideal.dealtaker)
	return total_deviation
	
func get_sorted_leaderboard() -> Array:
	var l: Array = []
	for player_name in leaderboard:
		l.append({
			"name": player_name,
			"score": leaderboard[player_name]
		})
	l.sort_custom(func(a, b):
		return b["score"].is_less(a["score"])
	)
	return l

func tournament_tick():
	if get_time_left().is_greater(BigNumber.new()):
		for player in leaderboard.keys():
			var score = player_traits[player].get_tick_score_increase()
			leaderboard[player] = leaderboard[player].add(score)
		GameState.tournament_data_update.emit()

func add_score(player_name : String, score : BigNumber):
	leaderboard[player_name] = leaderboard[player_name].add(score)
	GameState.tournament_data_update.emit()

func add_player(traits : PlayerTraits, player_name : String):
	leaderboard[player_name] = BigNumber.new()
	player_traits[player_name] = traits

func generate_bot_traits(bot_type : GameEnums.BOT_PLAYER_TYPES) -> PlayerTraits:
	var bot_traits := PlayerTraits.new()
	bot_traits.bot_type = bot_type 
	
	match bot_type:
		GameEnums.BOT_PLAYER_TYPES.WHALE:
			bot_traits.impulsive = generate_stat(70,15)
			bot_traits.long_sesions = generate_stat(35,10)
			bot_traits.checks_app_often = generate_stat(80,10)
			bot_traits.willingness_to_pay = generate_stat(90,10)
			bot_traits.dealtaker = generate_stat(30,10)
			
		GameEnums.BOT_PLAYER_TYPES.CASUAL:
			bot_traits.impulsive = generate_stat(15,15)
			bot_traits.long_sesions = generate_stat(15,10)
			bot_traits.checks_app_often = generate_stat(65,10)
			bot_traits.willingness_to_pay = generate_stat(10,10)
			bot_traits.dealtaker = generate_stat(45,10)
			
		GameEnums.BOT_PLAYER_TYPES.FTP_GRINDER:
			bot_traits.impulsive = generate_stat(5,10)
			bot_traits.long_sesions = generate_stat(90,5)
			bot_traits.checks_app_often = generate_stat(80,10)
			bot_traits.willingness_to_pay = generate_stat(10,10)
			bot_traits.dealtaker = generate_stat(50,10)
			
		GameEnums.BOT_PLAYER_TYPES.PREMIUM:
			bot_traits.impulsive = generate_stat(50,15)
			bot_traits.long_sesions = generate_stat(35,10)
			bot_traits.checks_app_often = generate_stat(50,10)
			bot_traits.willingness_to_pay = generate_stat(40,10)
			bot_traits.dealtaker = generate_stat(60,10)
			
		GameEnums.BOT_PLAYER_TYPES.DEALTAKER:
			bot_traits.impulsive = generate_stat(5,15)
			bot_traits.long_sesions = generate_stat(60,10)
			bot_traits.checks_app_often = generate_stat(60,10)
			bot_traits.willingness_to_pay = generate_stat(20,10)
			bot_traits.dealtaker = generate_stat(80,10)
			
		GameEnums.BOT_PLAYER_TYPES.RANDOM:
			bot_traits.impulsive = generate_stat(50,50)
			bot_traits.long_sesions = generate_stat(50,50)
			bot_traits.checks_app_often = generate_stat(50,50)
			bot_traits.willingness_to_pay = generate_stat(50,50)
			bot_traits.dealtaker = generate_stat(50,50)
			
	return bot_traits
	
func generate_stat(value : float, variance : float) -> float:
	return clamp(randf_range(value - variance, value + variance), 0.0, 100.0)
