extends CanvasLayer
@onready var close_button: Button = $Control/NinePatchRect/MarginContainer/VBoxContainer/PanelContainer/CloseButton


func _on_quit_button_pressed() -> void:
	GameState.save_game()
	get_tree().quit()


func _on_close_button_pressed() -> void:
	visible = false
