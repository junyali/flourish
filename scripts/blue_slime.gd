extends CharacterBody2D # Base class for an enemy :3

# // Enemy Attributes
@export var max_health: int = 100
@export var speed: float = 50.0
@export var attack_range: float = 10.0
@export var attack_speed: float = 0.5
@export var base_damage: float = 5.0

# // Variables
var sprite: AnimatedSprite2D = null
var iframe: Timer = null
var attack_cd: Timer = null
var healthbar: ProgressBar = null

var target = null

var current_health: int
var aggro = false
var can_be_attacked = true
var can_attack = true
var vulnerable = true
var target_in_range = false

# // Functions
func _ready():
	sprite = $sprite
	iframe = $iframe
	attack_cd = $attack_cd
	healthbar = $healthbar
	
	current_health = max_health
	attack_cd.wait_time = attack_speed
	
	print(position, global_position)
	
func _physics_process(delta: float) -> void:
	attack()
	move_towards_player()
	update_health()
	
	
func move_towards_player():
	if aggro and target:
		var direction = (target.position - position).normalized()
		
		if position.distance_to(target.position) > attack_range:
			
			position += (target.position - position) / speed
			
			sprite.play("side_walk")
			
			if (target.position.x - position.x) < 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
	else:
		sprite.play("front_idle")
	move_and_slide()
	
func _on_aggro_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.has_method("player"):
		target = body
		aggro = true

func _on_aggro_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.has_method("player"):
		target = null
		aggro = false
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		target_in_range = true
		can_be_attacked = true


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		target_in_range = false
		can_be_attacked = false
		
func take_damage() -> void:
	if can_be_attacked and Main.player_current_attack == true:
		if vulnerable:
			iframe.start()
			vulnerable = false
			current_health -= 20
			if current_health <= 0:
				sprite.play("death")
				
func die() -> void:
	sprite.play("death")
	
func attack() -> void:
	if target_in_range and can_attack:
		target.health -= 5
		can_attack = false
		attack_cd.start()
		
func _on_attack_cd_timeout() -> void:
	can_attack = true
	
func _on_sprite_animation_finished() -> void:
	if current_health <= 0:
		queue_free()

func _on_iframe_timeout() -> void:
	vulnerable = true
	
func update_health() -> void:
	healthbar.value = (current_health / max_health) * 100
