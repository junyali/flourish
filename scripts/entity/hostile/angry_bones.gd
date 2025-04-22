extends "res://scripts/entity/hostile/hostile.gd"

# Angry Bones Variables
@export var roam_speed: float = 40.0
@export var roam_interval: float = 3.0
@export var chase_speed: float = 40.0
@export var idle_chance: float = 0.1

var current_state: State = State.IDLE
var target_direction: Vector2 = Vector2.ZERO
var target_player: Node2D = null
var can_attack: bool = true
var current_direction: String = "front"

@onready var roam_timer: Timer = $Roam

func _init() -> void:
	pass

func _ready() -> void:
	max_health = 100.0
	current_health = max_health
	attack_damage = 10.0
	attack_speed = 3.0
	max_speed = 30.0
	shield = 8
	shield_multiplier = 0.5
	loot_table = [
		{
			"item_id": "purple_mushroom",
			"quantity": {
				"min": 1,
				"max": 1,
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
				update_direction(target_direction)
				handle_attack()
	
func handle_movement(delta: float) -> void:
	var base_velocity: Vector2 = Vector2.ZERO
	match current_state:
		State.WALK:
			update_direction(target_direction)
			base_velocity = target_direction * roam_speed
			play_animation("walk", target_direction)
		State.CHASE:
			if target_player:
				pathfinder.target_position = target_player.global_position
				var next_pos = pathfinder.get_next_path_position()
				target_direction = global_position.direction_to(next_pos).normalized()
				update_direction(target_direction)
				play_animation("walk", target_direction)
				base_velocity = target_direction * chase_speed
				roam_timer.stop()
		State.IDLE:
			play_animation("idle", Vector2.ZERO)
			base_velocity = Vector2.ZERO
		State.ATTACK:
			base_velocity = Vector2.ZERO
		_:
			play_animation("idle", Vector2.ZERO)
			base_velocity = Vector2.ZERO
	
	velocity = base_velocity
	super(delta)
		
func play_animation(state: String, direction: Vector2) -> void:
	var animation_name: String = current_direction + "_" + state
	if sprite.animation != animation_name:
		sprite.play(animation_name)

func update_direction(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		current_direction = "side"
		sprite.flip_h = direction.x < 0
	elif direction.y > 0:
		sprite.flip_h = false
		current_direction = "front"
	else:
		sprite.flip_h = false
		current_direction = "back"
	
func handle_attack() -> void:
	if target_player and can_attack:
		can_attack = false
		velocity = Vector2.ZERO
		
		play_animation("attack", target_direction)

		await 1.5 # got lazy so i put an arbitrary number here T-T
		
		if target_player:
			target_player.take_damage(DamageOptions.new({
				"amount": attack_damage
			}))

			var chance = 0.25
			if randf() < chance:
				var bleed = BleedingEffect.new("bleeding", 10, 1, 2, 0)
				if target_player.has_method("apply_status_effect"):
					target_player.apply_status_effect(bleed)
			
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
			handle_attack()

func _on_range_body_exited(body: Node2D) -> void:
	var root_player = body
	if root_player.is_in_group(Groups.PLAYER_GROUP):
		current_state = State.CHASE
		
func _on_attack_timeout() -> void:
	can_attack = true
