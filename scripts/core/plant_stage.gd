extends Resource
class_name PlantStage

@export var hardness: float
@export var health: float
@export var texture_atlas: Texture2D
@export var tool_hint_texture: Texture2D
@export var sprite_offset: Vector2
@export var growth_time: float
@export var require_water: bool
@export var one_hit: bool # Bypasses health and hardness
@export var loot_table: LootTable

func _init(data: Dictionary = {}) -> void:
	texture_atlas = data.get("texture_atlas", null)
	sprite_offset = data.get("sprite_offset", Vector2.ZERO)
	growth_time = data.get("growth_time", 0.0)
	health = data.get("health", 1.0)
	hardness = data.get("hardness", 0.0)
	one_hit = data.get("one_hit", false)
	require_water = data.get("require_water", false)
	loot_table = data.get("loot_table", LootTable.new())
