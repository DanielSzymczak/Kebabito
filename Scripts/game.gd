extends Node2D

var label_money = 0
@onready var label: Label = %Label

func _on_seller_body_entered(body : RigidBody2D) -> void:
	if body.has_method("sell_item"):
		var value = body.sell_item()
		add_earned_money(value)
		

func add_earned_money(money):
	label_money+=money
	label.text = str(label_money)
