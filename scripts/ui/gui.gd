extends CanvasLayer

# UI Variables
var effect_progress_bars = {}

# Inventory Dragging
var dragging_item = null
var drag_offset = Vector2.ZERO
var drag_node = null


# Node References
@onready var player = get_tree().get_first_node_in_group("player")
@onready var heart_container = $HUD/TopLeftCorner/StatContainer/HeartContainer
@onready var prot_container = $HUD/TopLeftCorner/StatContainer/ProtContainer
@onready var cooldown_container = $HUD/TopLeftCorner/StatContainer/CooldownContainer
@onready var effect_container = $HUD/TopLeftCorner/EffectContainer
@onready var inventory_ui = $Inventory
@onready var inventory_grid = $Inventory/TextureRect/GridContainer
@onready var controls_ui = $Controls
@onready var controls_list = $Controls/ControlsList

var available_controls = {}

func _ready() -> void:
	inventory_ui.visible = false

func _process(delta: float) -> void:
	if Global.Player:
		update_stat_display(delta)
		update_inventory()
		check_controls()
	if Input.is_action_just_pressed("ui_inventory"):
		toggle_inventory()
	if dragging_item and drag_node:
		drag_node.position = get_viewport().get_global_mouse_position() + drag_offset
		
func check_controls() -> void:
	if Global.Player.can_dash:
		set_control("dash", "characters", Rect2(0, 64, 16, 16))
	else:
		remove_control("dash")
	
	var can_harvest: bool = false
	for body in Global.Player.attack_area.get_overlapping_bodies():
		if body.is_in_group("resource"):
			can_harvest = true
			break
	if can_harvest:
		set_control("harvest", "characters", Rect2(64, 32, 16, 16))
	else:
		remove_control("harvest")
		
	set_control("attack", "characters", Rect2(64, 32, 16, 16))
	set_control("backpack", "characters", Rect2(16, 32, 16, 16))
	set_control("sprint", "extras", Rect2(0, 16, 32, 16))
	
func update_stat_display(delta: float) -> void:
	var current_hp = Global.Player.current_health
	var max_hp = Global.Player.max_health
	var shield = Global.Player.shield
	var is_sprinting = Global.Player.is_sprinting
	var movement_ability_cd = Global.Player.movement_timer.time_left / Global.Player.movement_timer.wait_time if not Global.Player.can_dash else 0
	var attack_timer_cd = Global.Player.attack_timer.time_left / Global.Player.attack_timer.wait_time if Global.Player.is_attacking else 0
	
	var hp_per_heart = max_hp / heart_container.get_child_count()
	var hearts = heart_container.get_children()
	var shield_label = prot_container.get_node("Shield").get_node("Label")
	
	for index in range(hearts.size()):
		var heart_fill = min(current_hp, hp_per_heart)
		hearts[index].value = (heart_fill / hp_per_heart) * 100
		
		current_hp -= hp_per_heart
		
	shield_label.text = str(shield)
	
	cooldown_container.get_node("Sprint").visible = is_sprinting
	if movement_ability_cd <= 0:
		cooldown_container.get_node("Dash").visible = false
	else:
		cooldown_container.get_node("Dash").value = lerp(15, 75, movement_ability_cd)
		cooldown_container.get_node("Dash").visible = true
		
	if attack_timer_cd <= 0:
		cooldown_container.get_node("Attack").visible = false
	else:
		cooldown_container.get_node("Attack").value = lerp(15, 75, attack_timer_cd)
		cooldown_container.get_node("Attack").visible = true
		
	cooldown_container.queue_sort()
	
	for effect_name in Global.Player.status_effects.keys():
		var effect = Global.Player.status_effects[effect_name]
		var time_left = effect.time_left
		var duration = effect.duration
		var amplification = effect.amplification
		
		if not effect_progress_bars.has(effect_name) and time_left > 0:
			var progress_bar = TextureProgressBar.new()
			var effect_texture = load("res://art/gui/effect/" + effect_name.to_lower() + ".png")
			progress_bar.name = effect_name
			progress_bar.texture_progress = effect_texture
			progress_bar.texture_under = effect_texture
			progress_bar.tint_under = Color.hex(0x333333ff)
			progress_bar.fill_mode = 5
			progress_bar.value = 0
			
			var time_label = Label.new()
			time_label.name = "Time"
			time_label.label_settings = preload("res://assets/labelsetting/flourish.tres")
			time_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			time_label.clip_text = true
			time_label.size = Vector2(32, 8)
			time_label.position = Vector2(0, 26)
			time_label.text = str(snapped(time_left, 0.1)) + "s"
			progress_bar.add_child(time_label)
			
			var amplification_label = Label.new()
			amplification_label.name = "Amplification"
			amplification_label.label_settings = preload("res://assets/labelsetting/flourish.tres")
			amplification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			amplification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			amplification_label.clip_text = true
			amplification_label.size = Vector2(32, 8)
			amplification_label.position = Vector2(1, 1)
			amplification_label.text = Global.int_to_roman(amplification)
			progress_bar.add_child(amplification_label)
			
			effect_container.add_child(progress_bar)
			effect_progress_bars[effect_name] = progress_bar
			
		var progress_bar = effect_progress_bars[effect_name]
		var time_label = progress_bar.get_node("Time")
		var amplification_label = progress_bar.get_node("Amplification")
		progress_bar.value = (time_left / duration) * 100
		time_label.text = str(snapped(time_left, 0.1)) + "s"
		amplification_label.text = Global.int_to_roman(amplification)
		
		if time_left <= 0:
			progress_bar.queue_free()
			effect_progress_bars.erase(effect_name)
			
	for effect_name in effect_progress_bars.keys():
		if not Global.Player.status_effects.has(effect_name):
			effect_progress_bars[effect_name].queue_free()
			effect_progress_bars.erase(effect_name)
		
