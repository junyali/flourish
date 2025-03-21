extends StatusEffect
class_name BurningEffect

func apply_effect(target) -> void:
	if target.has_method("take_damage"):
		target.take_damage(DamageOptions.new({
			"amount": 10 * amplification,
			"knockback_power": 4,
			"knockback_direction": Vector2(8, 8),
			"bypass_iframe": true,
			"apply_flash": false,
			"bypass_shield": true
		}))
		
	if target.has_method("flash_sprite"):
		target.flash_sprite(Color(1, 0.4, 0.05), 0.05)
