extends CharacterBody2D

var SPEED = 50
var PLAYER_CHASE = false
var PLAYER = null

var health = 200
var player_in_attack_zone = false
var can_take_damage = true

func _physics_process(delta: float) -> void:
	deal_with_damage()
	
	if PLAYER_CHASE:
		if position.distance_to(PLAYER.position) > 10:
			
			if player_in_attack_zone:
				$AnimatedSprite2D.play("side_attack")
			
				if (PLAYER.position.x - position.x) < 0:
					$AnimatedSprite2D.flip_h = true
				else:
					$AnimatedSprite2D.flip_h = false
			else:
			
				position += (PLAYER.position - position) / SPEED
				
				$AnimatedSprite2D.play("side_walk")
				
				if (PLAYER.position.x - position.x) < 0:
					$AnimatedSprite2D.flip_h = true
				else:
					$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("front_idle")
	move_and_slide()

func _on_aggro_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	PLAYER = body
	PLAYER_CHASE = true


func _on_aggro_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	PLAYER = null
	PLAYER_CHASE = false

func enemy():
	pass


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_attack_zone = true


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_attack_zone = false
		
func deal_with_damage():
	if player_in_attack_zone and Main.player_current_attack == true:
		if can_take_damage:
			$iframe.start()
			can_take_damage = false
			health -= 20
			if health <= 0:
				$AnimatedSprite2D.play("death")
			
func _on_animated_sprite_2d_animation_finished() -> void:
	if health <= 0:
		self.queue_free()

func _on_iframe_timeout() -> void:
	can_take_damage = true
