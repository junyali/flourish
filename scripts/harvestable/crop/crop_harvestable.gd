extends StaticBody2D

# Harvestable Attributes
@export var stages: Dictionary = {
	Stage.EMPTY: PlantStage.new(),
	Stage.SEEDED: PlantStage.new(),
	Stage.SPROUTING: PlantStage.new(),
	Stage.GROWING: PlantStage.new(),
	Stage.FLOWERING: PlantStage.new(),
	Stage.RIPE: PlantStage.new()
}

@export var harvest_cue: bool = true
@export var cue_range: float = 32.0
@export var cue_colour: Color = Color(1.5, 1.5, 1.5)

# Harvestable Variables
var current_crop: String = ""
var current_stage: Stage
var current_health: float
var hit_count: int = 0
var sound_player = null
var growth_timer: float = 0.0
var is_watered: bool = false
var needs_watering: bool = false

enum Stage {
	EMPTY,
	SEEDED,
	SPROUTING,
	GROWING,
	FLOWERING,
	RIPE
}

# Node References
@onready var sprite: Sprite2D = $Sprite
@onready var cue_sprite: Sprite2D = $CueSprite
@onready var tool_hint_sprite: Sprite2D = $ToolHintSprite
@onready var cue_area: CollisionShape2D = $CueArea/Detect

func _ready() -> void:
	add_to_group("harvestable")
	add_to_group("crop")
	if cue_area.shape is CircleShape2D:
		cue_area.shape.radius = cue_range

	current_stage = Stage.EMPTY
	current_health = stages[Stage.EMPTY].health
	
	setup_cue()
	
func _process(delta: float) -> void:
	if current_stage != Stage.EMPTY and current_stage != Stage.RIPE:
		growth_timer += delta
		check_growth()
		
	update_sprite()

func setup_cue() -> void:
	if harvest_cue:
		cue_sprite.texture = AtlasTexture.new()
		cue_sprite.texture.atlas = preload("res://art/gui/interactable/ui elements.png")
		cue_sprite.texture.region = Rect2(0, 0, 32, 32)

		tool_hint_sprite.texture = null

		cue_sprite.modulate.a = 0
		tool_hint_sprite.modulate.a = 0

		var start_pos: Vector2 = tool_hint_sprite.position
		var hint_tween: Tween  = create_tween().set_loops()
		hint_tween.tween_property(tool_hint_sprite, "position:y", start_pos.y - 1.0, 0.5)
		hint_tween.tween_property(tool_hint_sprite, "position:y", start_pos.y, 0.5)
		
func check_growth() -> void:
	var stage_data = stages[current_stage]
	if growth_timer >= stage_data.growth_time:
		if stage_data.require_water and not is_watered:
			needs_watering = true
			return
		else:
			advance_stage()
			growth_timer = 0.0
			is_watered = false
			needs_watering = false
			
func advance_stage() -> void:
	if current_stage < Stage.RIPE:
		match current_stage:
			Stage.EMPTY:
				current_stage = Stage.SEEDED
			Stage.SEEDED:
				current_stage = Stage.SPROUTING
			Stage.SPROUTING:
				current_stage = Stage.GROWING
			Stage.GROWING:
				current_stage = Stage.FLOWERING
			Stage.FLOWERING:
				current_stage = Stage.RIPE
			_:
				pass
		current_health = stages[current_stage].health
		update_sprite()

func plant_seed(crop_id: String) -> bool:
	if current_stage != Stage.EMPTY:
		return false
		
	current_crop = crop_id
	current_stage = Stage.SEEDED
	growth_timer = 0.0
	return true
	
func water_crop() -> void:
	if current_stage != Stage.EMPTY and current_stage != Stage.RIPE:
		is_watered = true
		needs_watering = false
		update_sprite()

func take_damage(amount: int) -> void:
	if current_stage == Stage.EMPTY: return
	
	var stage_data = stages[current_stage]
	if stage_data.one_hit or current_health <= amount:
		harvest()
	else:
		var hit: float = (amount - stage_data.hardness) - (amount * stage_data.hardness) if (amount - stage_data.hardness) - (amount * stage_data.hardness) else (amount) - (amount * stage_data.hardness)
		current_health -= hit
		
		handle_hit_feedback(hit)

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
	var stage_data = stages[current_stage]
	var loot = stage_data.loot_table.roll()
	
	for item in loot:
		GlobalInventory.add_item(item.item_id, item.quantity)
	
	current_stage = Stage.EMPTY
	current_crop = ""
	growth_timer = 0.0
	is_watered = false
	needs_watering = false
	update_sprite()
	
func update_sprite() -> void:
	var stage_data = stages[current_stage]
	sprite.texture = stage_data.texture_atlas
	sprite.offset = stage_data.sprite_offset
	
	var cue_alpha: float = cue_sprite.modulate.a
	var sprite_alpha: float = sprite.modulate.a
	
	if needs_watering:
		sprite.modulate = Color(0.5, 0.5, 1.0, sprite_alpha)
		tool_hint_sprite.texture = ItemDatabase.get_item_texture("watering_can")
	else:
		sprite.modulate = Color(1.0, 1.0, 1.0, sprite_alpha)
	
		match current_stage:
			Stage.EMPTY:
				cue_sprite.modulate = Color(1.0, 1.0, 1.0, cue_alpha)
				tool_hint_sprite.texture = ItemDatabase.get_item_texture("plant_pot")
				
			Stage.SEEDED:
				cue_sprite.modulate = Color(1.0, 0.2, 0.2, cue_alpha)
				tool_hint_sprite.texture = ItemDatabase.get_item_texture("hoe")
				
			Stage.RIPE:
				cue_sprite.modulate = Color(1.0, 1.5, 1.0, cue_alpha)
				tool_hint_sprite.texture = ItemDatabase.get_item_texture("hoe")
				
			_:
				cue_sprite.modulate = Color(1.0, 0.2, 0.2, cue_alpha)
				tool_hint_sprite.texture = ItemDatabase.get_item_texture("hoe")
			
func show_cue() -> void:
	if harvest_cue and current_health > 0:
		if not needs_watering:
			tween_sprite(cue_colour)

		var tween: Tween = create_tween()
		tween.tween_property(cue_sprite, "modulate:a", 1.0, 0.3)
		tween.parallel().tween_property(tool_hint_sprite, "modulate:a", 1.0, 0.3)


func hide_cue() -> void:
	if not needs_watering:
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
