extends ScrollContainer

var dragging := false
var last_pos := Vector2.ZERO
var active_touch := -1

func _gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			dragging = true
			active_touch = event.index
			last_pos = event.position
			get_viewport().set_input_as_handled()
		else:
			if event.index == active_touch:
				dragging = false
				active_touch = -1

	elif event is InputEventScreenDrag and dragging:
		if event.index != active_touch:
			return

		var delta = event.position - last_pos
		last_pos = event.position

		scroll_vertical -= delta.y
		scroll_horizontal -= delta.x
		get_viewport().set_input_as_handled()
