extends "res://scripts/interactable/pick_up.gd"

func _ready() -> void:
	Sprite.texture = ItemDatabase.get_item_texture("sword")
	
func pick_up(player: Node) -> void:
	if not Hotbar.check_tool("sword"):
		Hotbar.add_tool("sword")
	super(player)
	
