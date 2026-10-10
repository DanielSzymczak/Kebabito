extends HBoxContainer

var selected_splitter : Splitter = null

@onready var backward_list: ItemList = %BackwardList
@onready var forward_list: ItemList = %ForwardList
@onready var splitter_container: VBoxContainer = %VBoxContainer2

func _ready() -> void:
	GameState.ui_off.connect(turn_off)
	GameState.splitter_selected.connect(display_splitter_menu)

var _active_items: Array[Item] = []

func display_splitter_menu(splitter: Splitter):
	selected_splitter = splitter
	backward_list.clear()
	forward_list.clear()
	
	var b_data = splitter.get_backward_list()
	var f_data = splitter.get_forward_list()

	_active_items.assign(b_data.keys())
	
	for i in range(_active_items.size()):
		var item: Item = _active_items[i]
		
		backward_list.add_item(item.name, item.icon)
		forward_list.add_item(item.name, item.icon)
		
		# Set selection based on the boolean values in the dictionaries
		if b_data[item]:
			backward_list.select(i, false)
		if f_data[item]:
			forward_list.select(i, false)
			
	splitter_container.visible = true
	
func turn_off():
	splitter_container.visible = false	
	_active_items.clear() # Clean up when menu closes

func _on_backward_list_multi_selected(index: int, selected: bool) -> void:
	var item = _active_items[index]
	
	if selected:
		selected_splitter.add_item(item, GameEnums.SPLITTER_MODE.BACKWARD)
		selected_splitter.remove_item(item, GameEnums.SPLITTER_MODE.FORWARD)
		forward_list.deselect(index)
	else:
		selected_splitter.remove_item(item, GameEnums.SPLITTER_MODE.BACKWARD)
	

func _on_forward_list_multi_selected(index: int, selected: bool) -> void:
	var item = _active_items[index]
	
	if selected:
		selected_splitter.add_item(item, GameEnums.SPLITTER_MODE.FORWARD)
		selected_splitter.remove_item(item, GameEnums.SPLITTER_MODE.BACKWARD)
		backward_list.deselect(index)
	else:
		selected_splitter.remove_item(item, GameEnums.SPLITTER_MODE.FORWARD)


func _on_close_button_pressed() -> void:
	turn_off()
