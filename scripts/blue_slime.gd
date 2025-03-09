extends CharacterBody2D # Base class for an enemy

# // General Variables
@export var max_speed: float = 50.0
@export var acceleration: float = 500.0
@export var friction: float = 1500.0
@export var max_health: float = 100.0
@export var max_shield: float = 100.0
@export var attack_range: float = 10.0
@export var attack_speed: float = 0.5
@export var base_damage: float = 20.0
@export var invincibility_duration: float = 0.05
@export var knockback_strength: float = 50.0
@export var knockback_resistance: float = 10.0

# // Enemy Behaviour
@export var jump_interval: float = 3.0  # Time between jumps
@export var jump_force: float = 150.0   # Jump strength
@export var jump_decay: float = 500.0   # How quickly the slime slows down after jumping

# // Enemy Variables
var current_health: float = max_health
var move_direction: Vector2 = Vector2.ZERO
var velocity_modifier: float = 1.0
var is_aggro: bool = false
var is_knocked_back: bool = false
var is_attacking: bool = false
var time_since_last_move: float = 0.0
var is_vulnerable: bool = true

# // Node References
@onready var body_sprite: AnimatedSprite2D = $body_sprite
@onready var attack_timer: Timer = $attack_cd
@onready var iframe_timer: Timer = $iframe
@onready var flash_timer: Timer = $flash
@onready var jump_timer: Timer = $jump
@onready var player: CharacterBody2D = get_node("/root/Game/Player")

# Sprite Animations Dictionary
const ANIMATIONS = {
	"(0, -1)": ["back_idle", "back_walk"],
	"(0, 1)": ["front_idle", "front_walk",],
	"(-1, 0)": ["side_idle", "side_walk"],
	"(1, 0)": ["side_idle", "side_walk"]
}

func _ready() -> void:
	attack_timer.wait_time = attack_speed
	iframe_timer.wait_time = invincibility_duration
	flash_timer.wait_time = invincibility_duration
	attack_timer.wait_time = attack_speed
	jump_timer.wait_time = jump_interval
	jump_timer.start()
	body_sprite.play(ANIMATIONS["(0, 1)"][0])
	body_sprite.modulate = Color.WHITE

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_attack()

	if current_health <= 0:
		die()
		
func handle_movement(delta: float) -> void:
	if not is_aggro:
		body_sprite.play(ANIMATIONS["(0, 1)"][0])
	if not player: return
	if is_aggro and position.distance_to(player.position) > 10.0:
		move_direction = (player.position - position).normalized()
		velocity = move_direction * max_speed

		# Flip sprite if moving left
		body_sprite.play(ANIMATIONS["(-1, 0)"][0])
		body_sprite.flip_h = move_direction.x < 0
	else:
		velocity = Vector2.ZERO
			
	move_and_slide()
	
func play_animation(state: String, direction: Vector2) -> void:
	var dir_str = str(direction)
	if ANIMATIONS.has(dir_str):
		var anim_name = ANIMATIONS[dir_str][0] if state == "idle" else ANIMATIONS[dir_str][1]
		body_sprite.flip_h = (direction.x == -1)
		
		body_sprite.play(anim_name)

func handle_attack() -> void:
	if player and attack_timer.is_stopped():
		player.take_damage(base_damage, knockback_strength, Vector2(25, 25))
		attack_timer.start()

func take_damage(amount: float, knockback_power: float, knockback_dir: Vector2) -> void:
	current_health -= amount
	body_sprite.modulate = Color(1, 0.2, 0.2)

	var knockback_force = knockback_dir * (knockback_power / (knockback_resistance + knockback_power))
	velocity += knockback_force
	is_knocked_back = true

	await get_tree().create_timer(0.1).timeout
	body_sprite.modulate = Color.WHITE
	
	
func _on_iframe_timeout() -> void:
	flash_timer.stop()
	body_sprite.modulate = Color.WHITE
	is_vulnerable = true
		
func _on_regen_timer_timeout() -> void:
	if current_health > 0 and current_health < max_health:
		current_health = min(current_health + 20, max_health)
		
func _on_flash_timeout() -> void:
	if iframe_timer.time_left > 0:
		body_sprite.modulate = Color(1, 0.5, 0.5) if body_sprite.modulate == Color.WHITE else Color.WHITE
		flash_timer.start(invincibility_duration)
	else:
		body_sprite.visible = true
		is_vulnerable = true

func _on_jump_timer_timeout():
	if not is_aggro or not player:
		return

	# Jump toward the player
	move_direction = (player.position - position).normalized()
	velocity = move_direction * jump_force  # Apply jump impulse
	body_sprite.play(ANIMATIONS[str(Vector2(sign(move_direction.x), sign(move_direction.y)))][1])

	# Reset timer
	jump_timer.start()

func die():
	pass


func _on_aggro_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		is_aggro = true


func _on_aggro_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player = null
		is_aggro = false
		
func _on_melee_attack_hitbox_body_entered(body: Node2D) -> void:
	if body == player:
		is_attacking = true
		attack_timer.start()  # Start attack loop
		body.take_damage(10, 5, Vector2(5, 5))

func _on_melee_attack_hitbox_body_exited(body: Node2D) -> void:
	if body == player:
		is_attacking = false
		attack_timer.stop()  # Stop attacking when the player leaves
