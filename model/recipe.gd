extends Resource
class_name Recipe

@export var recipe_inputs: Dictionary[Item, BigNumber] = {}
@export var recipe_outputs: Dictionary[Item, BigNumber] = {}
@export var icon : AtlasTexture = null
@export var name : String = ""
@export var crafting_time_units : BigNumber


func get_input_dict() -> Dictionary[Item, BigNumber]:
	return recipe_inputs

func get_output_dict() -> Dictionary[Item, BigNumber]:
	return recipe_outputs

func get_input_dict_strings() -> Dictionary[String, BigNumber]:
	var dict: Dictionary[String, BigNumber] = {}
	for item in recipe_inputs.keys():
		dict[item.name if item else str(item)] = recipe_inputs[item]
	return dict

func get_output_dict_strings() -> Dictionary[String, BigNumber]:
	var dict: Dictionary[String, BigNumber] = {}
	for item in recipe_outputs.keys():
		dict[item.name if item else str(item)] = recipe_outputs[item]
	return dict
	
func _convert_dict(source: Dictionary[Item, BigNumber]) -> Dictionary[String, BigNumber]:
	var dict: Dictionary[String, BigNumber] = {}
	for item in source.keys():
		dict[item.name if item else str(item)] = source[item]
	return dict
	
func get_input(item_name : String) -> BigNumber:
	for item in recipe_inputs:
		if item.name == item_name:
			return recipe_inputs[item]
	return BigNumber.new()

func get_output(item_name : String) -> BigNumber:
	for item in recipe_outputs:
		if item.name == item_name:
			return recipe_outputs[item]
	return BigNumber.new()
	
func get_input_value_at_index(index : int) -> BigNumber:
	var values = recipe_inputs.values()
	if index >= 0 and index < values.size():
		return values[index]
	return BigNumber.new(0.0, 0)
	
func get_output_value_at_index(index : int) -> BigNumber:
	var values = recipe_outputs.values()
	if index >= 0 and index < values.size():
		return values[index]
	return BigNumber.new(0.0, 0)
	
func get_input_key_at_index(index : int) -> String:
	var keys = get_input_dict_strings().keys()
	if index >= 0 and index < keys.size():
		return keys[index]
	return ""
	
func get_output_key_at_index(index : int) -> String:
	var keys = get_output_dict_strings().keys()
	if index >= 0 and index < keys.size():
		return keys[index]
	return ""
