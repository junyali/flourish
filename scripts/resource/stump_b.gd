extends "res://scripts/resource/resource.gd"

func _ready():
	object_texture = preload("res://art/object/resource/stump_b.png")
	hardness = 0.0
	health = 3.0
	loot_table = [
		{
			"item_id": "oak_log",
			"quantity": {
				"min": 1,
				"max": 2,
			},
			"chance": 1.0
		}
	]

	harvest_cue = true
	cue_range = 64.0
	cue_colour = Color(1.5, 1.5, 1.5)
	super()
	
func take_damage(amount: int):
	var random_sound = randi_range(1, 3)
	sound_player = SoundManager.play_spatial_sfx(load("res://sfx/resource/tree_axe_" + str(random_sound) + ".wav"), self, 1.0)
	super(amount)
