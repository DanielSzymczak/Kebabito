@tool
extends Node
class_name Recipes

# 1. The variables define the order. Arrange these however you like.
static var kebab_plate_recipe: Recipe
static var shish_kebab_recipe: Recipe
static var baklava_recipe: Recipe
static var kebab_box_recipe: Recipe
static var packed_kebab_recipe: Recipe
static var onigiri_recipe: Recipe
# This array will be populated in the order above.
static var all_recipes: Array[Recipe] = []

static func _static_init() -> void:
	var script_path = "res://data/recipes/" 
	var dir = DirAccess.open(script_path)
	
	if dir:
		# Reset data
		all_recipes.clear()
		
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".tres"):
				# Load the resource
				var res = load(script_path + file_name)
				if res is Recipe:
					# Match the file name (e.g., "baklava_recipe") to the static variable
					var var_name = file_name.get_basename()
					if var_name in Recipes:
						Recipes[var_name] = res
			
			file_name = dir.get_next()
		
		# 2. MANUALLY CONSTRUCT THE ARRAY
		# This is where you set the "Source of Truth" for your ordering.
		all_recipes = [
			kebab_plate_recipe,
			baklava_recipe,
			shish_kebab_recipe,
			kebab_box_recipe,
			packed_kebab_recipe,
			onigiri_recipe
		]
		
		# 3. Clean up the array 
		# Removes any nulls in case a .tres file was missing or renamed
		all_recipes = all_recipes.filter(func(r): return r != null)

		print("--- Recipes Registry Initialization ---")
		for r in all_recipes:
			# This will now print in your custom order
			print("Loaded Recipe: ", r.resource_path.get_file().get_basename())
		
		print("Total Recipes Ordered: ", all_recipes.size())
		print("---------------------------------------")
	else:
		push_error("Recipes Registry Error: Could not open path " + script_path)
