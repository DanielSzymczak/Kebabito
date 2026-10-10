extends TextureRect

@export var speed: float = 200.0
@export var wave_frequency: float = 5.0 
@export var wave_amplitude: float = 30.0 

signal fairy_pressed

var direction: Vector2 = Vector2.ZERO
var perpendicular_direction: Vector2 = Vector2.ZERO
var time_passed: float = 0.0
var base_position: Vector2 = Vector2.ZERO

func setup_flight(target_direction: Vector2):
	direction = target_direction
	base_position = global_position
	
	# Calculate a vector perpendicular (90 degrees) to the flight direction
	# This ensures the wave works whether flying horizontally, vertically, or diagonally!
	perpendicular_direction = Vector2(-direction.y, direction.x).normalized()

func _process(delta: float) -> void:
	if direction == Vector2.ZERO:
		return
		
	time_passed += delta
	
	# 1. Move the invisible "base track" straight forward
	base_position += direction * speed * delta
	
	# 2. Calculate the sine offset (-1.0 to 1.0 multiplied by amplitude)
	var wave_offset = sin(time_passed * wave_frequency) * wave_amplitude
	
	# 3. Combine them: Base track position + Perpendicular wave offset
	global_position = base_position + (perpendicular_direction * wave_offset)

# Clean up memory when the fairy leaves the screen completely
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_button_pressed() -> void:
	fairy_pressed.emit()
	queue_free()
