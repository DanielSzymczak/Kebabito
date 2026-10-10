extends Resource
class_name PlayerData


@export var player_name : String = "Player"
@export var total_spent : float = 0
@export var tournaments : Array[TournamentData]
@export var traits : PlayerTraits = PlayerTraits.new()

func analyze_highest_spending_environment() -> PlayerTraits:
	if tournaments.is_empty():
		return null
		
	var highest_spending_tournament : TournamentData = null
	var max_spending := -1.0
	
	# 1. Locate the tournament where the player dropped the most cash
	for t in tournaments:
		if t.total_spending > max_spending:
			max_spending = t.total_spending
			highest_spending_tournament = t
	
	
	# Abort if no spending history exists yet
	if not highest_spending_tournament or max_spending <= 0.0:
		return null
		
	# 2. Create an empty container to compile the optimal average stats
	var optimal_traits = PlayerTraits.new()
	optimal_traits.impulsive = 0.0
	optimal_traits.long_sesions = 0.0
	optimal_traits.checks_app_often = 0.0
	optimal_traits.willingness_to_pay = 0.0
	optimal_traits.dealtaker = 0.0
	
	var bot_count := 0
	
	# 3. Sum up the raw values of all competitors in that room
	for competitor_name in highest_spending_tournament.player_traits:
		if competitor_name == "Player": # Replace with your real player identifier string
			continue
			
		var bot: PlayerTraits = highest_spending_tournament.player_traits[competitor_name]
		
		optimal_traits.impulsive += bot.impulsive
		optimal_traits.long_sesions += bot.long_sesions
		optimal_traits.checks_app_often += bot.checks_app_often
		optimal_traits.willingness_to_pay += bot.willingness_to_pay
		optimal_traits.dealtaker += bot.dealtaker
		bot_count += 1
		
	# 4. Divide by the total count to get the exact statistical mean
	if bot_count > 0:
		optimal_traits.impulsive /= bot_count
		optimal_traits.long_sesions /= bot_count
		optimal_traits.checks_app_often /= bot_count
		optimal_traits.willingness_to_pay /= bot_count
		optimal_traits.dealtaker /= bot_count
		return optimal_traits
		
	return null
	
func recalculate_tournament_spending_data() -> PlayerTraits:
	if tournaments.size() < 5 or total_spent <= 0.0:
		return null
		
	var target_profile = analyze_highest_spending_environment()
	if not target_profile:
		return null
		
	# OPTIONAL OPTIMIZATION: Push the spending traits slightly higher (+5%) 
	# than the previous optimal average to slowly ramp up the monetization ceiling over time.
	target_profile.willingness_to_pay = clamp(target_profile.willingness_to_pay + 5.0, 0.0, 100.0)
	target_profile.impulsive         = clamp(target_profile.impulsive + 5.0, 0.0, 100.0)
	
	# Keep engagement styles exactly at the historical sweet spot
	# target_profile.long_sesions and others are already set perfectly
	
	return target_profile

func join_tournament():
	var tournament = TournamentData.new()
	tournament.generate_tournament(recalculate_tournament_spending_data())
	tournament.time_started = Time.get_unix_time_from_system()
	tournaments.append(tournament)
	GameState.tournament_data_update.emit()

func end_tournament():
	var tournament :TournamentData = get_last_tournament()
	if not tournament:
		return 
	tournament.time_started = 0
	GameState.tournament_data_update.emit()

func claim_tournament():
	get_last_tournament().claim_tournament()

func get_last_tournament() -> TournamentData:
	if tournaments.is_empty():
		return null
	return tournaments[-1]


func make_purchase(purchase : Purchase):
	purchase.purchase_time = int(Time.get_unix_time_from_system())
	total_spent+=purchase.price
	traits.purchase_made(purchase)
	if get_last_tournament():
		get_last_tournament().purchase_made(purchase)
func create_fairy_purchase() -> Purchase:
	return traits.create_fairy_purchase()
	
