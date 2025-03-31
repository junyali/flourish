extends Resource
class_name LootTable

class LootEntry:
	var item_id: String
	var min_amount: int
	var max_amount: int
	var weight: float

	func _init(id: String, min_amt: int, max_amt: int, w: float = 1.0):
		item_id = id
		min_amount = min_amt
		max_amount = max_amt
		weight = w
		
var entries: Array[LootEntry] = []
var total_weight: float = 0.0

func add_entry(item_id: String, min_amount: int = 1, max_amount: int = 1, weight: float = 1.0) -> void:
	entries.append(LootEntry.new(item_id, min_amount, max_amount, weight))
	total_weight += weight

func roll() -> Array:
	var results: Array = []

	for entry in entries:
		if randf() <= entry.weight:
			var amount: int = randi_range(entry.min_amount, entry.max_amount)
			results.append({
				"item_id": entry.item_id,
				"quantity": amount
			})

	return results
	