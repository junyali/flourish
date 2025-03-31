extends "res://scripts/harvestable/harvestable.gd"

# Harvestable Variables
var stage: int = 1
var stage_loot_tables: Dictionary = {}

func _init():
	pass

func _ready():
	add_to_group("require_pickaxe")
	hardness = 0.2
	health = 5.0
	harvest_cue = true
	cue_range = 32.0
	cue_colour = Color(1.5, 1.5, 1.5)

	sprite.texture = AtlasTexture.new()
	sprite.texture.atlas = preload("res://art/tilemap/object/autumn items.png")
	sprite.texture.region = Rect2(48, 96, 32, 32)
	sprite.offset = Vector2(0, -9)

	super()

	tool_hint_sprite.texture = ItemDatabase.get_item_texture("pickaxe")

func setup_loot_table() -> void:
	var rock_table = LootTable.new()
	rock_table.add_entry("pebble", 3, 5, 1.0)
	stage_loot_tables[1] = rock_table

func take_damage(amount: int) -> void:
	if current_health > 0 and stage != 4:
		var random_sound = randi_range(1, 3)
		sound_player = SoundManager.play_spatial_sfx(load("res://sfx/resource/rock_deposit_" + str(random_sound) + ".wav"), self, 1.0)
	super(amount)

func harvest() -> void:
	sound_player = SoundManager.play_spatial_sfx(load("res://sfx/resource/rock_destroy.wav"), self, 1.0)
	sound_player.pitch_scale = 0.75

	if stage_loot_tables.has(1):
		var loot = stage_loot_tables[1].roll()
		for item in loot:
			GlobalInventory.add_item(item.item_id, item.quantity)

	stage = 4
	fade_out(0.4)
	
	
