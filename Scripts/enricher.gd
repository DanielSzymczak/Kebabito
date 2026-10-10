extends Node2D
class_name Enricher
@onready var spiral_sprite: AnimatedSprite2D = $SpiralSprite
@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var animated_sprite_2d_2: AnimatedSprite2D = $AnimatedSprite2D2
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var direction_sprite: Sprite2D = $DirectionSprite

@export var id : EnricherID
@export var navigate_clockwise : bool = false
var enricher_data : EnricherData
@export var enricher_navigation_nodes:Array[EnricherNavigatorNode] = []
var press_time := 0.0
var pressed := false
const MAX_TAP_TIME := 0.25

func _ready() -> void:
	enricher_data = GameState.game_save.enrichers[id.id_name]
	enricher_data.set_up()
	setup_navigation_nodes()
	if enricher_data.get_is_enabled():
		spiral_sprite.play("spiral_animation")
	else:
		enricher_navigation_nodes[enricher_data.input_index].is_busy = true
		enricher_navigation_nodes[enricher_data.output_index].is_busy = true
		modulate = Color(0.5, 0.5, 0.5)
	if enricher_data.input_index == 1:
		direction_sprite.flip_h = !direction_sprite.flip_h

func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	if body.item.name == enricher_data.selected_item.name:
		enrich(body)

func flip_crafter_node_states():
	var temp = enricher_data.input_index
	enricher_data.input_index = enricher_data.output_index
	enricher_data.output_index = temp
	direction_sprite.flip_h = !direction_sprite.flip_h
	refresh_node_data()
	
func enrich(body : ItemObject):
	body.stop()
	animated_sprite_2d.play("enriching")
	animated_sprite_2d_2.play("enriching")
	var ratio_bn = enricher_data.get_item_enriching_time()
	var wait_time = ratio_bn.to_float()
	progress_bar.value = 0
	progress_bar.max_value = wait_time
	progress_bar.show()
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", wait_time, wait_time)
	await get_tree().create_timer(wait_time).timeout
	body.enrichement_level += 1
	progress_bar.hide()
	body.enrichment_multiplier = enricher_data.get_enrichment_multiplier()
	body.set_direction(enricher_navigation_nodes[enricher_data.input_index].navigate_to(enricher_navigation_nodes[enricher_data.output_index]))
	animated_sprite_2d.pause()
	animated_sprite_2d_2.pause()
	enricher_navigation_nodes[enricher_data.input_index].is_busy = false
	enricher_navigation_nodes[enricher_data.output_index].is_busy = false

func setup_navigation_nodes():
	enricher_navigation_nodes[0].is_busy = false
	enricher_navigation_nodes[1].is_busy = false
	if navigate_clockwise:
		enricher_navigation_nodes[0].regular_direction = Vector2.UP.rotated(rotation)
		enricher_navigation_nodes[1].regular_direction = Vector2.DOWN.rotated(rotation)
	else:
		enricher_navigation_nodes[0].regular_direction = Vector2.DOWN.rotated(rotation)
		enricher_navigation_nodes[1].regular_direction = Vector2.UP.rotated(rotation)
	refresh_node_data()

	select_item(enricher_data.selected_item)
	
func select_item(item : Item):
	enricher_data.selected_item = item
	enricher_navigation_nodes[0].selected_item = item
	enricher_navigation_nodes[1].selected_item = item

func get_selected_item() -> Item:
	return enricher_data.selected_item

func upgrade():
	enricher_data.upgrade()
	refresh_node_data()
	if enricher_data.get_is_enabled():
		enricher_navigation_nodes[enricher_data.input_index].is_busy = false
		enricher_navigation_nodes[enricher_data.output_index].is_busy = false
		modulate = Color(1,1,1)
		spiral_sprite.play("spiral_animation")
	
func refresh_node_data():
	enricher_navigation_nodes[enricher_data.input_index].max_enrichment_level = enricher_data.get_max_enrichment_level()
	enricher_navigation_nodes[enricher_data.output_index].max_enrichment_level = enricher_data.get_max_enrichment_level()
	enricher_navigation_nodes[enricher_data.input_index].current_state = GameEnums.STATE.INPUT
	enricher_navigation_nodes[enricher_data.output_index].current_state = GameEnums.STATE.OUTPUT
func _on_clickable_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		
		if event.pressed:
			press_time = Time.get_ticks_msec()
			pressed = true
		
		else:
			if not pressed:
				return
			
			pressed = false
			
			var duration := (Time.get_ticks_msec() - press_time) / 1000.0
			
			if duration <= MAX_TAP_TIME:
				GameState.select_enricher(self)
