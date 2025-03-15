extends CharacterBody2D # Player script :3

# // General Variables
@export var max_speed: float = 80.0
@export var acceleration: float = 500.0
@export var friction: float = 1500.0
@export var max_health: float = 100.0
@export var shield_multiplier: float = 0.5
@export var regen_amount: float = 20.0
@export var regen_interval: float = 1.0
@export var regen_delay: float = 10.0
@export var attack_range: float = 10.0
@export var attack_speed: float = 0.5
@export var base_damage: float = 20.0
@export var invincibility_duration: float = 0.1 # Ideally a very short duration - after all it is just a frame right?
@export var knockback_strength: float = 10.0
@export var knockback_resistance: float = 1.0

# // Abilities
@export var dash_speed: float = 200.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 3.0

@export var sprint_multiplier: float = 1.5

# Player Variables
var current_velocity: Vector2 = Vector2.ZERO
var current_health: float = 90.0
var shield: float = 10.0
var status_effects = {}
var move_direction: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2(0, 1)
var is_attacking: bool = false
var is_vulnerable: bool = true
var can_dash: bool = true
var is_dashing: bool = false
var is_sprinting: bool = false
var last_hit_time: float = 0.0

# Node References
@onready var body_sprite: AnimatedSprite2D = $body_sprite
@onready var iframe_timer: Timer = $iframe
@onready var flash_timer: Timer = $flash
@onready var attack_timer: Timer = $attack_cd
@onready var regen_timer: Timer = $regen_timer
@onready var movement_timer: Timer = $movement_ability_cd
@onready var attack_hitbox: Area2D = $melee_attack_hitbox

var _overlapping = []

# Sprite Animations Dictionary
const ANIMATIONS = {
	"(0, -1)": ["back_idle", "back_walk", "back_attack"],
	"(0, 1)": ["front_idle", "front_walk", "front_attack"],
	"(-1, 0)": ["side_idle", "side_walk", "side_attack"],
	"(1, 0)": ["side_idle", "side_walk", "side_attack"]
}

func _ready() -> void:
	add_to_group("player")
	get_parent().add_to_group("player")
	attack_timer.wait_time = attack_speed
	iframe_timer.wait_time = invincibility_duration
	flash_timer.wait_time = invincibility_duration
	regen_timer.wait_time = regen_interval
	movement_timer.wait_time = dash_cooldown
	body_sprite.play(ANIMATIONS["(0, 1)"][0]) # Default front idle animation
	body_sprite.modulate = Color.WHITE
	
	regen_timer.timeout.connect(_on_regen_timer_timeout)
	regen_timer.start()
	
	Global.Player = self

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_attack()
	handle_dash()

	if current_health <= 0:
		respawn()
		
func _process(delta: float) -> void:
	update_status_effect(delta)
		
func player():
	pass # Future reference for checking a player (probably won't need this, ever.. :P)
		
