extends PanelContainer

var currency_data : CurrencyData
var threshold = BigNumber.from_int(1000000)
@onready var button: Button = $MarginContainer/VBoxContainer/HBoxContainer/Button
@onready var label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Label

func _ready() -> void:
	currency_data = GameState.game_save.currency_data
	currency_data.refresh_signal.connect(refresh)

func set_up():
	print(currency_data.get_total_earnings().format(),"  thre", threshold.format())
	if threshold.is_less(currency_data.get_total_earnings()):
		button.disabled=false
		label.text = "Prestige: %s" %calculate_prestige().format()
	else:
		button.disabled=true
		label.text = "Minimum earnings: %s" %threshold.format()
		

func _on_button_pressed() -> void:
	currency_data.add_prestige(calculate_prestige())
	GameState.prestige()

func calculate_prestige() -> BigNumber:
	var base_calc = currency_data.total_earnings.divide_big(threshold)
	return base_calc.pow_float(0.5).floor_self().max(BigNumber.from_int(1))
	
func refresh():
	set_up()
	print("refreshed",currency_data.get_total_earnings().format())
