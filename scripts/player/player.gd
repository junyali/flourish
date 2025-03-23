extends CharacterBody2D # Player character main script :3

# // Player Attributes \\ #
## MOVEMENT ##
@export var max_speed: float = 60.0 # Maximum speed player is capped at walking
@export var acceleration: float = 500.0 # From stationary to max speed
@export var friction: float = 1500.0 # From max speed to stationary

## STATS ##
@export var max_health: float = 100.0
@export var shield: float = 10.0
@export var shield_multiplier: float = 0.5

@export var regen_amount: float = 20.0 # x HP/sec
@export var regen_interval: float = 1.0 # Attempt regen every x sec
@export var regen_delay: float = 10.0 # Regen after last combat

## COMBAT ##
@export var attack_range: float = 10.0
@export var attack_speed: float = 0.5 # Attack duration
@export var base_attack_damage: float = 20.0

@export var invincibility_duration: float = 0.1 # Ideally a very short duration - after all it is just a frame right?

@export var knockback_strength: float = 10.0
@export var knockback_resistance: float = 1.0

## COMBAT ##
@export var dash_speed: float = 200.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 3.0

@export var sprint_multiplier: float = 1.5
# \\ End of Player Attributes // #

# // Runtime Variables Constants \\ #
var current_velocity: Vector2 = Vector2.ZERO
var current_health: float = 90.0
var status_effects = {}
var move_direction: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2(0, 1)
var is_attacking: bool = false
var is_vulnerable: bool = true
var can_dash: bool = true
var is_dashing: bool = false
var is_sprinting: bool = false
var last_hit_time: float = 0.0

const ANIMATIONS = {
	"(0, -1)": ["back_idle", "back_walk", "back_attack"],
	"(0, 1)": ["front_idle", "front_walk", "front_attack"],
	"(-1, 0)": ["side_idle", "side_walk", "side_attack"],
	"(1, 0)": ["side_idle", "side_walk", "side_attack"]
}

enum State {
	IDLE,
	WALK,
	SPRINT,
	ATTACK
}
# \\ End of Runtime Variables Constants // #

# // Node References \\ #
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var attack_area: Area2D = $Range
@onready var iframe_timer: Timer = $Iframe
@onready var flash_timer: Timer = $Flash
@onready var attack_timer: Timer = $Attack
@onready var regen_timer: Timer = $Regen
@onready var movement_timer: Timer = $Movement
# \\ End of Node References // #

func _ready() -> void:
	# On scene entering tree
	add_to_group(Groups.PLAYER_GROUP)
	
	# Set timers
	iframe_timer.wait_time = invincibility_duration
	iframe_timer.one_shot = false
	flash_timer.wait_time = invincibility_duration
	flash_timer.one_shot = false
	attack_timer.wait_time = attack_speed
	flash_timer.one_shot = false
	regen_timer.wait_time = regen_interval
	regen_timer.one_shot = false
	movement_timer.wait_time = dash_cooldown
	movement_timer.one_shot = false
	
	# Set defaults
	play_animation(State.IDLE, Vector2(0, 1)) # Default front idle animation
	sprite.modulate = Color.WHITE
	
	regen_timer.start()
	
	Global.Player = self

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_attack()
	update_status_effect(delta)

	if current_health <= 0:
		respawn()
	
func _process(delta: float) -> void:
	pass
	
