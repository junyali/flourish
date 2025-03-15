extends "res://scripts/resource/resource.gd"

func _init():
	pass
	
func _ready():
	object_texture = preload("res://art/object/resource/tree_extra_a.png")
	hardness = 0.1
	health = 5.0
	loot_table = [
		{
			"item_id": "oak_log",
			"quantity": {
				"min": 2,
				"max": 3,
			},
			"chance": 1.0
		},
		{
			"item_id": "spice_1",
			"quantity": {
				"min": 0,
				"max": 1,
			},
			"chance": 0.4
		},
		{
			"item_id": "spice_3",
			"quantity": {
				"min": 0,
				"max": 3,
			},
			"chance": 1.0
		}
	]

	harvest_cue = true
	cue_range = 96.0
	cue_colour = Color(1.5, 1.5, 1.5)
	super()
