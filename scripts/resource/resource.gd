extends Node2D

# Resource Attributes
@export var object_texture: Texture2D = null
@export var hardness: float = 0.1
@export var health: float = 5.0
@export var loot_table: Array[Dictionary] = [{}]
@export var harvest_cue: bool = true
@export var cue_range: float = 32.0
@export var cue_colour: Color = Color(1.5, 1.5, 1.5)

# Resource Variables
var current_health: float = health

# Node References
@onready var sprite: Sprite2D = $Sprite
@onready var cue_area: CollisionShape2D = $CueArea/Detect

func _ready() -> void:
	add_to_group("resource")
	if object_texture and sprite:
		sprite.texture = object_texture
	if cue_area.shape is CircleShape2D:
		cue_area.shape.radius = cue_range
	
	
func take_damage(amount: int) -> void:
	var hit = (amount - hardness) - (amount * hardness) if (amount - hardness) - (amount * hardness) else (amount) - (amount * hardness)
	current_health -= hit
	hit = clamp(hit / 1.0, 0.0, 1.0)
	
	var original_pos = position
	var tween = sprite.create_tween()
	
	var hit_colour = lerp(Color(1.2, 1.0, 0.8), Color(1.0, 0.5, 0.5), hit)
	tween.tween_property(sprite, "modulate", hit_colour, 0.1)
	
	for index in range(3):
		tween.tween_property(self, "position", original_pos + Vector2(1, 0), 0.02)
		tween.tween_property(self, "position", original_pos - Vector2(1, 0), 0.02)
		
	tween.tween_property(self, "position", original_pos, 0.01)
	tween.tween_property(sprite, "modulate", cue_colour if harvest_cue else Color(1, 1, 1), 0.2)
	
	if current_health <= 0:
		current_health = 0
		harvest()
		
func harvest() -> void:
	run_loot_table()
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.5)
	await tween.finished
	queue_free()
	
func run_loot_table() -> void:
	var items: Array[Dictionary] = []
	for item in loot_table:
		var ran = RandomNumberGenerator.new()
		if item.chance >= ran.randf_range(0.0, 1.0):
			items.append({
				"item_id": item.item_id,
				"quantity": ran.randi_range(item.quantity.min, item.quantity.max)
			})
		else:
			continue
			
	for item in items:
		GlobalInventory.add_item(item.item_id, item.quantity)
		
func show_cue() -> void:
	if harvest_cue:
		tween_sprite(cue_colour)

func hide_cue() -> void:
	tween_sprite(Color(1, 1, 1))
		
func tween_sprite(colour: Color, duration: float = 1.0) -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", colour, duration)

func _on_cue_area_body_entered(body: Node2D) -> void:
	var player = body.is_in_group("player")
	if player:
		show_cue()

func _on_cue_area_body_exited(body: Node2D) -> void:
	var player = body.is_in_group("player")
	if player:
		hide_cue()
