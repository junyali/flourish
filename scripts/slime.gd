extends CharacterBody2D

var SPEED = 40
var PLAYER_CHASE = false
var PLAYER = null

func _physics_process(delta: float) -> void:
	if PLAYER_CHASE:
		if position.distance_to(PLAYER.position) > 10:
			
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
