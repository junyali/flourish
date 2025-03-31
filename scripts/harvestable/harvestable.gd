extends StaticBody2D

# Harvestable Attributes
@export var hardness: float = 0.1
@export var health: float = 5.0
@export var harvest_cue: bool = true
@export var cue_range: float = 32.0
@export var cue_colour: Color = Color(1.5, 1.5, 1.5)

# Harvestable Variables
var current_health: float
var hit_count: int = 0
var loot_table: LootTable
var sound_player = null

# Node References
@onready var sprite: Sprite2D = $Sprite
@onready var cue_sprite: Sprite2D = $CueSprite
@onready var tool_hint_sprite: Sprite2D = $ToolHintSprite
@onready var cue_area: CollisionShape2D = $CueArea/Detect

func _ready() -> void:
	add_to_group("harvestable")
	if cue_area.shape is CircleShape2D:
		cue_area.shape.radius = cue_range
		
	current_health = health
		
	setup_loot_table()
	setup_cue()
		
func setup_loot_table() -> void:
	loot_table = LootTable.new()
	
func setup_cue() -> void:
	if harvest_cue:
		cue_sprite.texture = AtlasTexture.new()
		cue_sprite.texture.atlas = preload("res://art/gui/interactable/ui elements.png")
		cue_sprite.texture.region = Rect2(0, 0, 32, 32)
		
		tool_hint_sprite.texture = ItemDatabase.get_item_texture("axe")
	
		cue_sprite.modulate.a = 0
		tool_hint_sprite.modulate.a = 0
	
		var start_pos: Vector2 = tool_hint_sprite.position
		var hint_tween: Tween  = create_tween().set_loops()
		hint_tween.tween_property(tool_hint_sprite, "position:y", start_pos.y - 1.0, 0.5)
		hint_tween.tween_property(tool_hint_sprite, "position:y", start_pos.y, 0.5)
	
func take_damage(amount: int) -> void:
	if current_health > 0:
		var hit: float = (amount - hardness) - (amount * hardness) if (amount - hardness) - (amount * hardness) else (amount) - (amount * hardness)
		current_health -= hit
		hit = clamp(hit / 1.0, 0.0, 1.0)
		
		hit_count += 1
		
		handle_hit_feedback(hit)
	
		if current_health <= 0:
			current_health = 0
			harvest()
			
func handle_hit_feedback(hit: float) -> void:
	var original_pos: Vector2 = position
	var tween: Tween = sprite.create_tween()
	var hit_colour = lerp(Color(1.2, 1.0, 0.8), Color(1.0, 0.5, 0.5), hit)
	
	tween.tween_property(sprite, "modulate",hit_colour, 0.1)
	
	for index in range(0, 3):
		tween.tween_property(self, "position", original_pos + Vector2(1, 0), 0.02)
		tween.tween_property(self, "position", original_pos - Vector2(1, 0), 0.02) 
		
	tween.tween_property(self, "position", original_pos, 0.01)
	tween.tween_property(sprite, "modulate", cue_colour if harvest_cue else Color(1, 1, 1), 0.2)
		
func harvest() -> void:
	var loot: Array = loot_table.roll()

	for item in loot:
		GlobalInventory.add_item(item.item_id, item.quantity)
		
	fade_out()
		
func fade_out(time: float = 1.0) -> void:
	var tween: Tween = create_tween().set_parallel()
	tween.tween_property(cue_sprite, "modulate:a", 0.0, time * 0.3)
	tween.tween_property(tool_hint_sprite, "modulate:a", 0.0, time * 0.3)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), time)
	await tween.finished
	queue_free()
		
	

func show_cue() -> void:
	if harvest_cue and current_health > 0:
		tween_sprite(cue_colour)
		
		var tween: Tween = create_tween()
		tween.tween_property(cue_sprite, "modulate:a", 1.0, 0.3)
		tween.parallel().tween_property(tool_hint_sprite, "modulate:a", 1.0, 0.3)
		

func hide_cue() -> void:
	tween_sprite(Color(1, 1, 1))
	var tween: Tween = create_tween()
	tween.tween_property(cue_sprite, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(tool_hint_sprite, "modulate:a", 0.0, 0.3)

func tween_sprite(colour: Color, duration: float = 1.0) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "modulate", colour, duration)

func _on_cue_area_body_entered(body: Node2D) -> void:
	var player: bool = body.is_in_group(Groups.PLAYER_GROUP)
	if player:
		show_cue()

func _on_cue_area_body_exited(body: Node2D) -> void:
	var player: bool = body.is_in_group(Groups.PLAYER_GROUP)
	if player:
		hide_cue()
