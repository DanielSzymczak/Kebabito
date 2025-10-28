extends ItemList

@export var recipies : Array[Recipe] = []

@onready var ingridients_list: ItemList = %IngridientsList

var selected_crafter = null

func _ready() -> void:
	add_recipies()

func display_crafter_menu(crafter) -> void:
	selected_crafter=crafter
	for idx in item_count:
		if get_item_text(idx) == crafter.selected_recipe.name:
			print(crafter.selected_recipe.name)
			select(idx)
			display_recipe()
			break

func add_recipies() -> void:
	for recipe in recipies:
		add_item(recipe.name,recipe.icon)


func _on_item_selected(index: int) -> void:
	if selected_crafter:
		selected_crafter.select_recipe(recipies[index])
		display_recipe()


func _on_swap_direction_button_pressed() -> void:
	if selected_crafter:
		selected_crafter.flip_crafter_node_states()

func display_recipe():
	ingridients_list.clear()
	if selected_crafter:
		var recipe : Recipe = selected_crafter.selected_recipe
		for item in recipe.recipe_inputs:
			ingridients_list.add_item(item.name+" "+str(recipe.recipe_inputs[item]).pad_decimals(0),item.icon,false)
