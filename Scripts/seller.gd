extends Area2D

var currency_data : CurrencyData

func _ready() -> void:
	_load_save_data()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("sell_item"):
		var value = body.sell_item()
		currency_data.add_money(value)

func _load_save_data():
	currency_data = GameState.game_save.currency_data
