extends Resource
class_name Recipe

@export var recipe_inputs: Dictionary[Item, float] = {}
@export var recipe_outputs: Dictionary[Item, float] = {}
@export var icon : AtlasTexture = null
@export var name : String = ""

var recipe_input_string_dict: Dictionary[String, float]
var recipe_output_string_dict: Dictionary[String, float]

func get_input_dict() -> Dictionary[String, float]:
	if recipe_input_string_dict.is_empty():
		recipe_input_string_dict = _convert_dict(recipe_inputs)
	return recipe_input_string_dict

func get_output_dict() -> Dictionary[String, float]:
	if recipe_output_string_dict.is_empty():
		recipe_output_string_dict = _convert_dict(recipe_outputs)
	return recipe_output_string_dict

func _convert_dict(source: Dictionary[Item, float]) -> Dictionary[String, float]:
	var dict: Dictionary[String, float] = {}
	for item in source.keys():
		dict[item.name if item else str(item)] = source[item]
	return dict
