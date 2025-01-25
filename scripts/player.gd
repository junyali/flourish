extends CharacterBody2D


@export var SPEED = 100.0
@export var GRAVITY = get_gravity() or 30
@export var JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if velocity.y > 1000:
			velocity.y = 1000
		else:
			velocity += get_gravity() * delta

	# Handle jump.
	var count = 0
	if Input.is_action_just_pressed("jump") && is_on_floor():
		if count == 0:
			velocity.y = JUMP_VELOCITY
			count += 1
		elif count == 1:
			velocity.y += JUMP_VELOCITY
	if is_on_floor():
		count = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x += direction * SPEED
		velocity.x *= 0.8
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