func handle_movement(delta: float) -> void:
	# Get raw input values
	var h_dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var v_dir = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var input_dir = Vector2(h_dir, v_dir).normalized()
	
	# Determine movement priority
	# Consequentely prevents diagonal movement (intended)
	if abs(h_dir) > abs(v_dir):
		input_dir = Vector2(sign(h_dir), 0)
	elif abs(v_dir) > 0:
		input_dir = Vector2(0, sign(v_dir))
	
	# Accelerative speed (was that even a word??)
	if input_dir != Vector2.ZERO:
		move_direction = input_dir
		facing_direction = input_dir  # Update direction
	else:
		move_direction = Vector2.ZERO  # Instant stop
		
	is_sprinting = Input.is_action_pressed("sprint")
	is_dashing = Input.is_action_just_pressed("movement_ability")
		
	# Update facing direction when moving
	if move_direction != Vector2.ZERO and not is_attacking:
		var target_speed = max_speed * (sprint_multiplier if is_sprinting else 1.0)
		current_velocity = velocity.move_toward(move_direction * target_speed, acceleration * delta)
	else:
		current_velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	# Handle animations
	if not is_attacking:
		var state = State.IDLE
		if input_dir != Vector2.ZERO:
			if is_sprinting:
				state = State.SPRINT
			else:
				state = State.WALK
		else:
			state = State.IDLE
		play_animation(state, facing_direction)
	else:
		current_velocity = Vector2.ZERO
		
	if is_dashing and can_dash and not is_attacking:
		can_dash = false
		
		var dash_vector = facing_direction * dash_speed
		var tween = create_tween()
		tween.tween_property(self, "velocity", facing_direction * dash_speed, dash_duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		apply_status_effect(BurningEffect.new("burning", 10.0, 1.0, 2.0, 0))
		
		await get_tree().create_timer(dash_duration).timeout
		is_dashing = false

		movement_timer.start()
		
	velocity = current_velocity
	move_and_slide()
	
func handle_attack() -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		play_animation(State.ATTACK, facing_direction)
		attack_timer.start()
		
		for body in attack_area.get_overlapping_bodies():
			print(body)
			if body.is_in_group("resource"):
				body.take_damage(1)
			elif body.is_in_group("entity"):
				var damage_params = DamageOptions.new({
					"amount": 10.0,
					"knockback_power": 16,
					"knockback_direction": Vector2(10, 10),
					"attacker": self
				})
				body.take_damage(damage_params)
		

func play_animation(state: State, direction: Vector2) -> void:
	var dir_str = str(direction)
	if ANIMATIONS.has(dir_str):
		var anim_name = ""
		
		match state:
			State.IDLE:
				anim_name = ANIMATIONS[dir_str][0]
			State.WALK:
				anim_name = ANIMATIONS[dir_str][1]
				sprite.sprite_frames.set_animation_speed(anim_name, 5)
			State.SPRINT:
				anim_name = ANIMATIONS[dir_str][1]
				sprite.sprite_frames.set_animation_speed(anim_name, 15)
			State.ATTACK:
				anim_name = ANIMATIONS[dir_str][2]
				var sprite_fps: float = sprite.get_sprite_frames().get_frame_count(anim_name) / attack_speed
				sprite.sprite_frames.set_animation_speed(anim_name, sprite_fps)
				
		sprite.flip_h = (direction.x == -1)
			
		# Play animation track
		sprite.play(anim_name)
		
func take_damage(options: DamageOptions) -> void:
	if is_vulnerable:
		if not options.bypass_shield:
			# funni name :3
			# Current formula is logarithmic
			# var THE_FORMULA = max(amount - (shield * shield_multiplier), 0)
			# var THE_FORMULA = snapped(max(amount - (log(shield + 1) * shield_multiplier), 0), 0.01)
			var THE_FORMULA = max(options.amount - (log(shield + 1) * shield_multiplier), 0)
			current_health -= THE_FORMULA
			print("Damage Received: %s | Shield: %s | Damage Taken: %s" % [options.amount, shield, THE_FORMULA])
		else:
			current_health -= options.amount
		if not options.bypass_iframe:
			is_vulnerable = false
			iframe_timer.start()
			flash_timer.start()
			
		if options.apply_flash:
			flash_sprite(Color(1, 0.2, 0.2), invincibility_duration)
			
		var knockback_force = options.knockback_direction * (options.knockback_power / (knockback_resistance + options.knockback_power))
		velocity = knockback_force
		last_hit_time = Time.get_ticks_msec() / 1000.0
		
func apply_status_effect(effect: StatusEffect) -> void:
	status_effects[effect.effect_name] = effect
	
func update_status_effect(delta: float) -> void:
	var effects_to_remove = []
	for effect_name in status_effects.keys():
		if status_effects[effect_name].update_effect(delta, self):
			effects_to_remove.append(effect_name)
			
	for effect in effects_to_remove:
		remove_status_effect(effect)
		
func remove_status_effect(effect_name: String) -> void:
	if effect_name in status_effects:
		status_effects.erase(effect_name)
		
func flash_sprite(colour: Color, duration: float = 1.0) -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", colour, duration)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.1)
		
func calculate_attack_damage() -> float:
	return base_attack_damage
		
func respawn() -> void:
	# (Insert respawn mechanic here idk)
	current_health = max_health
	position = Vector2(200, 200)
	
func _on_iframe_timeout() -> void:
	flash_timer.stop()
	is_vulnerable = true
		
func _on_flash_timeout() -> void:
	if iframe_timer.time_left > 0:
		flash_timer.start(invincibility_duration)
	else:
		sprite.visible = true
		is_vulnerable = true

func _on_attack_timeout() -> void:
	is_attacking = false

func _on_regen_timeout() -> void:
	var time_since_last_hit = (Time.get_ticks_msec() / 1000.0) - last_hit_time
	if time_since_last_hit >= regen_delay and current_health < max_health:
		current_health = min(current_health + regen_amount, max_health)

func _on_movement_timeout() -> void:
	can_dash = true

func _on_range_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

func _on_range_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
