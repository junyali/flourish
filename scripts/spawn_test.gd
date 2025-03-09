extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	while false:
		var t = randf_range(1, 3)
		var r = randi_range(1, 3)
		await get_tree().create_timer(t).timeout
		
		match r:
			1:
				spawn_enemy("blue_slime", Vector2(500, 500))
			2:
				spawn_enemy("green_slime", Vector2(500, 500))
			3:
				spawn_enemy("angry_bones", Vector2(500, 500))
			_:
				pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func spawn_enemy(enemy_type: String, position: Vector2):
	var enemy
	if enemy:
		enemy.global_position = position
		get_parent().add_child(enemy)
	
