extends CharacterBody2D

var enemy_in_attack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

const SPEED = 100.0
var direction : Vector2 = Vector2.ZERO
var current_dir = Vector2(0, 1)
var animatedir_dict = {
	"(0, -1)": ["back_idle", "back_walk", "back_jump", "back_attack"],
	"(0, 1)": ["front_idle", "front_walk", "front_jump", "front_attack"],
	"(-1, 0)": ["side_idle", "side_walk", "side_jump", "side_attack"],
	"(1, 0)": ["side_idle", "side_walk", "side_jump", "side_attack"]
}

var attack_in_progress = false

func _ready():
	$AnimatedSprite2D.play(animatedir_dict["(0, 1)"][0])

func _physics_process(delta: float) -> void:
	# Get Player direction via input
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction:
		current_dir = direction
		if not attack_in_progress:
			play_animation(1, direction)
		velocity = direction * SPEED
	else:
		if not attack_in_progress:
			play_animation(0, current_dir) # No movement
		velocity = Vector2.ZERO
		
	move_and_slide()
	enemy_attack()
	attack()
	
	if health <= 0:
		player_alive = false
		health = 0
		print("player has been killed")
		
	
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
			
func player():
	pass

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = true


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_attack_range = false
		
func enemy_attack():
	if enemy_in_attack_range and enemy_attack_cooldown == true:
		health -= 20
		enemy_attack_cooldown = false
		$Attack_CD.start()
		print(health)
		

func _on_attack_cd_timeout() -> void:
	enemy_attack_cooldown = true
	
func attack():
	var dir = str(current_dir)
	var anim = $AnimatedSprite2D
	
	if Input.is_action_just_pressed("attack"):
		Main.player_current_attack = true
		attack_in_progress = true
		if animatedir_dict.has(dir):
			var attackanim = animatedir_dict[dir][3]
			if current_dir.x == -1:
				anim.flip_h = true
			elif current_dir.x == 1:
				anim.flip_h = false
			anim.play(attackanim)
		$Deal_Attack_CD.start()

func _on_deal_attack_cd_timeout() -> void:
	$Deal_Attack_CD.stop()
	Main.player_current_attack = false
	attack_in_progress = false
