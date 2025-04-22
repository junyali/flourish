extends StaticBody2D

# Node References
@onready var Sprite: Sprite2D = $Sprite
@onready var Collision = $Collision
@onready var Area: Area2D = $Area

# Cool Sprite Animation :3
var bobbing_amplitude: float = 5.0
var bobbing_speed: float = 2.0
var original_position: Vector2

func _ready() -> void:
	original_position = Sprite.position
	
func _process(delta: float) -> void:
	Sprite.position.y = original_position.y + sin(Time.get_ticks_msec() / 1000.0 * bobbing_speed) * bobbing_amplitude

func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group(Groups.PLAYER_GROUP):
		pick_up(body)
		
func pick_up(player: Node) -> void:
	fade_out()
	
func fade_out() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(Sprite, "modulate:a", 0.0, 0.5)
	await tween.finished
	queue_free()
