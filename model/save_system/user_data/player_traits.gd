extends Resource
class_name PlayerTraits

const BASE_TICK_INCREASE = 1000
const MAX_TRAIT_VALUE = 100
const MIN_TRAIT_VALUE = 0

@export var impulsive := 50.0
@export var long_sesions := 50.0
@export var checks_app_often := 50.0
@export var willingness_to_pay := 50.0
@export var dealtaker := 50.0
@export var bot_type: GameEnums.BOT_PLAYER_TYPES
func purchase_made(purchase : Purchase):
	var price = purchase.price
	var type = purchase.type
	var discount = purchase.discount
	
	# --- 0. CALCULATE TIME SPENT ---
	# Difference between when it spawned and when they clicked buy (in seconds)
	var time_spent: float = float(purchase.purchase_time - purchase.creation_time)
	if time_spent < 0.0: 
		time_spent = 0.0 # Safety check against corrupt/empty timestamps
	
	# --- 1. WILLINGNESS TO PAY SCALING ---
	var clamped_price = clamp(price, 0.0, 50.0)
	var dynamic_increase = remap(clamped_price, 0.0, 50.0, 1.0, 10.0)
	willingness_to_pay = clamp(willingness_to_pay + dynamic_increase, MIN_TRAIT_VALUE, MAX_TRAIT_VALUE)
	print("Price: ", price, " | Willingness Increase: ", dynamic_increase, " | New Willingness Total: ", willingness_to_pay)
	
	# --- 2. IMPULSIVE SCALING ---
	var impulsive_change := 0.0
	if time_spent <= 15.0:
		# Remaps 0s to +8.0 increase, and 10s to 0.0 increase smoothly
		impulsive_change = remap(time_spent, 0.0, 15.0, 8.0, 0.0)
	else:
		impulsive_change = -2.0
	
	if type == GameEnums.PURCHASE_TYPE.FAIRY:
		impulsive_change *= 1.5
		
	if type == GameEnums.PURCHASE_TYPE.TIME_DEAL:
		impulsive_change *= 1.1
		
	impulsive = clamp(impulsive + impulsive_change, MIN_TRAIT_VALUE, MAX_TRAIT_VALUE)
	print("Time: %.1fs | Impulsive Change: %+.1f | New Impulsive: %.1f" % [time_spent, impulsive_change, impulsive])
	
	# --- 3. DEALTAKER SCALING ---
	var base_discount_change := 0.0
	
	if discount > 0.0:
		# Convert decimal discount (e.g., 0.25) to a clean percentage float (25.0)
		var discount_percentage = discount * 100.0
		var clamped_discount = clamp(discount_percentage, 0.0, 60.0) # Matches your max 60% rule
		
		# More discount = more trait growth
		base_discount_change = remap(clamped_discount, 0.0, 60.0, 0.0, 10.0)
	else:
		# Buying something at full price severely drops their "dealtaker" metric
		base_discount_change = -5.0
		
	var price_multiplier = remap(clamped_price, 0.0, 50.0, 0.5, 2.0)
	var final_dealtaker_change = base_discount_change * price_multiplier
	
	dealtaker = clamp(dealtaker + final_dealtaker_change, MIN_TRAIT_VALUE, MAX_TRAIT_VALUE)
	print("Discount: %d%% | Multiplier: %.2f | Dealtaker Change: %.2f | New Dealtaker: %.1f" % [discount * 100, price_multiplier, final_dealtaker_change, dealtaker])
	
func new_session_started(last_session_ended: int) -> void:	
	var current_timestamp := int(Time.get_unix_time_from_system())
	
	var time_passed_seconds := current_timestamp - last_session_ended
	var time_passed_hours := time_passed_seconds / 3600.0
	
	var current_date := Time.get_datetime_dict_from_system() 
	var last_date := Time.get_datetime_dict_from_unix_time(last_session_ended)
	
	var current_julian_day := _get_julian_day(current_date.year, current_date.month, current_date.day)
	var last_julian_day := _get_julian_day(last_date.year, last_date.month, last_date.day)
	var days_passed := current_julian_day - last_julian_day
	
	var modifier := 0.0
	
	
	if days_passed == 0:
		if time_passed_hours < 2.0:
			modifier = +2.0
		else:
			modifier = -2.0
			
	elif days_passed == 1:
		if current_date.hour < 12:
			modifier = +4.0
	else:
		modifier = -10

	checks_app_often = clamp(checks_app_often + modifier, MIN_TRAIT_VALUE, MAX_TRAIT_VALUE)
	print("Days passed: %d | Hours passed: %.2f | Modifier: %+.1f | New Value: %.1f" % [days_passed, time_passed_hours, modifier, checks_app_often])

