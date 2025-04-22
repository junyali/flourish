extends "res://scripts/harvestable/crop/crop_harvestable.gd"

func _ready():
	stages = {
		Stage.EMPTY: PlantStage.new(),
		Stage.SEEDED: PlantStage.new({
			"hardness": 0.0,
			"health": 0.1,
			"growth_time": 40.0,
			"growth_randomness": 100.0,
			"texture_atlas": ItemDatabase.get_sprite_texture("lettuce_seed"),
			"sprite_offset": Vector2(0, -4),
			"one_hit": true,
			"require_water": true,
			"loot_table": setup_loot_table(Stage.SEEDED)
		}),
		Stage.SPROUTING: PlantStage.new({
			"hardness": 0.0,
			"health": 0.1,
			"growth_time": 40.0,
			"growth_randomness": 100.0,
			"texture_atlas": ItemDatabase.get_sprite_texture("lettuce_sprout"),
			"sprite_offset": Vector2(0, -4),
			"one_hit": true,
			"require_water": true,
			"loot_table": setup_loot_table(Stage.SPROUTING)
		}),
		Stage.GROWING: PlantStage.new({
			"hardness": 0.0,
			"health": 0.1,
			"growth_time": 40.0,
			"growth_randomness": 100.0,
			"texture_atlas": ItemDatabase.get_sprite_texture("lettuce_growing"),
			"sprite_offset": Vector2(0, -4),
			"one_hit": true,
			"require_water": true,
			"loot_table": setup_loot_table(Stage.GROWING)
		}),
		Stage.FLOWERING: PlantStage.new({
			"hardness": 0.0,
			"health": 0.1,
			"growth_time": 40.0,
			"growth_randomness": 100.0,
			"texture_atlas": ItemDatabase.get_sprite_texture("lettuce_flowering"),
			"sprite_offset": Vector2(0, -4),
			"one_hit": true,
			"require_water": true,
			"loot_table": setup_loot_table(Stage.FLOWERING)
		}),
		Stage.RIPE: PlantStage.new({
			"hardness": 0.0,
			"health": 0.1,
			"growth_time": 40.0,
			"growth_randomness": 100.0,
			"texture_atlas": ItemDatabase.get_sprite_texture("lettuce_ripe"),
			"sprite_offset": Vector2(0, -4),
			"one_hit": true,
			"require_water": false,
			"loot_table": setup_loot_table(Stage.RIPE)
		}),
	}
	
	add_to_group("require_hoe")
	
	harvest_cue = true
	cue_range = 32
	cue_colour = Color(1.5, 1.5, 1.5)
	
	current_crop = "lettuce"
	
	super()

	current_stage = Stage.SEEDED
	
func setup_loot_table(stage: Stage) -> LootTable:
	var table = LootTable.new()
	match stage:
		Stage.SEEDED:
			table.add_entry("lettuce_seed", 1, 1, 1.0)
		Stage.SPROUTING:
			table.add_entry("lettuce_seed", 1, 2, 1.0)
		Stage.GROWING:
			table.add_entry("lettuce_seed", 2, 4, 1.0)
		Stage.FLOWERING:
			table.add_entry("lettuce_seed", 1, 3, 1.0)
			table.add_entry("lettuce", 1, 1, 0.5)
		Stage.RIPE:
			table.add_entry("lettuce_seed", 0, 2, 0.8)
			table.add_entry("lettuce", 1, 3, 1.0)
		_:
			pass
		
	return table
		
