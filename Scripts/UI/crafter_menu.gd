extends ItemList

@export var game : Node2D = null

@onready var outputs_list: ItemList = %OutputList
@onready var ingridients_list: ItemList = %IngridientsList
@onready var upgrade_button: Button = %UpgradeButton
@onready var crafter_container: VBoxContainer = %VBoxContainer

var selected_crafter :Crafter = null

func _ready() -> void:
	set("theme_override_constants/align", 1)
	add_recipies()
	GameState.ui_off.connect(turn_off)
	GameState.crafter_selected.connect(display_crafter_menu)

func display_crafter_menu(crafter:Crafter) -> void:
	crafter_container.visible = true
	selected_crafter=crafter
	if selected_crafter.crafter_data.get_is_enabled():
		upgrade_button.text = "Upgrade: "+selected_crafter.crafter_data.get_upgrade_price().format()
	else:
		upgrade_button.text = "Buy: " + selected_crafter.crafter_data.get_buy_price().format()
		
	for idx in item_count:
		if get_item_text(idx) == crafter.crafter_data.selected_recipe.name:
			select(idx)
			display_recipe()
			break

func add_recipies() -> void:
	for recipe in Recipes.all_recipes:
		add_item(recipe.name ,recipe.icon)


func _on_item_selected(index: int) -> void:
	if selected_crafter:
		selected_crafter.select_recipe(Recipes.all_recipes[index])
		display_recipe()


func _on_swap_direction_button_pressed() -> void:
	if selected_crafter:
		selected_crafter.flip_crafter_node_states()

func display_recipe():
	ingridients_list.clear()
	outputs_list.clear()
	if selected_crafter:
		var recipe : Recipe = selected_crafter.crafter_data.selected_recipe
		for item in recipe.recipe_inputs:
			ingridients_list.add_item(item.name+" "+recipe.recipe_inputs[item].format(),item.icon,false)
		
		for item in recipe.recipe_outputs:
			outputs_list.add_item(item.name+" "+recipe.recipe_outputs[item].format(),item.icon,false)

func _on_upgrade_button_pressed() -> void:
	selected_crafter.upgrade()
	display_crafter_menu(selected_crafter)

func turn_off():
	crafter_container.visible = false


func _on_close_button_pressed() -> void:
	turn_off()
