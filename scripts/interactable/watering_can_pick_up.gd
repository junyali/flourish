extends "res://scripts/interactable/pick_up.gd"

func _ready() -> void:
	Sprite.texture = ItemDatabase.get_item_texture("watering_can")
	
func pick_up(player: Node) -> void:
	if not Hotbar.check_tool("watering_can"):
		Hotbar.add_tool("watering_can")
	super(player)