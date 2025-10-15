extends Marker2D

@export var item_scene:PackedScene = null

func _ready() -> void:
	spawn_item()

func spawn_item():
	for i in range(1111111):
		var new_instance_of_item = item_scene.instantiate()
		add_child(new_instance_of_item)
		await get_tree().create_timer(0.1).timeout
