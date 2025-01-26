extends CharacterBody2D


const SPEED = 100.0
var direction : Vector2 = Vector2.ZERO
var current_dur = "(0, 0)"
var animatedir_dict = {
	"(0, -1)": ["back_idle", "back_walk", "back_jump", "back_attack"],
	"(0, 1)": ["front_idle", "front_walk", "front_jump", "front_attack"],
	"(-1, 0)": ["side_idle", "side_walk", "side_jump", "side_attack"],
	"(1, 0)": ["side_idle", "side_walk", "side_jump", "side_attack"]
}


func _ready():
	$AnimatedSprite2D.play(animatedir_dict["(0, 1)"][0])

func _physics_process(delta: float) -> void:
	# Get Player direction via input
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction:
		current_dur = direction
		play_animation(1, direction)
		velocity = direction * SPEED
	else:
		play_animation(0, current_dur) # No movement
		velocity = Vector2.ZERO
		
	move_and_slide()
	
func play_animation(ismoving, direction):
	var dir = str(direction)
	var anim = $AnimatedSprite2D
	
	if animatedir_dict.has(dir):
		var actionpose = animatedir_dict[dir][1]
		var idlepose = animatedir_dict[dir][0]
		
		if ismoving:
			if direction.x == -1:
				anim.flip_h = true
			elif direction.x == 1:
				anim.flip_h = false
			anim.play(actionpose)
		else:
			anim.play(idlepose)
