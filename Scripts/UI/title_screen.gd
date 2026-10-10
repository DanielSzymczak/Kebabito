extends Control
@onready var background: TextureRect = $Background
@onready var title_control: Control = $TitleControl
@onready var door: TextureRect = $Background/Door
@onready var kebab: TextureRect = $Background/Kebab
@onready var button_label: Label = $Button/ButtonLabel
@onready var button: Button = $Button

@export var marker1: Marker2D
@export var marker2: Marker2D
@export var marker3: Marker2D


@export var wave_height: float = 20.0
@export var wave_duration: float = 2.0 # Increased from 1.0 to 3.0 to make it much slower
@export var wave_offset: float = 0.25   # Slightly increased to match the slower speed
@export var seconds_to_wait : float = 0.5
@export var door_closing_time : float = 1
@export var title_left_padding: float = 0
@export var kebab_speed: float = 100.0
func _ready() -> void:
	fade_in_button_text()
	start_intro_sequence()

func start_intro_sequence() -> void:
	# 1. Slide the background up first
	#await get_tree().create_timer(seconds_to_wait).timeout
	await slide_background_up()
	
	# 2. Slide the title control to the left side of the screen
	await slide_title_left()
	
	# 3. Start the text wave effect once everything is in position
	animate_wave()
	spawn_kebab(5)
	
	
func slide_background_up() -> void:
	var screen_height := get_viewport_rect().size.y
	var graphic_height := background.size.y
	var target_y := screen_height - graphic_height
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(background, "position:y", target_y, 3)
	await tween.finished

func move_kebab_to_marker(target_marker: Marker2D) -> void:
	if not target_marker:
		return
		
	# 1. Calculate the distance between the kebab's current position and the marker
	var distance = kebab.global_position.distance_to(target_marker.global_position)
	
	# 2. Math: Time = Distance / Speed
	var dynamic_duration = distance / kebab_speed
	
	# 3. Use that calculated time inside your tween
	var tween = create_tween()
	# TRANS_LINEAR ensures it moves at a completely uniform, unchanging speed
	tween.set_trans(Tween.TRANS_LINEAR) 
	
	tween.tween_property(kebab, "global_position", target_marker.global_position, dynamic_duration)
	await tween.finished

func animate_wave() -> void:
	var children = title_control.get_children()
	var total_children = children.size()
	
	# Loop backwards: from the last child down to 0
	for i in range(total_children - 1, -1, -1):
		var child = children[i] as Control
		if not child: continue
		
		var distance_from_end = (total_children - 1) - i
		var initial_delay = distance_from_end * wave_offset
		
		if initial_delay > 0:
			var delay_tween = create_tween()
			delay_tween.tween_interval(initial_delay)
			delay_tween.tween_callback(start_looping_wave.bind(child))
		else:
			start_looping_wave(child)

func start_looping_wave(child: Control) -> void:
	var tween = create_tween().set_loops()
	
	# TRANS_SINE + EASE_IN_OUT makes it slow down perfectly at the top and bottom peaks
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	var start_y = child.position.y
	var half_time = wave_duration / 2.0
	
	# --- SIMPLE DOWN & UP SEQUENCE ---
	# 1. Smoothly ease DOWN from the starting position
	tween.tween_property(child, "position:y", start_y + wave_height, half_time)
	
	# 2. Smoothly ease back UP to the exact starting position
	tween.tween_property(child, "position:y", start_y, half_time)
	
	
func slide_title_left() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# We move the position.x property to our left padding value
	tween.tween_property(title_control, "position:x", title_left_padding, 1.5)
	
	await tween.finished # Pause function execution until title arrives at the left
	
func open_door() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	var target_y = door.position.y - door.size.y
	
	tween.tween_property(door, "position:y", target_y, 1.5)
	await tween.finished

func close_door() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	var target_y = door.position.y + door.size.y
	
	tween.tween_property(door, "position:y", target_y, 1.5)
	await tween.finished

func set_kebab_z_position(marker : Marker2D):
	kebab.z_index=marker.z_index

func spawn_kebab(seconds_wait:float):
	while true:
		if marker1:
			set_kebab_z_position(marker1)
			kebab.global_position = marker1.global_position
		
		await open_door()
		
		await move_kebab_to_marker(marker2)
		set_kebab_z_position(marker2)
		move_kebab_to_marker(marker3) 
		await get_tree().create_timer(door_closing_time).timeout

		await close_door()
		await get_tree().create_timer(seconds_wait).timeout
	

func fade_in_button_text():
	await get_tree().create_timer(10.0).timeout
	
	if not button_label: 
		return
		
	# 1. Start completely invisible
	button_label.modulate.a = 0.0
	
	# 2. Run the initial clean fade-in to 100% visibility (1.0 alpha)
	var intro_tween = create_tween()
	intro_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	intro_tween.tween_property(button_label, "modulate:a", 1.0, 1.5)
	
	# 3. Once the intro fade finishes, start the continuous oscillation loop
	intro_tween.tween_callback(start_visibility_oscillation)

func start_visibility_oscillation():
	# Create an infinite looping tween
	var loop_tween = create_tween().set_loops()
	loop_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Set the duration for a half-cycle (time to fade down or fade up)
	var pulse_duration = 1.0 # Adjust this to make the pulsing faster or slower
	
	# --- THE OSCILLATION SEQUENCE ---
	# Fade down to 75% visibility
	loop_tween.tween_property(button_label, "modulate:a", 0.5, pulse_duration)
	# Fade back up to 100% visibility
	loop_tween.tween_property(button_label, "modulate:a", 1.0, pulse_duration)

func _on_button_pressed() -> void:
	button.disabled=true
	GameState.load_game()
	Transition.transition_to_scene("res://Scenes/game.tscn")
	
