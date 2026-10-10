class_name Item
extends Resource

@export var id : ItemID:
	set(value):
		id = value
		if id:
			name = id.id_name

var name: String = ""
@export var icon: AtlasTexture
@export var value: BigNumber
@export var enriching_time_units : BigNumber
var scene: PackedScene = load("res://Scenes/items/item.tscn")
