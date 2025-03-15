extends "res://scripts/resource/resource.gd"

func _ready():
	object_texture = preload("res://art/object/resource/log_b.png")
	hardness = 0.0
	health = 3.0
	loot_table = [
		{
			"item_id": "oak_log",
			"quantity": {
				"min": 1,
				"max": 1,
			},
			"chance": 1.0
		}
	]

	harvest_cue = true
	cue_range = 64.0
	cue_colour = Color(1.5, 1.5, 1.5)
	super()
