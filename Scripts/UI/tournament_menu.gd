extends Button

@onready var tournament_layer: CanvasLayer = %TournamentLayer
@onready var tournament_time_label: Label = $"../../TournamentTimeLabel"

var total_seconds: BigNumber
var timer_active: bool = false

var tournament: TournamentData

func _ready() -> void:
	if not GameState.is_node_ready():
		await GameState.ready
		
	if GameState.game_save and GameState.game_save.player_data:
		GameState.tournament_data_update.connect(timer_init)
	
	timer_init()

func _process(_delta: float) -> void:
	if timer_active and tournament:
		update_timer_data()

func update_timer_data() -> void:
	total_seconds= tournament.get_time_left()
	
	if total_seconds.is_less(BigNumber.from_int(1)):
		print(total_seconds.format_time())
		tournament_time_label.text = "Claim Reward!"
		timer_active = false
	else:
		tournament_time_label.text = total_seconds.format_time()

func hide_tournament_ui() -> void:
	timer_active = false
	if tournament_time_label:
		tournament_time_label.visible = false


func timer_init():
	tournament = GameState.game_save.player_data.get_last_tournament()
	
	if not tournament or tournament.was_claimed:
		hide_tournament_ui()
		return
	
	tournament_time_label.visible = true
	timer_active = true
	update_timer_data()

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		tournament_layer.display()
		return
	tournament_layer.hide()
