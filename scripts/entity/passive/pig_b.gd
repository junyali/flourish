extends "res://scripts/entity/passive/passive.gd"

# Pig Variables
@export var roam_speed: float = 40.0
@export var roam_interval: float = 3.0
@export var idle_chance: float = 0.2
@export var action_chance: float = 0.4
@export var panic_duration: float = 3.0

enum State {
	IDLE,
	WALK,
	ACTION_1,
	ACTION_2
}
var current_state: State = State.IDLE
var target_direction: Vector2 = Vector2.ZERO
var is_panicking: bool = false

@onready var roam_timer: Timer = $Roam
@onready var panic_timer: Timer = $Panic
@onready var direction_timer: Timer = Timer.new()
@onready var roam_action_timer: Timer = Timer.new()

func _init() -> void:
	pass

func _ready() -> void:
	max_health = 20.0
	current_health = max_health
	max_speed = 10.0
	shield_multiplier = 0.1
	loot_table = [
		{
			"item_id": "seed_1",
			"quantity": {
				"min": 3,
				"max": 5,
			},
			"chance": 1.0
		}
	]
	
	add_child(direction_timer)
	add_child(roam_action_timer)
	
	roam_timer.wait_time = roam_interval
	roam_timer.start()
	
	roam_action_timer.one_shot = true
	roam_action_timer.timeout.connect(_end_action)
	
	panic_timer.wait_time = panic_duration
	panic_timer.one_shot = true
	
	direction_timer.timeout.connect(_change_panic_direction)
	play_animation("side_idle", Vector2.ZERO)
	super()
	
func handle_movement(delta: float) -> void:
	if not is_panicking:
		match current_state:
			State.WALK:
				var test_velocity = target_direction * roam_speed
				if !_will_collide(test_velocity):
					velocity = test_velocity
					play_animation("side_walk", target_direction)
			State.IDLE, State.ACTION_1, State.ACTION_2:
				velocity = Vector2.ZERO
			_:
				play_animation("side_idle", Vector2.ZERO)
				velocity = Vector2.ZERO
		
	else:
		var test_velocity = target_direction * max_speed * 5
		if !_will_collide(test_velocity):
			velocity = test_velocity
			play_animation("side_walk", target_direction)
	
	if target_direction.x != 0:
		sprite.flip_h = target_direction.x > 0
		
	move_and_slide()
		
func play_animation(state: String, direction: Vector2) -> void:
	sprite.play(state)
	
func take_damage(amount: float, knockback_power: float = 10, knockback_dir: Vector2 = Vector2.ZERO, apply_flash: bool = true, bypass_shield: bool = false, bypass_iframe: bool = false, attacker: Node = null):
	super(amount, knockback_power, knockback_dir, apply_flash, bypass_shield, bypass_iframe, attacker)
	enter_panic()
	
func enter_panic():
	if is_panicking:
		return
	is_panicking = true
	panic_timer.start(randf_range(3, 5))
	direction_timer.start(randf_range(0.5, 1.5))

func _on_roam_timeout() -> void:
	if is_panicking:
		roam_timer.start()
		return
	
	var roll = randf()
	
	if roll < idle_chance:
		current_state = State.IDLE
		play_animation("side_idle", Vector2.ZERO)
		roam_timer.start()
	elif roll < idle_chance + action_chance:
		current_state = State.ACTION_1 if randf() < 0.5 else State.ACTION_2
		play_animation("side_action_1" if current_state == State.ACTION_1 else "side_action_2", Vector2.ZERO)
		roam_action_timer.start(randf_range(1.5, 2.5))
	else:
		current_state = State.WALK
		target_direction = Vector2.RIGHT.rotated(randf_range(0, TAU)).normalized()
		play_animation("side_walk", target_direction)
		roam_timer.start()	
		
func _on_death():
	if last_damage_source and last_damage_source.is_in_group("player"):  
		run_loot_table()
		
	super()
	
func _on_panic_timeout() -> void:
	is_panicking = false
	direction_timer.stop()
	
func _change_panic_direction() -> void:
	var new_direction = Vector2.ZERO
	var attempts = 5

	for i in range(attempts):
		var test_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		if !_will_collide(test_direction * max_speed * 5):
			new_direction = test_direction
			break

	target_direction = new_direction
	direction_timer.start(randf_range(0.5, 1.5))
	
func _end_action() -> void:
	current_state = State.IDLE
	roam_timer.start()
	
func _will_collide(velocity: Vector2) -> bool:
	var test_position = global_position + velocity * get_physics_process_delta_time()
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = test_position
	query.collide_with_bodies = true
	query.exclude = [self]

	var result = space_state.intersect_point(query)
	return result.size() > 0
	
