extends "res://scripts/interactable/pick_up.gd"

func _ready() -> void:
	Sprite.texture = ItemDatabase.get_item_texture("hoe")
	
func pick_up(player: Node) -> void:
	if not Hotbar.check_tool("hoe"):
		Hotbar.add_tool("hoe")
	super(player)