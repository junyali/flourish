extends TextureRect

var item_id = null # oh GDScript when will you have union types T-T
var count: int = 0
var item_texture: Texture2D = null

@onready var label: Label = $Count
@onready var itemrect: TextureRect = $Item

func set_item(item):
	item_id = item.item_id
	count = item.quantity
	item_texture = ItemDatabase.get_item_texture(item_id)
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
	set_process_input(true)

func _process(delta: float) -> void:
	pass
