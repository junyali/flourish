extends Node

var atlases: Dictionary = {}
var items: Dictionary = {}
var sprites: Dictionary = {}
var multi_sprites: Dictionary = {}

# Initialise
func _ready() -> void:
	## LOAD ATLAS
	register_atlas("items_1", "res://art/gui/item/items_1.png")
	register_atlas("items_2", "res://art/gui/item/items_2.png")
	
	register_atlas("food_1", "res://art/gui/item/food_1.png")
	register_atlas("objects_1", "res://art/gui/item/objects_1.png")
	register_atlas("tools_1", "res://art/gui/item/tools.png")
	register_atlas("resources_1", "res://art/gui/item/resources_1.png")
	register_atlas("flowers_1", "res://art/gui/item/flowers_1.png")
	register_atlas("wood_1", "res://art/gui/item/wood_1.png")
	register_atlas("rock_1", "res://art/gui/item/rock_1.png")

	register_atlas("plants_1", "res://art/gui/item/plants_1.png")
	register_atlas("plants_2", "res://art/gui/item/plants_2.png")
	
	## REGISTER ITEM
	register_item("bow", "tools_1", Rect2(0, 0, 16, 16))
	register_item("arrow", "tools_1", Rect2(16, 0, 16, 16))
	register_item("pickaxe", "tools_1", Rect2(32, 0, 16, 16))
	register_item("axe", "tools_1", Rect2(48, 0, 16, 16))
	register_item("sword", "tools_1", Rect2(64, 0, 16, 16))
	register_item("hoe", "tools_1", Rect2(80, 0, 16, 16))
	register_item("watering_can", "tools_1", Rect2(96, 0, 16, 16))
	register_item("fishing_rod", "tools_1", Rect2(112, 0, 16, 16))
	register_item("lantern", "tools_1", Rect2(128, 0, 16, 16))
	register_item("torch", "tools_1", Rect2(144, 0, 16, 16))
	
	register_item("pumpkin", "items_1", Rect2(0, 0, 16, 16))
	register_item("lettuce", "items_1", Rect2(16, 0, 16, 16))
	register_item("carrot", "items_1", Rect2(32, 0, 16, 16))
	register_item("wheat", "items_1", Rect2(48, 0, 16, 16))
	register_item("cocoa", "items_1", Rect2(64, 0, 16, 16))
	register_item("strawberry", "items_1", Rect2(80, 0, 16, 16))
	register_item("tomato", "items_1", Rect2(96, 0, 16, 16))
	register_item("aubergine", "items_1", Rect2(112, 0, 16, 16))
	register_item("onion", "items_1", Rect2(128, 0, 16, 16))
	register_item("sweetcorn", "items_1", Rect2(144, 0, 16, 16))
	register_item("pumpkin_seed_bag", "items_1", Rect2(0, 16, 16, 16))
	register_item("lettuce_seed_bag", "items_1", Rect2(16, 16, 16, 16))
	register_item("carrot_seed_bag", "items_1", Rect2(32, 16, 16, 16))
	register_item("wheat_seed_bag", "items_1", Rect2(48, 16, 16, 16))
	register_item("cocoa_seed_bag", "items_1", Rect2(64, 16, 16, 16))
	register_item("strawberry_seed_bag", "items_1", Rect2(80, 16, 16, 16))
	register_item("tomato_seed_bag", "items_1", Rect2(96, 16, 16, 16))
	register_item("aubergine_seed_bag", "items_1", Rect2(112, 16, 16, 16))
	register_item("onion_seed_bag", "items_1", Rect2(128, 16, 16, 16))
	register_item("sweetcorn_seed_bag", "items_1", Rect2(144, 16, 16, 16))
	
	register_item("pebble", "items_1", Rect2(0, 32, 16, 16))
	register_item("snowball", "items_1", Rect2(16, 32, 16, 16))
	register_item("birch_log", "items_1", Rect2(32, 32, 16, 16))
	register_item("oak_log", "items_1", Rect2(48, 32, 16, 16))
	register_item("oak_leaf", "items_1", Rect2(64, 32, 16, 16))
	register_item("maple_leaf", "items_1", Rect2(80, 32, 16, 16))
	register_item("cherry_petal", "items_1", Rect2(96, 32, 16, 16))
	register_item("brown_egg", "items_1", Rect2(96, 48, 16, 16))
	register_item("white_egg", "items_1", Rect2(112, 48, 16, 16))

	register_item("raw_chicken", "food_1", Rect2(0, 0, 16, 16))
	register_item("cooked_chicken", "food_1", Rect2(16, 0, 16, 16))
	register_item("raw_porkchop", "food_1", Rect2(32, 0, 16, 16))
	register_item("cooked_porkchop", "food_1", Rect2(48, 0, 16, 16))
	register_item("brown_mushroom", "food_1", Rect2(64, 0, 16, 16))
	register_item("purple_mushroom", "food_1", Rect2(80, 0, 16, 16))
	register_item("raw_beef", "food_1", Rect2(0, 16, 16, 16))
	register_item("steak", "food_1", Rect2(16, 16, 16, 16))
	register_item("raw_mutton", "food_1", Rect2(32, 16, 16, 16))
	register_item("cooked_mutton", "food_1", Rect2(48, 16, 16, 16))
	register_item("red_mushroom", "food_1", Rect2(64, 16, 16, 16))
	register_item("blue_mushroom", "food_1", Rect2(80, 16, 16, 16))
	
	register_item("berry", "objects_1", Rect2(16, 32, 16, 16))
	
	register_item("plant_pot", "flowers_1", Rect2(0, 32, 16, 16))
	
	## REGISTER SPRITES
	# Crops
	register_item("pumpkin_seed", "plants_1", Rect2(0, 0, 16, 16))
	register_sprite("pumpkin_sprout", "plants_1", Rect2(16, 0, 16, 16))
	register_sprite("pumpkin_growing", "plants_1", Rect2(32, 0, 16, 16))
	register_sprite("pumpkin_flowering", "plants_1", Rect2(48, 0, 16, 16))
	register_sprite("pumpkin_ripe", "plants_1", Rect2(64, 0, 16, 16))
	
	register_item("tomato_seed", "plants_1", Rect2(0, 16, 16, 16))
	register_sprite("tomato_sprout", "plants_1", Rect2(16, 16, 16, 16))
	register_sprite("tomato_growing", "plants_1", Rect2(32, 16, 16, 16))
	register_sprite("tomato_flowering", "plants_1", Rect2(48, 16, 16, 16))
	register_sprite("tomato_ripe", "plants_1", Rect2(64, 16, 16, 16))
	
	register_item("carrot_seed", "plants_1", Rect2(0, 32, 16, 16))
	register_sprite("carrot_sprout", "plants_1", Rect2(16, 32, 16, 16))
	register_sprite("carrot_growing", "plants_1", Rect2(32, 32, 16, 16))
	register_sprite("carrot_flowering", "plants_1", Rect2(48, 32, 16, 16))
	register_sprite("carrot_ripe", "plants_1", Rect2(64, 32, 16, 16))
	
	register_item("onion_seed", "plants_1", Rect2(0, 48, 16, 16))
	register_sprite("onion_sprout", "plants_1", Rect2(16, 48, 16, 16))
	register_sprite("onion_growing", "plants_1", Rect2(32, 48, 16, 16))
	register_sprite("onion_flowering", "plants_1", Rect2(48, 48, 16, 16))
	register_sprite("onion_ripe", "plants_1", Rect2(64, 48, 16, 16))
	
	register_item("lettuce_seed", "plants_1", Rect2(0, 64, 16, 16))
	register_sprite("lettuce_sprout", "plants_1", Rect2(16, 64, 16, 16))
	register_sprite("lettuce_growing", "plants_1", Rect2(32, 64, 16, 16))
	register_sprite("lettuce_flowering", "plants_1", Rect2(48, 64, 16, 16))
	register_sprite("lettuce_ripe", "plants_1", Rect2(64, 64, 16, 16))
	
	register_item("wheat_seed", "plants_1", Rect2(0, 80, 16, 16))
	register_sprite("wheat_sprout", "plants_1", Rect2(16, 80, 16, 16))
	register_sprite("wheat_growing", "plants_1", Rect2(32, 80, 16, 16))
	register_sprite("wheat_flowering", "plants_1", Rect2(48, 80, 16, 16))
	register_sprite("wheat_ripe", "plants_1", Rect2(64, 80, 16, 16))
	
	register_item("strawberry_seed", "plants_1", Rect2(0, 96, 16, 16))
	register_sprite("strawberry_sprout", "plants_1", Rect2(16, 96, 16, 16))
	register_sprite("strawberry_growing", "plants_1", Rect2(32, 96, 16, 16))
	register_sprite("strawberry_flowering", "plants_1", Rect2(48, 96, 16, 16))
	register_sprite("strawberry_ripe", "plants_1", Rect2(64, 96, 16, 16))
	
	register_item("aubergine_seed", "plants_1", Rect2(0, 112, 16, 16))
	register_sprite("aubergine_sprout", "plants_1", Rect2(16, 112, 16, 16))
	register_sprite("aubergine_growing", "plants_1", Rect2(32, 112, 16, 16))
	register_sprite("aubergine_flowering", "plants_1", Rect2(48, 112, 16, 16))
	register_sprite("aubergine_ripe", "plants_1", Rect2(64, 112, 16, 16))

