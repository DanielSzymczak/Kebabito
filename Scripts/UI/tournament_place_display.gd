extends Control
class_name LeaderboardEntry
var score = BigNumber.new()
var tournament :TournamentData = null
@onready var position_label: Label = $NinePatchRect/MarginContainer/HBoxContainer/PositionLabel
@onready var name_label: Label = $NinePatchRect/MarginContainer/HBoxContainer/NameLabel
@onready var earned_label: Label = $NinePatchRect/MarginContainer/HBoxContainer/EarnedLabel

var position_in_leaderboard


func _on_debug_button_pressed() -> void:
	add_score(BigNumber.from_int(1000))
	
func update_score():
	earned_label.text = score.format()

func add_score(amount : BigNumber):
	if tournament:
		tournament.add_score(name_label.text,amount)
	update_score()
	
func get_score() -> BigNumber:
	return score

func get_position_in_leaderboard() -> int:
	return position_in_leaderboard

func set_position_display(new_position:int):
	position_in_leaderboard = new_position
	position_label.text = str(new_position)

func set_data(player_name : String, place : int, score_to_set : BigNumber):
	name_label.text = player_name
	position_label.text = str(place)
	score = score_to_set
	earned_label.text = score.format()
