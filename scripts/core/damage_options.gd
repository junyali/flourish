# A GDScript class for storing all options for take_damage() methods as a structure :3
extends RefCounted
class_name DamageOptions

## PARAMETERS ##
var amount: float = 0.0
var knockback_power: float = 0.0
var knockback_direction: Vector2 = Vector2.ZERO
var apply_flash: bool = true
var bypass_shield: bool = false
var bypass_iframe: bool = false
var attacker: Node = null

## CONSTRUCTOR ##
func _init(values: Dictionary = {}) -> void:
	for key in values:
		if key in self:
			self[key] = values[key]
