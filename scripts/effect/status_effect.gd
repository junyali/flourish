# GDScript for handling effects on entities incl Player
extends RefCounted
class_name StatusEffect

## PARAMETERS
var effect_name: String
var duration: float
var time_left: float
var amplification: int
var tick_interval: float
var time_since_last_tick: float = 0.0

## METHODS
func _init(_effect_name: String, _duration: float, _amplification: int, _tick_interval: float, _time_since_last_tick: float):
	effect_name = _effect_name
	duration = _duration
	time_left = _duration
	amplification = _amplification
	tick_interval = _tick_interval
	time_since_last_tick = _time_since_last_tick
	
# To be overriden
func apply_effect(target) -> void:
	pass
	
func update_effect(delta: float, target) -> bool:
	time_left -= delta
	time_since_last_tick += delta
	
	if time_since_last_tick >= tick_interval:
		time_since_last_tick = 0
		apply_effect(target)
		
	return time_left <= 0
