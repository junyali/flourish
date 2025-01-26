extends CharacterBody2D


const SPEED = 100.0
var current_dir = "none"

func _ready():
	$AnimatedSprite2D.play("front_idle")

func _physics_process(delta: float) -> void:
	player_movement(delta)
	
func player_movement(delta: float) -> void:
	
	# Main movement
	if Input.is_action_pressed("move_right"):
		current_dir = "right"
		play_animation(1)
		velocity.x = SPEED
		velocity.y = 0
	elif Input.is_action_pressed("move_left"):
		current_dir = "left"
		play_animation(1)
		velocity.x = -SPEED
		velocity.y = 0
	elif Input.is_action_pressed("move_up"):
		current_dir = "up"
		play_animation(1)
		velocity.x = 0
		velocity.y = -SPEED
	elif Input.is_action_pressed("move_down"):
		current_dir = "down"
		play_animation(1)
		velocity.x = 0
		velocity.y = SPEED
	else:
		play_animation(0)
		velocity.x = 0
		velocity.y = 0
		
	move_and_slide()
	
func play_animation(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			anim.play("side_idle")
	elif dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			anim.play("side_idle")
	elif dir == "up":
		anim.flip_h = false
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0:
			anim.play("back_idle")
	elif dir == "down":
		anim.flip_h = false
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0:
			anim.play("front_idle")
