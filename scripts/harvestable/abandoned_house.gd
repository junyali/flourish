extends "res://scripts/harvestable/harvestable.gd"

# Harvestable Variables
@export var wave_interval: float = 5.0
@export var enemies_per_wave: int = 5
@export var enemy_types: Array = [
	{
		"scene": preload("res://scenes/entity/hostile/slime_blue.tscn"),
		"probability": 0.7,
	}
]

var is_spawning: bool = false
var total_probability: float = 0.0

func _init():
	pass

func _ready():
	add_to_group("require_sword")
	hardness = 0.5
	health = 100.0
	harvest_cue = true
	cue_range = 64.0
	cue_colour = Color(1.5, 1.5, 1.5)
	
	sprite.texture = preload("res://art/tilemap/object/abandoned_house.png")
	sprite.offset = Vector2(0, -50)

	super()

	tool_hint_sprite.texture = ItemDatabase.get_item_texture("sword")
	
	for enemy in enemy_types:
		total_probability += enemy.probability

func take_damage(amount: int) -> void:
	if current_health > 0:
		var random_sound = randi_range(1, 3)
		sound_player = SoundManager.play_spatial_sfx(load("res://sfx/resource/tree_axe_" + str(random_sound) + ".wav"), self, 1.0)
	super(amount)

func harvest() -> void:
	fade_out(0.4)
	
func start_wave_system() -> void:
	spawn_wave()
	while is_spawning:
		await get_tree().create_timer(wave_interval).timeout
		spawn_wave()
	
func spawn_wave() -> void:
	for i in range(enemies_per_wave):
		if not is_spawning:
			return
		spawn_enemy()

func spawn_enemy() -> void:
	var enemy_scene = select_random_enemy()
	if enemy_scene:
		var enemy_instance = enemy_scene.instance()
		var angle = randf() * TAU
		var distance = randf_range(16, 64)
		var spawn_position = global_position + Vector2(cos(angle), sin(angle)) * distance
		
		enemy_instance.global_position = spawn_position
		get_parent().add_child(enemy_instance)
		
func select_random_enemy() -> PackedScene:
	var random_value = randf() * total_probability
	var cumulative_probability = 0.0
	for enemy in enemy_types:
		cumulative_probability += enemy.probability
		if random_value <= cumulative_probability:
			return enemy.scene
	return null

func _on_cue_area_body_entered(body: Node2D) -> void:
	super(body)
	if not is_spawning:
		is_spawning = true
		

func _on_cue_area_body_exited(body: Node2D) -> void:
	super(body)
	is_spawning = false
