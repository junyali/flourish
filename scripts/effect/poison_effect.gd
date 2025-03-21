extends StatusEffect
class_name PoisonEffect

func apply_effect(target) -> void:
	if target.has_method("take_damage"):
		target.take_damage(DamageOptions.new({
			"amount": 5 + (2.5 * amplification),
			"knockback_power": 2,
			"knockback_direction": Vector2(2, 2),
			"bypass_iframe": true,
			"apply_flash": false,
			"bypass_shield": true
		}))
		
	if target.has_method("flash_sprite"):
		target.flash_sprite(Color(0.0, 0.5, 0.0), 0.05)
