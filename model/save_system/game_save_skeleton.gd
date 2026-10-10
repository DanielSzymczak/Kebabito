extends Resource
class_name GameSave

@export var spawners: Dictionary[String,SpawnerData] = {}
@export var splitters : Dictionary[String,SplitterData] = {}
@export var crafters : Dictionary[String,CrafterData] = {}
@export var stack_data : ItemStackData = ItemStackData.new()
@export var game_upgrades : UpgradeData = UpgradeData.new()
@export var currency_data : CurrencyData = CurrencyData.new()
@export var enrichers : Dictionary[String,EnricherData] = {}
@export var player_data : PlayerData = PlayerData.new()
