extends Marker2D

@export var items:Array[Item]=[]
@onready var timer: Timer = %Timer

func _ready() -> void:
	timer.timeout.connect(func(): spawn_item(items[0]))

func spawn_item(item:Item, location:Vector2 = self.global_position, direction = Vector2(0,1)):
	var new_instance_of_item = item.scene.instantiate()
	add_child(new_instance_of_item)
	new_instance_of_item.set_data(item)
	new_instance_of_item.global_position=location
	new_instance_of_item.set_direction(direction)
 
