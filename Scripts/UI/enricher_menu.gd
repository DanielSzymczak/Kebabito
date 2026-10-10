extends VBoxContainer
@onready var enricher_item_list: ItemList = %EnricherItemList
@onready var upgrade_button: Button = $SplitterContainer/MarginContainer/HBoxContainer2/VBoxContainer/UpgradeButton
@onready var time_label: Label = $SplitterContainer/MarginContainer/HBoxContainer2/VBoxContainer/TimeLabel
@export var enrichers_enabled_id : UpgradeID
var selected_enricher : Enricher
var enrichers_enabled_upgrade : UpgradeStatistics

func _ready() -> void:
	GameState.ui_off.connect(turn_off)
	GameState.enricher_selected.connect(display_enricher_data)
	enrichers_enabled_upgrade = GameState.game_save.game_upgrades.prestige_upgrades[enrichers_enabled_id.id_name]

func turn_off():
	visible = false

func _on_close_button_pressed() -> void:
	turn_off()

func display_enricher_data(enricher : Enricher):
	if !enrichers_enabled_upgrade.get_current_level():
		turn_off()
		return
	enricher_item_list.clear()
	var selected_item = enricher.get_selected_item()
	var item_array = ItemsRegistry.all_items
	for i in range(item_array.size()):
		enricher_item_list.add_item(item_array[i].name, item_array[i].icon)
		
		if item_array[i].name == selected_item.name:
			enricher_item_list.select(i, true)
			
	selected_enricher = enricher
	if selected_enricher.enricher_data.get_is_enabled():
		upgrade_button.text = "upgrade: %s" % selected_enricher.enricher_data.get_upgrade_price().format()
	else:
		upgrade_button.text = "Buy: %s" % selected_enricher.enricher_data.get_buy_price().format()
	time_label.text = "Enrich Time:\n%s" % selected_enricher.enricher_data.get_item_enriching_time().format_time()

	visible = true


func _on_enricher_item_list_item_selected(index: int) -> void:
	selected_enricher.select_item(ItemsRegistry.all_items[index])
	display_enricher_data(selected_enricher)



func _on_upgrade_button_pressed() -> void:
	selected_enricher.upgrade()
	display_enricher_data(selected_enricher)


func _on_swap_diection_button_pressed() -> void:
	selected_enricher.flip_crafter_node_states()
