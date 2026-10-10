extends CanvasLayer

@onready var door_left: TextureRect = $DoorLeft
@onready var door_right: TextureRect = $DoorRight
@onready var wheel: TextureRect = $DoorRight/Wheel

var door_right_closed_X = 0.0
var door_right_opened_X = 692.0
var door_left_closed_X = 0.0
var door_left_opened_X = -577.0

func _ready() -> void:
	pass

func transition_to_scene(target_scene_path: String) -> void:	
	visible = true
	door_left.position.x = door_left_opened_X
	door_right.position.x = door_right_opened_X
	
	# 1. Close Doors
	var close_tween = create_tween()
	close_tween.set_parallel(true)
	close_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	close_tween.tween_property(door_left, "position:x", door_left_closed_X, 1.0)
	close_tween.tween_property(door_right, "position:x", door_right_closed_X, 1.0)
	await close_tween.finished

	# 2. Spin Wheel
	var wheel_tween = create_tween()
	var spin_amount = wheel.rotation + (TAU * 1) 
	wheel_tween.tween_property(wheel, "rotation", spin_amount, 0.5)
	await wheel_tween.finished
	
	# 3. Change the scene behind the closed doors!
	get_tree().change_scene_to_file(target_scene_path)
	
	# Wait 2 frames instead of 1 just to give heavy UI scenes an extra microsecond to instantiate 
	# behind the curtain before opening up
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 4. Open Doors
	var open_tween = create_tween()
	open_tween.set_parallel(true)
	open_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	open_tween.tween_property(door_left, "position:x", door_left_opened_X, 1.0)
	open_tween.tween_property(door_right, "position:x", door_right_opened_X, 1.0)
	await open_tween.finished
	visible = false
