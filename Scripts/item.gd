extends RigidBody2D
signal item_sold

@export var value:float = 50.0
@export var speed:float = 150
@export var direction:Vector2 = Vector2(0,1)
@export var value_multiplier:float = 1.0

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
	return value*value_multiplier

func set_direction(new_direction: Vector2):
	direction=new_direction
	linear_velocity=direction*speed

func set_data(item:Item)->void:
	value = item.value
	
