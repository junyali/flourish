extends "res://scripts/resource/resource.gd"

func _init():
	pass
	
func _ready() -> void:
	object_texture = preload("res://art/object/resource/tree_a.png")
	hardness = 0.1
	health = 4.0
	loot_table = [
		{
			"item_id": "oak_log",
			"quantity": {
				"min": 3,
				"max": 3,
			},
			"chance": 1.0
		}
	]

	harvest_cue = true
	cue_range = 96.0
	cue_colour = Color(1.5, 1.5, 1.5)
	super()
	
func take_damage(amount: int) -> void:
	var random_sound = randi_range(1, 3)
	sound_player = SoundManager.play_spatial_sfx(load("res://sfx/resource/tree_axe_" + str(random_sound) + ".wav"), self, 1.0)
	super(amount)
	
func harvest() -> void:
	sound_player = SoundManager.play_spatial_sfx(load("res://sfx/resource/tree_fell.wav"), self, 1.0)
	super()
