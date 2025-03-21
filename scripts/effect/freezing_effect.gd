extends StatusEffect
class_name FreezingEffect

func apply_effect(target) -> void:
	if target.has_method("take_damage"):
		target.velocity *= 0.2
		
	if target.has_method("flash_sprite"):
		target.flash_sprite(Color(0.35, 0.55, 0.88), 1)
