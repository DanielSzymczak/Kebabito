extends Button

@export var spawner_id : SpawnerID

var spawner_data : SpawnerData

func _ready() -> void:
	spawner_data = GameState.game_save.spawners[spawner_id.id_name]
	spawner_data.set_up()
	set_label_text()


func _on_pressed() -> void:
	spawner_data.upgrade()
	set_label_text()
	
func set_label_text():
	if spawner_data.get_current_level():
		text = "Upgrade\n"+spawner_data.get_current_cost().format()
	else:
		text = "Buy\n"+spawner_data.get_current_cost().format()
