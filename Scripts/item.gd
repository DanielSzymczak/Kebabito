extends RigidBody2D
class_name Item
signal item_sold

@export var value:float = 50.0
@export var speed:float = 150
@export var direction:Vector2 = Vector2(0,1)

var last_position: Vector2 = Vector2(0, 0)
var last_direction: Vector2 = Vector2(0, 0)
const ACCEPTABLE_DISTANCE = 3

func _physics_process(_delta: float) -> void:
	pass
	
func _ready() -> void:
	set_direction(direction)

func sell_item() -> float:
	item_sold.emit()
	queue_free()
	return value

func set_direction(new_direction: Vector2):
	direction=new_direction
	linear_velocity=direction*speed

func move_to_position(pos: Vector2, change_visibility: bool):
	last_position = global_position + direction * min(speed, 50)
	while distance_to(pos) > ACCEPTABLE_DISTANCE:
		linear_velocity = (pos - global_position).normalized() * speed
		await get_tree().create_timer(0.01).timeout
	linear_velocity = Vector2(0, 0)
	if change_visibility:
		visible = false

func move_to_last_position():
	visible = true
	while distance_to(last_position) > ACCEPTABLE_DISTANCE:
		linear_velocity = (last_position - global_position).normalized() * speed
		await get_tree().create_timer(0.01).timeout
	set_direction(direction)

func distance_to(to: Vector2) -> float:
	return (to - global_position).length()
