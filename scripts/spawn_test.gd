extends Node2D

var blue_slime = preload("res://scenes/blue_slime.tscn")
var green_slime = preload("res://scenes/green_slime.tscn")
var angry_bones = preload("res://scenes/angry_bones.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	while true:
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
	match enemy_type:
		"blue_slime":
			enemy = blue_slime.instantiate()
		"green_slime":
			enemy = green_slime.instantiate()
		"angry_bones":
			enemy = angry_bones.instantiate()
	if enemy:
		enemy.global_position = position
		get_parent().add_child(enemy)
	
