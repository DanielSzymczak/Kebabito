extends VBoxContainer

@export var game : Game = null

@onready var upgrade_button_list: VBoxContainer = %UpgradeButtonList
var UpgradeUIScene := preload("res://Scenes/UI/upgrade_button_ui.tscn")
var StackUpgradeUIScene := preload("res://Scenes/UI/stack_upgrade_button_ui.tscn")
var PrestigeButtonScene := preload("res://Scenes/UI/prestige_ui.tscn")
var mode_group := ButtonGroup.new()
@onready var prestige_button: Button = $UpgradeMenu/PrestigeButton
@onready var store_button: Button = $UpgradeMenu/StoreButton
@onready var stack_button: Button = $UpgradeMenu/StackButton
@onready var premium_buton: Button = $UpgradeMenu/PremiumButon

@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var options_layer: CanvasLayer = %OptionsLayer

func get_store_upgrade_dict() -> Dictionary:
	return GameState.game_save.game_upgrades.money_upgrades

var prestige_upgrade_dict : Dictionary
var stack_upgrade_data : ItemStackData

enum CONTENTS_INDEX {
	PRESTIGE,
	STORE,
	STACK,
	PREMIUM
}

func _ready():
	if not GameState.is_node_ready():
		await GameState.ready
	_load_save_data()
	prestige_button.button_group = mode_group
	store_button.button_group = mode_group
	stack_button.button_group = mode_group
	premium_buton.button_group = mode_group
	prestige_button.pressed.connect(_on_mode_changed)
	store_button.pressed.connect(_on_mode_changed)
	stack_button.pressed.connect(_on_mode_changed)
	premium_buton.pressed.connect(_on_mode_changed)

func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if !(prestige_button.button_pressed or store_button.button_pressed or stack_button.button_pressed or premium_buton.button_pressed):
			store_button.button_pressed=true
			display_contents(CONTENTS_INDEX.STORE)
		upgrade_button_list.visible = true
		store_button.visible = true
		prestige_button.visible = true
		scroll_container.visible = true
		stack_button.visible = true
		premium_buton.visible = true
		return
	upgrade_button_list.visible = false
	store_button.visible = false
	prestige_button.visible = false
	scroll_container.visible = false
	stack_button.visible = false
	premium_buton.visible = false

func _on_upgrade_list_item_selected(index: int) -> void:
	display_contents(index)

func display_contents(index: CONTENTS_INDEX):
	for child in upgrade_button_list.get_children():
		child.queue_free()
	
	if index == CONTENTS_INDEX.STACK:
		for item_name in stack_upgrade_data.item_stack_level.keys():
			var ui: StackUpgradeButtonUI = StackUpgradeUIScene.instantiate()
			upgrade_button_list.add_child(ui)
			ui.setup(item_name)
			
	var upgrade_dict : Dictionary
	if index == CONTENTS_INDEX.STORE:
		upgrade_dict = get_store_upgrade_dict()
	elif index == CONTENTS_INDEX.PRESTIGE:
		upgrade_dict = prestige_upgrade_dict
		var p = PrestigeButtonScene.instantiate()
		upgrade_button_list.add_child(p)
		print("menu", GameState.game_save.currency_data.get_total_earnings().format())
		p.set_up()
		
	for entry in upgrade_dict.values():
		var ui: UpgradeButtonUI = UpgradeUIScene.instantiate()
		upgrade_button_list.add_child(ui)
		ui.setup(entry)


func _on_mode_changed():
	if prestige_button.button_pressed:
		display_contents(CONTENTS_INDEX.PRESTIGE)
	elif store_button.button_pressed:
		display_contents(CONTENTS_INDEX.STORE)
	elif stack_button.button_pressed:
		display_contents(CONTENTS_INDEX.STACK)
	elif premium_buton.button_pressed:
		display_contents(CONTENTS_INDEX.PREMIUM)

func _load_save_data():
	prestige_upgrade_dict = GameState.game_save.game_upgrades.prestige_upgrades
	stack_upgrade_data = GameState.game_save.stack_data

func _on_options_button_button_down() -> void:
	options_layer.visible = true
