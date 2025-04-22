extends "res://scripts/interactable/pick_up.gd"

func _ready() -> void:
	Sprite.texture = ItemDatabase.get_item_texture("axe")
	
func pick_up(player: Node) -> void:
	if not Hotbar.check_tool("axe"):
		Hotbar.add_tool("axe")
	super(player)