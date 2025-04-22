extends Node

const INVENTORY_SIZE: int = 15

var items: Array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	items.resize(INVENTORY_SIZE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_items() -> Array:
	return items
	
func add_item(item_id: String, quantity: int = 1) -> bool:
	for index in range(INVENTORY_SIZE):
		if items[index] and items[index].item_id == item_id:
			items[index].quantity += quantity
			return true
			
	for index in range(INVENTORY_SIZE):
		if items[index] == null:
			items[index] = {
				"item_id": item_id,
				"quantity": quantity
			}
			return true
			
	return false
	
func remove_item(item_id: String, quantity: int = 1) -> bool:
	for index in range(INVENTORY_SIZE):
		if items[index] and items[index].item_id == item_id:
			items[index].quantity -= quantity
			if items[index].quantity <= 0:
				items[index] = null	
			return true
			
	return false
		
func remove_item_by_index(index, quantity: int = 1) -> bool:
	if items[index]:
		items[index].quantity -= quantity
		if items[index].quantity <= 0:
			items[index] = null	
		return true
	else:
		return false
