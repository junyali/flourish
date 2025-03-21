extends StatusEffect
class_name BleedingEffect

func apply_effect(target) -> void:
	if target.has_method("take_damage"):
		target.take_damage(DamageOptions.new({
			"amount": 10 * amplification,
			"knockback_power": 0,
			"knockback_direction": Vector2(0, 0),
			"bypass_iframe": true,
			"apply_flash": false,
			"bypass_shield": true
		}))
		
	if target.has_method("flash_sprite"):
		target.flash_sprite(Color(1, 0, 0), 0.05)
