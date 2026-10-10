extends Resource
class_name CurrencyData

signal refresh_signal

@export var total_earnings : BigNumber = BigNumber.new()
@export var money : BigNumber = BigNumber.new()
@export var prestige : BigNumber = BigNumber.new()

func get_total_earnings() -> BigNumber:
	return total_earnings

func add_money(amount : BigNumber):
	money = money.add(amount)
	total_earnings = total_earnings.add(amount)
	refresh_signal.emit()

func add_prestige(amount : BigNumber):
	prestige = prestige.add(amount)
	refresh_signal.emit()

func subtract_money(amount : BigNumber) -> bool:
	if money.is_less(amount):
		return false
	money = money.subtract(amount)
	refresh_signal.emit()
	return true
	
func subtract_prestige(amount : BigNumber) -> bool:
	if prestige.is_less(amount):
		return false
	prestige = prestige.subtract(amount)
	refresh_signal.emit()
	return true

func get_money_string() -> String:
	return money.format()
	
func get_prestige_string() -> String:
	return prestige.format()
	
func revert():
	total_earnings.reset()
	money.reset()
	print("reverted ",get_total_earnings().format())
	emit_changed()
	refresh_signal.emit()
