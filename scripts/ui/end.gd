extends Control

@onready var time_label: Label = $Background/Time
@onready var count_label: Label = $Background/Count

func _ready():
	SignalBus.game_won.connect(_on_game_won)
	
func _on_game_won() -> void:

	var time_taken = (Time.get_ticks_msec() - Global.start_time) / 100
	var death_count = Global.death_count
	
	SoundManager.play_music(load("res://sfx/music/game_over.wav"))
	
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var total_time: int = int(time_taken)
	var hours: int = total_time / 3600
	var minutes: int = (total_time % 3600) / 60
	var seconds: int = total_time % 60
	var formatted_time = "%02d:%02d:%02d" % [hours, minutes, seconds]
	
	time_label.text = formatted_time
	count_label.text = str(death_count)
	
	visible = true
