extends Node

const HOTBAR_SIZE: int = 5

var tools: Array = ["", "", "", "", ""]
var selected_slot: int = 0
var last_input_time: float = 0.0

signal hotbar_changed(selected_slot)

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			select_previous_slot()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			select_next_slot()
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1, KEY_KP_1:
				select_slot(0)
			KEY_2, KEY_KP_2:
				select_slot(1)
			KEY_3, KEY_KP_3:
				select_slot(2)
			KEY_4, KEY_KP_4:
				select_slot(3)
			KEY_5, KEY_KP_5:
				select_slot(4)
	elif Input.is_action_just_pressed("ui_cycle_left"):
		select_previous_slot()
	elif Input.is_action_just_pressed("ui_cycle_right"):
		select_next_slot()

func select_next_slot() -> void:
	selected_slot = (selected_slot + 1) % HOTBAR_SIZE
	hotbar_changed.emit(selected_slot)
	
func select_previous_slot() -> void:
	selected_slot = (selected_slot - 1 + HOTBAR_SIZE) % HOTBAR_SIZE
	hotbar_changed.emit(selected_slot)

func select_slot(slot: int) -> void:
	if slot >= 0 and slot < HOTBAR_SIZE:
		selected_slot = slot
		hotbar_changed.emit(selected_slot)
		
func check_tool(tool) -> bool:
	return tool in tools

func add_tool(tool, index: int = -1) -> bool:
	if index <= -1 or index >= HOTBAR_SIZE:
		for i in range(HOTBAR_SIZE):
			if tools[i] == "":
				tools[i] = tool
				return true
		return false
	else:
		tools[index] = tool
		return true
	return false

func remove_tool(tool) -> void:
	if tool in tools:
		tools[tools.find(tool)] = ""
