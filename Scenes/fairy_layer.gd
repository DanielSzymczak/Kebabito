extends CanvasLayer
@onready var price_label: Label = $PopupPanel/MarginContainer/VBoxContainer/HBoxContainer/PriceLabel
@onready var discount_label: Label = $PopupPanel/MarginContainer/VBoxContainer/HBoxContainer/DiscountLabel
@onready var accept_button: Button = $PopupPanel/MarginContainer/VBoxContainer/HBoxContainer2/AcceptButton
@onready var reject_button: Button = $PopupPanel/MarginContainer/VBoxContainer/HBoxContainer2/RejectButton

@onready var popup_panel: NinePatchRect = $PopupPanel

const BASE_FAIRY_SPAWN_TIME_SECONDS = 180
var fairy_scene = preload("res://Scenes/fairy.tscn")
var curency_data : CurrencyData

var purchase : Purchase

func _ready() -> void:
	curency_data = GameState.game_save.currency_data
	
	popup_panel.visible = false 
	
	start_spawning_loop()

func start_spawning_loop():
	while true:
		spawn_fairy()
		# Delays the loop execution by exactly 3.0 seconds asynchronously
		await get_tree().create_timer(3.0).timeout

func spawn_fairy():
	var fairy_instance = fairy_scene.instantiate()
	
	var screen_size = get_viewport().get_visible_rect().size
	var padding = 50 
	
	var start_pos = Vector2.ZERO
	var target_pos = Vector2.ZERO
	
	var side = randi() % 4
	
	match side:
		0:
			start_pos = Vector2(-padding, randf_range(0, screen_size.y))
			target_pos = Vector2(screen_size.x + padding, randf_range(0, screen_size.y))
		1:
			start_pos = Vector2(screen_size.x + padding, randf_range(0, screen_size.y))
			target_pos = Vector2(-padding, randf_range(0, screen_size.y))
		2:
			start_pos = Vector2(randf_range(0, screen_size.x), -padding)
			target_pos = Vector2(randf_range(0, screen_size.x), screen_size.y + padding)
		3:
			start_pos = Vector2(randf_range(0, screen_size.x), screen_size.y + padding)
			target_pos = Vector2(randf_range(0, screen_size.x), -padding)
	
	fairy_instance.global_position = start_pos
	fairy_instance.fairy_pressed.connect(display_popup)
	add_child(fairy_instance)
	
	var fly_direction = (target_pos - start_pos).normalized()
	if fairy_instance.has_method("setup_flight"):
		fairy_instance.setup_flight(fly_direction)


func display_popup():
	discount_label.visible = false
	reject_button.visible = false
	purchase = GameState.game_save.player_data.create_fairy_purchase()
	if purchase:
		price_label.text = "Price:\n"+str(purchase.price)
		if purchase.discount:
			discount_label.text = "Discount\n"+str(purchase.discount)
			discount_label.visible = true
		reject_button.visible = true
		accept_button.text = "Buy"
		popup_panel.visible = true
		return
	
	price_label.text = "Money:\n1000"
	accept_button.text = "Claim"
	popup_panel.visible = true


func _on_reject_button_pressed() -> void:
	purchase = null
	popup_panel.visible = false


func _on_accept_button_pressed() -> void:
	if purchase:
		GameState.game_save.player_data.make_purchase(purchase)
	popup_panel.visible = false
	purchase = null
