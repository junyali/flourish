extends CanvasLayer

# UI Variables
var effect_progress_bars = {}

# Node References
@onready var player = get_tree().get_first_node_in_group("player")
@onready var heart_container = $TopLeftCorner/StatContainer/HeartContainer
@onready var prot_container = $TopLeftCorner/StatContainer/ProtContainer
@onready var cooldown_container = $TopLeftCorner/StatContainer/CooldownContainer
@onready var effect_container = $TopLeftCorner/EffectContainer

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Global.Player:
		update_stat_display(delta)
	
func update_stat_display(delta: float) -> void:
	var current_hp = Global.Player.current_health
	var max_hp = Global.Player.max_health
	var shield = Global.Player.shield
	var is_sprinting = Global.Player.is_sprinting
	var movement_ability_cd = Global.Player.movement_timer.time_left / Global.Player.movement_timer.wait_time if not Global.Player.can_dash else 0
	
	var hp_per_heart = max_hp / heart_container.get_child_count()
	var hearts = heart_container.get_children()
	var shield_label = prot_container.get_node("Shield").get_node("Label")
	
	for index in range(hearts.size()):
		var heart_fill = min(current_hp, hp_per_heart)
		hearts[index].value = (heart_fill / hp_per_heart) * 100
		
		current_hp -= hp_per_heart
		
	shield_label.text = str(shield)
	
	cooldown_container.get_node("Sprint").visible = is_sprinting
	if movement_ability_cd <= 0:
		cooldown_container.get_node("Dash").visible = false
	else:
		cooldown_container.get_node("Dash").value = lerp(15, 75, movement_ability_cd)
		cooldown_container.get_node("Dash").visible = true
		
	cooldown_container.queue_sort()
	
	for effect_name in Global.Player.status_effects.keys():
		var effect = Global.Player.status_effects[effect_name]
		var time_left = effect["time_left"]
		var duration = effect["duration"]
		var amplification = effect["amplification"]
		
		if not effect_progress_bars.has(effect_name) and time_left > 0:
			var progress_bar = TextureProgressBar.new()
			var effect_texture = load("res://art/gui/effect/" + effect_name.to_lower() + ".png")
			progress_bar.name = effect_name
			progress_bar.texture_progress = effect_texture
			progress_bar.texture_under = effect_texture
			progress_bar.tint_under = Color.hex(0x333333ff)
			progress_bar.fill_mode = 5
			progress_bar.value = 0
			
			var time_label = Label.new()
			time_label.name = "Time"
			time_label.label_settings = preload("res://assets/labelsetting/flourish.tres")
			time_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			time_label.clip_text = true
			time_label.size = Vector2(32, 8)
			time_label.position = Vector2(0, 26)
			time_label.text = str(snapped(time_left, 0.1)) + "s"
			progress_bar.add_child(time_label)
			
			var amplification_label = Label.new()
			amplification_label.name = "Amplification"
			amplification_label.label_settings = preload("res://assets/labelsetting/flourish.tres")
			amplification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			amplification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			amplification_label.clip_text = true
			amplification_label.size = Vector2(32, 8)
			amplification_label.position = Vector2(1, 1)
			amplification_label.text = Global.int_to_roman(amplification)
			progress_bar.add_child(amplification_label)
			
			effect_container.add_child(progress_bar)
			effect_progress_bars[effect_name] = progress_bar
			
		var progress_bar = effect_progress_bars[effect_name]
		var time_label = progress_bar.get_node("Time")
		var amplification_label = progress_bar.get_node("Amplification")
		progress_bar.value = (time_left / duration) * 100
		time_label.text = str(snapped(time_left, 0.1)) + "s"
		amplification_label.text = Global.int_to_roman(amplification)
		
		if time_left <= 0:
			progress_bar.queue_free()
			effect_progress_bars.erase(effect_name)
			
	for effect_name in effect_progress_bars.keys():
		if not Global.Player.status_effects.has(effect_name):
			effect_progress_bars[effect_name].queue_free()
			effect_progress_bars.erase(effect_name)
		
	
