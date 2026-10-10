extends Resource
class_name UpgradeData

@export var money_upgrades : Dictionary = {}
@export var prestige_upgrades : Dictionary = {}

func revert():
	for upgrade in money_upgrades:
		money_upgrades[upgrade].revert()
