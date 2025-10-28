extends Node2D

var label_money = 0
@onready var money_label: Label = %MoneyLabel
@onready var prestige_label: Label = %PrestigeLabel
@onready var crafter_menu: ItemList = %CrafterMenu


func _on_seller_body_entered(body : RigidBody2D) -> void:
	if body.has_method("sell_item"):
		var value = body.sell_item()
		add_earned_money(value)
		

func add_earned_money(money):
	label_money+=money
	money_label.text = str(label_money).pad_decimals(0)+"$"

func select_crafter(crafter:Node2D) -> void:
	crafter_menu.display_crafter_menu(crafter)
