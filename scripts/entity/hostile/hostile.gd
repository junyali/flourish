extends CharacterBody2D

# // General Variables
@export var max_speed: float = 80.0
@export var max_health: float = 100.0
@export var shield: float = 0.0
@export var shield_multiplier: float = 0.0
@export var attack_damage: float = 5.0
@export var attack_speed: float = 1.0
@export var regen_amount: float = 2.0
@export var regen_interval: float = 10.0
@export var regen_delay: float = 10.0
@export var invincibility_duration: float = 0.1
@export var knockback_resistance: float = 0.05
@export var loot_table: Array[Dictionary] = [{}]

# Entity Variables
var current_health: float = max_health
var knockback_velocity: Vector2 = Vector2.ZERO
var is_invincible: bool = false
var is_knocked_back: bool = false
var last_damage_source: Node = null

enum State {
	IDLE,
	WALK,
	CHASE,
	ATTACK
}

# Node References
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision: CollisionShape2D = $Collision
@onready var pathfinder: NavigationAgent2D = $Pathfinder
@onready var range: Area2D = $Range
@onready var aggro: Area2D = $Aggro
@onready var health_bar: ProgressBar = $Healthbar
@onready var iframe_timer: Timer = $Iframe
@onready var flash_timer: Timer = $Flash
@onready var regen_timer: Timer = $Regen
@onready var attack_timer: Timer = $Attack

func _ready() -> void:
	add_to_group("entity")
	add_to_group("hostile_entity")
	
	set_physics_process(false)
	call_deferred("wait_for_physics")
	
	iframe_timer.wait_time = invincibility_duration
	iframe_timer.one_shot = true
	
	flash_timer.wait_time = invincibility_duration
	flash_timer.one_shot = true
	
	regen_timer.wait_time = regen_interval
	regen_timer.one_shot = true
	
	regen_timer.start()
	
func wait_for_physics() -> void:
	await get_tree().physics_frame
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	handle_movement(delta)

func _process(delta: float) -> void:
	update_stats()
	
func handle_movement(delta: float) -> void:
	if is_knocked_back:
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 2 * delta)
		if knockback_velocity.length() < 1:
			is_knocked_back = false
			knockback_velocity = Vector2.ZERO
			
		print("Applied Knockback: ", knockback_velocity)
	
	velocity += knockback_velocity
	move_and_slide()
	
func play_animation(state: String, direction: Vector2) -> void:
	if direction.x != 0:
		sprite.flip_h = direction.x < 0
	sprite.play(state)
	
func take_damage(options: DamageOptions):
	print(1)
	if is_invincible and not options.bypass_iframe:
		return
		
	var damage_taken = max(options.amount - (shield * shield_multiplier), 0)
	current_health -= damage_taken
	
	if options.apply_flash:
		flash_sprite(Color(1.5, 0.5, 0.5), 0.1)
		
	if options.knockback_power != 0:
		apply_knockback(options.attacker.global_position, options.knockback_power)
		
	if options.attacker:
		last_damage_source = options.attacker
		
	if current_health <= 0:
		die()
		
	is_invincible = true
	iframe_timer.start()
	flash_timer.start()
	
func flash_sprite(colour: Color, duration: float = 1.0) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", colour, duration)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.1)
	
func apply_knockback(direction, power: float) -> void:
	knockback_velocity = (global_position - direction).normalized() * (power * (1.0 - knockback_resistance))
	is_knocked_back = true
	
func die() -> void:
	velocity = Vector2.ZERO
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.5)
	await tween.finished
	queue_free()
	
func update_stats() -> void:
	health_bar.visible = current_health < max_health
	health_bar.value = (current_health / max_health) * 100
	
func run_loot_table() -> void:
	var items: Array[Dictionary] = []
	var rng = RandomNumberGenerator.new()
	for item in loot_table:
		if item.chance >= rng.randf_range(0.0, 1.0):
			items.append({
				"item_id": item.item_id,
				"quantity": rng.randi_range(item.quantity.min, item.quantity.max)
			})
		else:
			continue
			
	for item in items:
		GlobalInventory.add_item(item.item_id, item.quantity)
	
func _on_iframe_timeout() -> void:
	is_invincible = false

func _on_flash_timeout() -> void:
	pass

func _on_regen_timeout() -> void:
	if current_health < max_health:
		current_health = min(current_health + regen_amount, max_health)

func _on_attack_timeout() -> void:
	pass # Replace with function body.

func _on_aggro_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

func _on_aggro_body_exited(body: Node2D) -> void:
	pass # Replace with function body.

func _on_range_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

func _on_range_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
