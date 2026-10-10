extends HBoxContainer
@onready var money_label: Label = %MoneyLabel
@onready var prestige_label: Label = %PrestigeLabel


func get_currency_data() -> CurrencyData:
	return GameState.game_save.currency_data

func _ready() -> void:
	_load_save_data()

func _on_timer_timeout() -> void:
	_update_labels()
	
func _update_labels():
	money_label.text = get_currency_data().get_money_string()
	prestige_label.text = get_currency_data().get_prestige_string()
	pass

func _load_save_data():
	get_currency_data().refresh_signal.connect(_update_labels)
