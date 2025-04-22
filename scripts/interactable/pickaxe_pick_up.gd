extends "res://scripts/interactable/pick_up.gd"

func _ready() -> void:
	Sprite.texture = ItemDatabase.get_item_texture("pickaxe")
	
func pick_up(player: Node) -> void:
	if not Hotbar.check_tool("pickaxe"):
		Hotbar.add_tool("pickaxe")
	super(player)
