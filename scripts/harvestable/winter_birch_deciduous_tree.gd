extends "res://scripts/harvestable/harvestable.gd"

# Harvestable Variables
var stage: int = 1
var stage_loot_tables: Dictionary = {}

func _init():
	pass

func _ready() -> void:
	add_to_group("require_axe")
	hardness = 0.1
	health = 4.0
	harvest_cue = true
	cue_range = 64.0
	cue_colour = Color(1.5, 1.5, 1.5)
	super()
	
	tool_hint_sprite.texture.region = Rect2(48, 0, 16, 16)
	
	update_stage()

func setup_loot_table() -> void:
	var fallen_table = LootTable.new()
	fallen_table.add_entry("birch_log", 2, 4, 1.0)
	fallen_table.add_entry("snowball", 0, 1, 1.0)
	stage_loot_tables[1] = fallen_table

	var stump_table = LootTable.new()
	stump_table.add_entry("birch_log", 1, 2, 0.8)
	stage_loot_tables[2] = stump_table

func setup_cue() -> void:
	super()
	tool_hint_sprite.texture = ItemDatabase.get_item_texture("axe")

func update_stage() -> void:
	if current_health <= 0:
		harvest()
		stage = 2
		current_health = health - 1.0

	match stage:
		1:
			sprite.texture = AtlasTexture.new()
			sprite.texture.atlas = preload("res://art/tilemap/object/winter objects.png")
			sprite.texture.region = Rect2(96, 0, 48, 64)
			sprite.offset = Vector2(-5, -31)
		2:
			sprite.texture.atlas = preload("res://art/tilemap/object/spring and summer objects.png")
			sprite.texture.region = Rect2(96, 64, 48, 16)
			sprite.offset = Vector2(2, -3)
		_:
			pass

func take_damage(amount: int) -> void:
	if stage != 3:
		var random_sound = randi_range(1, 3)
		sound_player = SoundManager.play_spatial_sfx(load("res://sfx/resource/tree_axe_" + str(random_sound) + ".wav"), self, 1.0)
		super(amount)
	update_stage()

func harvest() -> void:
	match stage:
		1:
			sound_player = SoundManager.play_spatial_sfx(load("res://sfx/resource/tree_fell.wav"), self, 1.0)
			var loot = stage_loot_tables[1].roll()
			for item in loot:
				GlobalInventory.add_item(item.item_id, item.quantity)
		2:
			var loot = stage_loot_tables[2].roll()
			for item in loot:
				GlobalInventory.add_item(item.item_id, item.quantity)
			stage = 3
			fade_out()
		_:
			pass
