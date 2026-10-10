extends PanelContainer
class_name UpgradeButtonUI

@onready var name_label: Label = $MarginContainer/GridContainer/NameLabel
@onready var level_label: Label = $MarginContainer/GridContainer/LevelLabel
@onready var price_label: Label = $MarginContainer/GridContainer/PriceLabel

var currency_data : CurrencyData
var upgrade_statistics : UpgradeStatistics

func _ready() -> void:
	_load_save_data()

# --- SETUP ---
func setup(upgrade_data : UpgradeStatistics) -> void:
	upgrade_statistics = upgrade_data
	update_ui()

func get_cost() -> BigNumber:
	return upgrade_statistics.base_cost.multiply_big(BigNumber.from_float(upgrade_statistics.level_price_increase).pow_float(upgrade_statistics.current_level)).floor_self()
	
	
# --- UI ---
func update_ui() -> void:
	name_label.text = upgrade_statistics.name
	if upgrade_statistics.has_max_level():
		level_label.text = "Level: %d / %d" % [upgrade_statistics.current_level, upgrade_statistics.max_level]
	else:
		level_label.text = "Level: %d" % upgrade_statistics.current_level
	price_label.text = "Cost: %s" % get_cost().format()

# --- UPGRADE LOGIC ---
func _on_upgrade_button_pressed() -> void:
	upgrade_statistics.upgrade()
	update_ui()

func _load_save_data():
	currency_data = GameState.game_save.currency_data
