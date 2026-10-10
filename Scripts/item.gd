extends RigidBody2D
class_name ItemObject

var item : Item = null
@onready var label: Label = %Label
@export var speed:float = 100
@export var direction:Vector2 = Vector2(0,1)
var enrichement_level : float = 0
@export var amount:BigNumber = BigNumber.from_int(1)
@onready var item_sprite: Sprite2D = $ItemSprite
var enrichment_multiplier : BigNumber = BigNumber.from_int(1)

func _ready() -> void:
	_load_save_data()
	
func _physics_process(_delta):
	linear_velocity = direction * speed
	

func sell_item() -> BigNumber:
	queue_free()
	return item.value.multiply_big(enrichment_multiplier.pow_float(enrichement_level)).multiply_big(amount)

func set_direction(new_direction: Vector2):
	direction=new_direction
	linear_velocity=direction*speed
	
func get_baked_texture(atlas_tex: AtlasTexture) -> ImageTexture:
	# 1. Get the raw image of the entire sheet
	var full_image = atlas_tex.atlas.get_image()
	# 2. Cut out just the region defined in your .tres file
	var item_image = full_image.get_region(atlas_tex.region)
	# 3. Create a new texture from that slice
	return ImageTexture.create_from_image(item_image)

func _update_visuals() -> void:
	if item and item.icon is AtlasTexture:
		item_sprite.texture = get_baked_texture(item.icon)
	elif item:
		item_sprite.texture = item.icon
		
func set_data(item_data : Item, item_amount : BigNumber, new_speed : float = 100) -> void:
	speed = new_speed
	item = item_data
	amount = item_amount
	
	if item.icon is AtlasTexture:
		# 1. Set the main sheet as the texture
		item_sprite.texture = item.icon.atlas
		# 2. Enable region and pull the coordinates from the resource
		item_sprite.region_enabled = true
		item_sprite.region_rect = item.icon.region
	else:
		# If it's just a normal PNG, disable region
		item_sprite.region_enabled = false
		item_sprite.texture = item.icon
		
	label.text = amount.format()

func stop():
	direction=Vector2.ZERO

func get_amount() -> BigNumber:
	return amount.multiply_big(enrichment_multiplier)

func _load_save_data():
	pass