func handle_movement(delta: float) -> void:
	# Get raw input values
	var h_dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var v_dir = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	var input_dir = Vector2(h_dir, v_dir).normalized()
	
	# Determine movement priority
	# Consequentely prevents diagonal movement (intended)
	if h_dir != 0:
		input_dir = Vector2(h_dir, 0)
	elif v_dir != 0:
		input_dir = Vector2(0, v_dir)
	
	# Accelerative speed (was that even a word??)
	if input_dir != Vector2.ZERO:
		move_direction = input_dir
		facing_direction = input_dir  # Update direction
	else:
		move_direction = Vector2.ZERO  # Instant stop
		
	if Input.is_action_pressed("sprint"):
		is_sprinting = true
	else:
		is_sprinting = false
		
	# Update facing direction when moving
	if move_direction != Vector2.ZERO and not is_attacking:
		var target_speed = max_speed * (sprint_multiplier if is_sprinting else 1.0)
		velocity = velocity.move_toward(move_direction * target_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	# Handle animations
	if not is_attacking:
		var state = "walk" if input_dir != Vector2.ZERO else "idle"
		play_animation(state, facing_direction)
		
	move_and_slide()
	
func handle_dash() -> void:
	if Input.is_action_just_pressed("movement_ability") and can_dash:
		is_dashing = true
		can_dash = false
		velocity = facing_direction * dash_speed
		
		#apply_status_effect("burning", 10, 1, 1)
		#apply_status_effect("poison", 60, 2.0, 0.5)
		#apply_status_effect("freezing", 60, 2.0, 0.5)
		#apply_status_effect("bleeding", 60, 2.0, 0.5)
		
		#var rng = RandomNumberGenerator.new()
		#take_damage(rng.randi_range(5, 25))
		
		await get_tree().create_timer(dash_duration).timeout
		is_dashing = false

		movement_timer.start()
		
	
func play_animation(state: String, direction: Vector2) -> void:
	var dir_str = str(direction)
	if ANIMATIONS.has(dir_str):
		var anim_name = ANIMATIONS[dir_str][0] if state == "idle" else ANIMATIONS[dir_str][1]
		body_sprite.flip_h = (direction.x == -1)
		
		if Input.is_action_pressed("sprint"):
			body_sprite.sprite_frames.set_animation_speed(anim_name, 15)
		else:
			body_sprite.sprite_frames.set_animation_speed(anim_name, 5)
		body_sprite.play(anim_name)


func handle_attack() -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		attack_hitbox.monitoring = true  # Enable hit detection
		attack_timer.start()  # Start cooldown
		
		velocity = Vector2.ZERO

		if ANIMATIONS.has(str(facing_direction)):
			var anim_name: String = ANIMATIONS[str(facing_direction)][2]
			var sprite_fps: float = body_sprite.get_sprite_frames().get_frame_count(anim_name) / attack_speed
			body_sprite.sprite_frames.set_animation_speed(anim_name, sprite_fps)
			body_sprite.play(anim_name)  # Attack animation
			
		for body in _overlapping:
			print(body)
			if body.is_in_group("resource"):
				body.get_parent().take_damage(1)
			elif body.get_parent().is_in_group("entity"):
				body.get_parent().take_damage(10, 20, Vector2(5, 5), true, false, true, self)
		
func take_damage(amount: float, knockback_power: float = 10, knockback_dir: Vector2 = Vector2.ZERO, apply_flash: bool = true, bypass_shield: bool = false, bypass_iframe: bool = false) -> void:
	if is_vulnerable:
		if not bypass_shield:
			# funni name :3
			# Current formula is logarithmic
			# var THE_FORMULA = max(amount - (shield * shield_multiplier), 0)
			# var THE_FORMULA = snapped(max(amount - (log(shield + 1) * shield_multiplier), 0), 0.01)
			var THE_FORMULA = max(amount - (log(shield + 1) * shield_multiplier), 0)
			current_health -= THE_FORMULA
			print("Damage Received: %s | Shield: %s | Damage Taken: %s" % [amount, shield, THE_FORMULA])
		else:
			current_health -= amount
		if not bypass_iframe:
			is_vulnerable = false
			iframe_timer.start()
			flash_timer.start()
			
		if apply_flash:
			flash_sprite(Color(1, 0.2, 0.2), invincibility_duration)
			
		var knockback_force = knockback_dir * (knockback_power / (knockback_resistance + knockback_power))
		velocity = knockback_force
		last_hit_time = Time.get_ticks_msec() / 1000.0
		
func apply_status_effect(effect_name: String, duration: float = 60.0, amplification: int = 1, tick_interval: float = 1.0) -> void:
	status_effects[effect_name] = {
		"time_left": duration,
		"duration": duration,
		"amplification": amplification,
		"tick_interval": tick_interval,
		"time_since_last_tick": 9999
	}
	
func update_status_effect(delta: float) -> void:
	var effects_awaiting_removal = []
	for effect_name in status_effects.keys():
		var effect = status_effects[effect_name]
		effect["time_left"] -= delta
		effect["time_since_last_tick"] += delta
		
		match effect_name:
			"poison":
				if effect["time_since_last_tick"] >= effect["tick_interval"]:
					effect["time_since_last_tick"] = 0
					take_damage(10 * effect["amplification"], 2, Vector2(2, 2), false, true, true)
					flash_sprite(Color(0.0, 0.5, 0.0), 0.05)
					
			"burning":
				if effect["time_since_last_tick"] >= effect["tick_interval"]:
					effect["time_since_last_tick"] = 0
					take_damage(2 * effect["amplification"], 8, Vector2(4, 4), false, true, true)
					flash_sprite(Color(1, 0.4, 0.05), 0.05)
					
			"freezing":
				velocity *= 0.2
				flash_sprite(Color(0.35, 0.55, 0.88), 1)
				
			"bleeding":
				if effect["time_since_last_tick"] >= effect["tick_interval"]:
					effect["time_since_last_tick"] = 0
					take_damage(10 * effect["amplification"], 0, Vector2(0, 0), false, true, true)
					flash_sprite(Color(1, 0, 0), 0.05)
				
		
		if effect["time_left"] <= 0:
			effect["time_left"] = -1
			effects_awaiting_removal.append(effect_name)
			
	for effect in effects_awaiting_removal:
		remove_status_effect(effect)
		
func remove_status_effect(effect_name: String) -> void:
	if effect_name in status_effects:
		status_effects.erase(effect_name)
		
func flash_sprite(colour: Color, duration: float = 1.0) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(body_sprite, "modulate", colour, duration)
	tween.tween_property(body_sprite, "modulate", Color(1, 1, 1, 1), 0.1)
	
		
func calculate_attack_damage() -> float:
	return base_damage
		
func respawn() -> void:
	# (Insert respawn mechanic here idk)
	current_health = max_health
	position = Vector2(200, 200)
		
func _on_attack_cd_timeout() -> void:
	is_attacking = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	_overlapping.append(body)

func _on_hitbox_body_exited(body: Node2D) -> void:
	_overlapping.erase(body)
	
func _on_iframe_timeout() -> void:
	flash_timer.stop()
	is_vulnerable = true
		
func _on_regen_timer_timeout() -> void:
	var time_since_last_hit = (Time.get_ticks_msec() / 1000.0) - last_hit_time
	if time_since_last_hit >= regen_delay and current_health < max_health:
		current_health = min(current_health + regen_amount, max_health)
		
func _on_flash_timeout() -> void:
	if iframe_timer.time_left > 0:
		flash_timer.start(invincibility_duration)
	else:
		body_sprite.visible = true
		is_vulnerable = true

func _on_movement_ability_cd_timeout() -> void:
	can_dash = true
	
