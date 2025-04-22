extends "res://scripts/interactable/pick_up.gd"

func _ready() -> void:
	Sprite.texture = preload("res://art/gui/hud/shield.png")
	
func pick_up(player: Node) -> void:
	player.shield += 10
	super(player)
