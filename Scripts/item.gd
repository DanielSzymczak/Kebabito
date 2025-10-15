extends RigidBody2D
class_name Item
signal item_sold

@export var value:float = 50.0
@export var speed:float = 150
@export var direction:Vector2 = Vector2(0,1)

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
