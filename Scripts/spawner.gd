extends Marker2D

@export var items:Array[Item]=[]
@onready var timer: Timer = %Timer

func _ready() -> void:
	timer.timeout.connect(spawn_item)

func spawn_item():
	var rand_integer = randi()%3
	var new_instance_of_item = items[rand_integer].scene.instantiate()
	add_child(new_instance_of_item)
	new_instance_of_item.set_data(items[rand_integer])
 