# Register AtlasTexture paths
func register_atlas(id: String, path: String) -> void:
	atlases[id] = load(path)
	
# Register Items
func register_item(id: String, atlas_id: String, region: Rect2, stackable: bool = true, max_stack: int = 99, register_sprite_for_item: bool = true) -> void:
	if id.is_empty() or atlas_id.is_empty():
		push_error("Invalid item registration: Empty ID or atlas")
		return
		
	if region.size.x <= 0 or region.size.y <= 0:
		push_error("Invalid region size for item: " + id)
		return

	if items.has(id):
		push_error("Attempted to override item: " + id)
		return
	
	var item_data = ItemData.new()
	item_data.id = id
	item_data.atlas_path = atlas_id
	item_data.region = region
	item_data.stackable = stackable
	item_data.max_stack = max_stack
	items[id] = item_data
	
	if register_sprite_for_item:
		register_sprite(id, atlas_id, region)
	
func register_sprite(id: String, atlas_id, region: Rect2) -> void:
	var sprite_data = SpriteData.new()
	sprite_data.id = id
	sprite_data.atlas_path = atlas_id
	sprite_data.region = region
	if sprites.has(id):
		print("Attempted to override sprite: " + id)
	else:
		sprites[id] = sprite_data
	
func register_multi_sprite(id: String, stage: String, atlas_id: String, region: Rect2) -> void:
	var sprite_data = SpriteData.new()
	sprite_data.id = id
	sprite_data.atlas_path = atlas_id
	sprite_data.region = region
	
	if not multi_sprites.has(stage):
		multi_sprites[stage] = {}	

	if multi_sprites.has(id):
		print("Attempted to override multi sprite: " + id)
	else:
		if multi_sprites[stage].has(id):
			print("Attempted to override multi sprite stage: " + id + stage)
		else:
			multi_sprites[stage][id] = sprite_data
	
# Get Texture
func _get_atlas_texture(collection: Dictionary, id: String, stage: String = "") -> Texture2D:
	if not collection.has(id):
		return null
	var data = collection[stage][id] if stage != "" else collection[id]
	if not data or not atlases.has(data.atlas_path):
		return null

	var atlas_texture = AtlasTexture.new()
	atlas_texture.atlas = atlases[data.atlas_path]
	atlas_texture.region = data.region
	return atlas_texture

func get_item_texture(id: String) -> Texture2D:
	return _get_atlas_texture(items, id)

func get_sprite_texture(id: String) -> Texture2D:
	return _get_atlas_texture(sprites, id)

func get_multi_sprite_texture(id: String, stage: String) -> Texture2D:
	return _get_atlas_texture(multi_sprites, id, stage)
