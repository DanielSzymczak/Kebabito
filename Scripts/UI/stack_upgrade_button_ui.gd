extends PanelContainer
class_name StackUpgradeButtonUI
@onready var texture_rect: TextureRect = $MarginContainer/GridContainer/VBoxContainer/TextureRect/TextureRect
@onready var amount_label: Label = $MarginContainer/GridContainer/VBoxContainer/AmountLabel
@onready var value_label: Label = $MarginContainer/GridContainer/VBoxContainer2/ValueLabel
@onready var upgrade_button: Button = $MarginContainer/GridContainer/VBoxContainer2/UpgradeButton
@onready var price_label: Label = $MarginContainer/GridContainer/VBoxContainer2/PriceLabel

var item_name : String
var currency_data : CurrencyData
var item_stack_data : ItemStackData

func _ready() -> void:
	_load_save_data()

func setup(item_name_string : String) -> void:
	item_name = item_name_string
	update_ui()

func get_cost() -> BigNumber:
	return item_stack_data.get_cost(item_name)
	
func update_ui() -> void:
	texture_rect.texture = Items.get_item_by_name(item_name).icon
	amount_label.text = "Capacity: %s" % item_stack_data.get_stack_amount(item_name).format()
	price_label.text = "Cost: %s" % get_cost().format()
	value_label.text = "Value: %s" % Items.get_item_by_name(item_name).value.format()

func _on_upgrade_button_pressed() -> void:
	item_stack_data.upgrade(item_name)
	update_ui()

func _load_save_data():
	currency_data = GameState.game_save.currency_data
	item_stack_data = GameState.game_save.stack_data