func toggle_inventory() -> void:
	inventory_ui.visible = not inventory_ui.visible
	if inventory_ui.visible:
		# Debug code
		var dir_path = "res://art/gui/items"
		var dir = DirAccess.open(dir_path)
		var item_list = dir.get_files()
		var count = 0
		for item in item_list:
			if item.contains("import"):
				item_list.remove_at(count)
			count += 1
		
		var ran = item_list[randi() % item_list.size()].replace(".png", "")
		var n = randi() % 8 + 1
		print(ran, n)
		
		GlobalInventory.add_item(ran, n)
		# End debug
		populate_inventory()
	else:
		clear_inventory()
		
func populate_inventory() -> void:
	for index in range(GlobalInventory.INVENTORY_SIZE):
		var item = GlobalInventory.items[index]
		var cell = inventory_grid.get_child(index)
		if item:
			cell.set_item(item)
			
func update_inventory() -> void:
	for index in range(GlobalInventory.INVENTORY_SIZE):
		var item = GlobalInventory.items[index]
		var cell = inventory_grid.get_child(index)

		if item:
			if cell.item_id != item.item_id or cell.count != item.quantity:
				cell.set_item(item)
		else:
			cell.clear_item()
			
func clear_inventory() -> void:
	for cell in inventory_grid.get_children():
		cell.clear_item()
		
func start_drag(cell) -> void:
	dragging_item = cell.item_texture
	drag_offset = cell.get_local_mouse_position()

	drag_node = TextureRect.new()
	drag_node.texture = dragging_item
	drag_node.rect_min_size = cell.rect_min_size
	add_child(drag_node)

	drag_node.position = get_viewport().get_global_mouse_position() + drag_offset
	
func update_controls_ui():
	var existing_controls = {}
	for child in controls_list.get_children():
		existing_controls[child.name] = child
		
	for action_name in available_controls.keys():
		if action_name in existing_controls:
			var control_ui = existing_controls[action_name]
			var control_data = available_controls[action_name]
			var control_atlas = AtlasTexture.new()
			control_ui.get_node("action").texture = control_data["action_icon"]
			control_atlas.atlas = control_data["key_icon"]
			control_atlas.region = control_data["key_atlas"]
			control_ui.get_node("key").texture = control_atlas
		else:
			var control_data = available_controls[action_name]
			var control_ui = preload("res://assets/ui/control_group.tscn").instantiate()
			var control_atlas = AtlasTexture.new()
			control_ui.name = action_name
			control_ui.get_node("action").texture = control_data["action_icon"]
			control_atlas.atlas = control_data["key_icon"]
			control_atlas.region = control_data["key_atlas"]
			control_ui.get_node("key").texture = control_atlas
			controls_list.add_child(control_ui)
			
	for action_name in existing_controls.keys():
		if action_name not in available_controls:
			existing_controls[action_name].queue_free()
	
func set_control(action: String, key_icon: String, key_atlas: Rect2):
	available_controls[action] = {
		"action_icon": load("res://art/gui/controls/" + action + ".png"),
		"key_icon": load("res://art/gui/controls/keyboard_" + key_icon + ".png"),
		"key_atlas": key_atlas
	}
	update_controls_ui()
	
func remove_control(action: String):
	if available_controls.has(action):
		available_controls.erase(action)
		update_controls_ui()