func session_ended(session_start: int) -> void:
	var current_timestamp := int(Time.get_unix_time_from_system())
	var session_duration_seconds := current_timestamp - session_start
	var session_duration_minutes := session_duration_seconds / 60.0
	var modifier := 0.0
	
	if session_duration_minutes > 15.0:
		var clamped_minutes = clamp(session_duration_minutes, 15.0, 120.0)
		
		modifier = remap(clamped_minutes, 15.0, 120.0, 2.0, 10.0)
		
	if session_duration_seconds > 30 and session_duration_minutes < 5.0 :
		modifier = -1.0
	long_sesions = clamp(long_sesions + modifier, MIN_TRAIT_VALUE, MAX_TRAIT_VALUE)
	print("Session Duration: %.1fm | Modifier: %+.1f | New Long Sessions: %.1f" % [session_duration_minutes, modifier, long_sesions])

func _get_julian_day(year: int, month: int, day: int) -> int:
	if month <= 2:
		year -= 1
		month += 12
	var a = floor(year / 100.0)
	var b = 2 - a + floor(a / 4.0)
	return int(floor(365.25 * (year + 4716)) + floor(30.6001 * (month + 1)) + day + b - 1524.5)

func get_tick_score_increase() -> BigNumber:
	var unified_score = (willingness_to_pay * 0.35) + \
						(long_sesions * 0.30) + \
						(checks_app_often * 0.20) + \
						(impulsive * 0.15)
	
	var trait_mult = remap(unified_score, 0.0, 100.0, 0.7, 1.5)
	
	var tick_variance = randf_range(0.70, 1.30)
	
	var final_tick_value = BASE_TICK_INCREASE * trait_mult * tick_variance
	
	return BigNumber.from_float(final_tick_value)

# Purchase creators
const APPEALING_PRICES: Array[float] = [1.99, 2.49, 2.99, 3.50, 3.99, 4.99, 5.00, 5.99, 6.99, 7.50, 7.99, 8.99, 9.99]
const APPEALING_DISCOUNTS: Array[float] = [0.10, 0.15, 0.20, 0.25, 0.30, 0.40, 0.50, 0.60]

# Purchase creators
func create_fairy_purchase() -> Purchase:
	if randf_range(0, 100) > (impulsive * 0.5 + 5):
		return null
		
	var purchase = Purchase.new()
	
	var wtp_factor = willingness_to_pay / 100.0
	var price_noise = randf_range(-0.5, 0.5)
	var targeted_index = int(clamp((wtp_factor + price_noise) * (APPEALING_PRICES.size() - 1), 0, APPEALING_PRICES.size() - 1))
	purchase.price = APPEALING_PRICES[targeted_index]
	
	var dt_factor = dealtaker / 100.0
	var discount_chance = 0.2 + (dt_factor * 0.6)
	
	if randf() < discount_chance:
		purchase.type = GameEnums.PURCHASE_TYPE.SHOP_DISCOUNT
		
		var discount_noise = randf_range(-0.15, 0.15)
		var discount_index = int(clamp((dt_factor + discount_noise) * (APPEALING_DISCOUNTS.size() - 1), 0, APPEALING_DISCOUNTS.size() - 1))
		purchase.discount = APPEALING_DISCOUNTS[discount_index]
	else:
		purchase.type = GameEnums.PURCHASE_TYPE.SHOP
		purchase.discount = 0.0
		
	purchase.creation_time = int(Time.get_unix_time_from_system())
	purchase.purchase_time = 0 
	return purchase
