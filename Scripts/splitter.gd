extends Node2D
class_name Splitter

@export var id : SplitterID
@export var begining_navigation_node : Marker2D
@export var ending_navigation_node : Marker2D
@export var game:Node2D = null

var press_time := 0.0
var pressed_inside := false
var splitter_data : SplitterData

const MAX_TAP_TIME := 0.25

func _ready() -> void:
	_load_save_data()

func add_item(item_to_add : Item , mode : GameEnums.SPLITTER_MODE):
	if mode == GameEnums.SPLITTER_MODE.BACKWARD:
		splitter_data.backward_items_set[item_to_add]=true
	if mode == GameEnums.SPLITTER_MODE.FORWARD:
		splitter_data.forward_items_set[item_to_add]=true
	update_navigation_nodes()
	pass
	
func remove_item(item_to_remove : Item , mode : GameEnums.SPLITTER_MODE):
	if mode == GameEnums.SPLITTER_MODE.BACKWARD:
		splitter_data.backward_items_set[item_to_remove]=false
	if mode == GameEnums.SPLITTER_MODE.FORWARD:
		splitter_data.forward_items_set[item_to_remove]=false
	update_navigation_nodes()
	pass
	
func update_navigation_nodes():
	begining_navigation_node.set_navigation_items(splitter_data.forward_items_set)
	ending_navigation_node.set_navigation_items(splitter_data.backward_items_set)
	pass


func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		
		if event.pressed:
			pressed_inside = true
			press_time = Time.get_ticks_msec()
		
		else:
			if pressed_inside:
				var duration := (Time.get_ticks_msec() - press_time) / 1000.0
				
				if duration <= MAX_TAP_TIME:
					GameState.select_splitter(self)
			
			pressed_inside = false

func _load_save_data():
	splitter_data = GameState.game_save.splitters[id.id_name]
	splitter_data.refresh_node_data.connect(update_navigation_nodes)
	
func get_forward_list() -> Dictionary[Item, bool]:
	return splitter_data.forward_items_set
	
func get_backward_list() -> Dictionary[Item, bool]:
	return splitter_data.backward_items_set
