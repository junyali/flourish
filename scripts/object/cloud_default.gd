extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $Collision
@onready var requirement: Sprite2D = $Requirement
@onready var sprite_image: Sprite2D = $Requirement/Image
@onready var label: Label = $Requirement/Label

var required_item: String = "carrot_seed"
var required_amount: int = 1
var take_items: bool = true

var wobble_amplitude: float = 2.0
var wobble_speed: float = 1.0
var time_passed: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("cloud")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta
	var wobble_offset = Vector2(
		wobble_amplitude * sin(time_passed * wobble_speed),
		wobble_amplitude * cos(time_passed * wobble_speed)
	)
	sprite.position = wobble_offset
	requirement.position = wobble_offset
	
	update_requirement_display()
	
func set_requirement(item: String, amount: int) -> void:
	required_item = item
	required_amount = amount
	
func update_requirement_display() -> void:
	sprite_image.texture = ItemDatabase.get_sprite_texture(required_item)
	label.text = "x" + str(required_amount)
	
	var tween: Tween = create_tween()
	if check_requirements():
		tween.tween_property(label, "modulate", Color(0.5, 1, 0.5), 0.5)
	else:
		tween.tween_property(label, "modulate", Color(1, 0.5, 0.5), 0.5)
	
func check_requirements() -> bool:
	if Global.Player:
		var items = GlobalInventory.get_items()
		var count = 0
		for item in items:
			if item and item.item_id == required_item:
				count += item.quantity
				
		if count >= required_amount:
			return true
		else:
			return false
	else:
		return false
		
func remove() -> void:
	if take_items:
		if Global.Player:
			GlobalInventory.remove_item(required_item, required_amount)
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	await tween.finished
	queue_free()
	
