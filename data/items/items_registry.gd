@tool
extends Node
class_name Items

# Autocomplete / Static references
static var small_rollo_id : ItemID = load("res://model/ID's/item/small_rollo_ID.tres")
static var kebab_plate_id : ItemID = load("res://model/ID's/item/kebab_plate_ID.tres")
static var baklava_id : ItemID = load("res://model/ID's/item/baklava_ID.tres")
static var shish_kebab_id : ItemID = load("res://model/ID's/item/shish_kebab_ID.tres")
static var kebab_box_id : ItemID = load("res://model/ID's/item/kebab_box_ID.tres")
static var onigiri_id : ItemID = load("res://model/ID's/item/onigiri_ID.tres")
static var packed_kebab

# 1. Define your exact desired order here
static var ordered_ids: Array[ItemID] = [
	small_rollo_id,
	kebab_plate_id,
	baklava_id,
	shish_kebab_id,
	kebab_box_id,
	onigiri_id
]

static var all_items: Array[Item] = []
# Key: String (from id_name), Value: Item Resource
static var item_map: Dictionary[String, Item] = {} 

static func _static_init() -> void:
	print("item registry init")
	var script_path = "res://data/items/"
	var dir = DirAccess.open(script_path)
	if dir:
		item_map.clear()
		all_items.clear()
		
		# Step A: Load everything into the Dictionary first
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var res = load(script_path + "/" + file_name) as Item
				if res and res.id:
					var key = res.id.id_name
					item_map[key] = res
			file_name = dir.get_next()
			
		# Step B: Populate all_items using the exact order of your static variables
		for target_id in ordered_ids:
			if target_id and item_map.has(target_id.id_name):
				all_items.append(item_map[target_id.id_name])
				
		# Step C: Safety Catch-All 
		# If you create a new item in the folder but forget to add it to 
		# the 'ordered_ids' array above, this ensures it still gets added to the very end.
		for key in item_map:
			var item = item_map[key]
			if not all_items.has(item):
				all_items.append(item)
				
	print(item_map.keys())

# --- The Helper Method ---
static func get_item(item_id: ItemID) -> Item:
	if item_id == null: return null
	return get_item_by_name(item_id.id_name)

static func get_item_by_name(item_name: String) -> Item:
	if item_map.has(item_name):
		return item_map[item_name]
	
	if not Engine.is_editor_hint():
		printerr("Items Registry: No item found for name '", item_name, "'")
	return null
