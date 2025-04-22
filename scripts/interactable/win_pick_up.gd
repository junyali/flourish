extends "res://scripts/interactable/pick_up.gd"

func _ready() -> void:
	Sprite.texture = preload("res://art/gui/hud/trophy.png")
	
func pick_up(player: Node) -> void:
	SignalBus.game_won.emit()
	super(player)
