extends TextureRect

var item_id = null # oh GDScript when will you have union types T-T
var count: int = 0
var item_texture: Texture2D = null
var is_dragging: bool = false

@onready var label: Label = $Count
@onready var itemrect: TextureRect = $Item

func set_item(item):
	item_id = item.item_id
	count = item.quantity
	item_texture = load("res://art/gui/items/" + item_id.to_lower() + ".png")
	itemrect.texture = item_texture
	label.text = str(count) if count > 0 else ""
	
func clear_item():
	item_id = null
	count = 0
	item_texture = null
	itemrect.texture = null
	label.text = ""

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func _process(delta: float) -> void:
	pass
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button.index == MOUSE_BUTTON_LEFT:
			_on_item_clicked()
	elif event is InputEventMouseButton and event.button.index == MOUSE_BUTTON_LEFT and not event.pressed and is_dragging:
		# Gui.stop_drag(self)
		pass
			
func _on_item_clicked():
	if item_id:
		is_dragging = true
		Gui.start_drag(self)
