extends "res://scripts/entity/hostile/hostile.gd"

# Slime Variables
@export var roam_speed: float = 40.0
@export var roam_interval: float = 3.0
@export var chase_speed: float = 60.0
@export var idle_chance: float = 0.1

var current_state: State = State.IDLE
var target_direction: Vector2 = Vector2.ZERO
var target_player: Node2D = null
var can_attack: bool = true

@onready var roam_timer: Timer = $Roam

func _init() -> void:
	pass

func _ready() -> void:
	max_health = 25.0
	current_health = max_health
	attack_damage = 3.0
	attack_speed = 0.5
	max_speed = 30.0
	shield = 0.5
	shield_multiplier = 0.1
	loot_table = [
		{
			"item_id": "berry",
			"quantity": {
				"min": 2,
				"max": 7,
			},
			"chance": 1.0
		}
	]
	
	roam_timer.wait_time = roam_interval
	roam_timer.one_shot = false
	roam_timer.start()
	
	attack_timer.wait_time = attack_speed
	
	play_animation("idle", Vector2.ZERO)
	super()
	
func _physics_process(delta: float) -> void:
	super(delta)
	for body in range.get_overlapping_bodies():
		var root_player = body
		if root_player.is_in_group(Groups.PLAYER_GROUP):
			current_state = State.ATTACK
			velocity = Vector2.ZERO
			if can_attack:
				target_direction = (root_player.global_position - global_position).normalized()
				sprite.flip_h = target_direction.x > 0
				handle_attack()
	
func handle_movement(delta: float) -> void:
	var base_velocity: Vector2 = Vector2.ZERO
	match current_state:
		State.WALK:
			base_velocity = target_direction * roam_speed
			play_animation("walk", target_direction)
		State.CHASE:
			if target_player:
				pathfinder.target_position = target_player.global_position
				base_velocity = global_position.direction_to(pathfinder.get_next_path_position()) * roam_speed
				play_animation("walk", target_direction)
				roam_timer.stop()
		State.IDLE:
			play_animation("idle", Vector2.ZERO)
			base_velocity = Vector2.ZERO
		_:
			play_animation("idle", Vector2.ZERO)
			base_velocity = Vector2.ZERO
	
	if target_direction.x != 0:
		sprite.flip_h = target_direction.x > 0
	
	velocity = base_velocity
	super(delta)
		
func play_animation(state: String, direction: Vector2) -> void:
	sprite.play(state)
	
func handle_attack() -> void:
	if target_player and can_attack:
		target_player.take_damage(DamageOptions.new({
			"amount": attack_damage
		}))
		can_attack = false
		attack_timer.start()

func _on_roam_timeout() -> void:
	if current_state == State.CHASE:
		return
	if current_state == State.WALK:
		current_state = State.IDLE
	elif current_state == State.IDLE:
		var roll = randf()
		if roll < idle_chance:
			current_state = State.IDLE
			play_animation("idle", Vector2.ZERO)
		else:
			current_state = State.WALK
			target_direction = Vector2.RIGHT.rotated(randf_range(0, TAU)).normalized()
			play_animation("walk", target_direction)
			
	roam_timer.start()	
		
func die():
	if last_damage_source and last_damage_source.is_in_group(Groups.PLAYER_GROUP):  
		run_loot_table()
		
	super()
	
func _on_aggro_body_entered(body: Node2D) -> void:
	var root_player = body
	if root_player.is_in_group(Groups.PLAYER_GROUP):
		target_player = root_player
		current_state = State.CHASE

func _on_aggro_body_exited(body: Node2D) -> void:
	var root_player = body
	if root_player.is_in_group(Groups.PLAYER_GROUP):
		target_player = null
		current_state = State.IDLE
		roam_timer.start()
		
func _on_range_body_entered(body: Node2D) -> void:
	var root_player = body
	if root_player.is_in_group(Groups.PLAYER_GROUP):
		current_state = State.ATTACK
		velocity = Vector2.ZERO
		if can_attack:
			target_direction = (root_player.global_position - global_position).normalized()
			sprite.flip_h = target_direction.x > 0
			handle_attack()

func _on_range_body_exited(body: Node2D) -> void:
	var root_player = body
	if root_player.is_in_group(Groups.PLAYER_GROUP):
		current_state = State.CHASE
		
func _on_attack_timeout() -> void:
	can_attack = true
