extends Node

const GAME_VERSION = "0.1.0a"

var Player = null

var start_time: int = 0
var death_count: int = 0

func _ready() -> void:
	start_time = Time.get_ticks_msec()

# Int to Roman Numeral (Str)
func int_to_roman(num: int) -> String:
	var roman_numerals = [
		[1000, "M"],
		[900, "CM"],
		[500, "D"],
		[400, "CD"],
		[100, "C"],
		[90, "XC"],
		[50, "L"],
		[40, "XL"],
		[10, "X"],
		[9, "IX"],
		[5, "V"],
		[4, "IV"],
		[1, "I"]
	]

	var result = ""

	for pair in roman_numerals:
		var value = pair[0]
		var symbol = pair[1]

		while num >= value:
			result += symbol
			num -= value
			
	return result
