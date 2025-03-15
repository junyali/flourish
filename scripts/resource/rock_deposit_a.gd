extends "res://scripts/resource/resource.gd"

func _ready():
	object_texture = preload("res://art/object/resource/rock_deposit_a.png")
	hardness = 0.2
	health = 5.0
	loot_table = [
		{
			"item_id": "rock",
			"quantity": {
				"min": 3,
				"max": 5,
			},
			"chance": 1.0
		},
		{
			"item_id": "plant_2",
			"quantity": {
				"min": 1,
				"max": 1,
			},
			"chance": 0.1
		}
	]

	harvest_cue = true
	cue_range = 64.0
	cue_colour = Color(1.5, 1.5, 1.5)
	super()
