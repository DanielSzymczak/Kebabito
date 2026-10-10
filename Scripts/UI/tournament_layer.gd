extends CanvasLayer
@onready var leaderboard_v_box_container: VBoxContainer = %LeaderboardVBoxContainer
@onready var join_button: Button = $Control/HBoxContainer/Leaderboard/MarginContainer/VBoxContainer/JoinButton

var leaderboard_entry := preload("res://Scenes/UI/tournament_place_display.tscn")
var tournament : TournamentData

func _ready() -> void:
	GameState.tournament_data_update.connect(refresh_data)

func display():
	refresh_data()
	visible = true

func _on_join_button_pressed() -> void:
	if tournament and tournament.was_claimed == false:
		join_button.text = "Join Tournament"
		GameState.game_save.player_data.claim_tournament()
		tournament = null
		return
	join_button.visible = false
	join_tournament()

func join_tournament():
	GameState.game_save.player_data.join_tournament()
	display()

func end_tournament():
	GameState.game_save.player_data.end_tournament()

func tournament_tick():
	tournament = GameState.game_save.player_data.get_last_tournament()
	if tournament:
		tournament.tournament_tick()
		refresh_data()

func _on_end_tournament_button_pressed() -> void:
	end_tournament()

func refresh_data() -> void:
	for child in leaderboard_v_box_container.get_children():
		if child is LeaderboardEntry:
			leaderboard_v_box_container.remove_child(child)
			child.queue_free()

	tournament = GameState.game_save.player_data.get_last_tournament()
	if not tournament or tournament.was_claimed:
		join_button.visible = true
		join_button.text = "Join Tournament"
		return

	var is_ongoing: bool = tournament.get_time_left().is_greater(BigNumber.new())
	
	if is_ongoing:
		join_button.visible = false
	else:
		join_button.visible = true
		join_button.text = "Claim Reward"
	
	var entries: Array = tournament.get_sorted_leaderboard()
	var display_count := int(min(tournament.MAX_PLAYERS, entries.size()))
	
	for i in range(display_count):
		var entry : LeaderboardEntry = leaderboard_entry.instantiate()
		leaderboard_v_box_container.add_child(entry)
		entry.tournament = tournament
		entry.set_data(entries[i]["name"], i+1, entries[i]["score"])
		
	

func _on_tournament_tick_button_pressed() -> void:
	tournament_tick()
