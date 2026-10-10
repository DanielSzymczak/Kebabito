extends Resource
class_name SplitterData

signal refresh_node_data

@export var id : String 
@export var backward_items_set: Dictionary[Item, bool] = {}
@export var forward_items_set: Dictionary[Item, bool] = {}

func revert():
	for item in backward_items_set:
		backward_items_set[item]=false
		forward_items_set[item]=false
	refresh_node_data.emit()
