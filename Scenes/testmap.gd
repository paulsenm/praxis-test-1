extends Node2D

var resource_placeholders = []
const test_coords = [[44.08328, -123.11245], [44.08338, -123.11370], [44.08117, -123.11280]]
const test_resource_names = ['Nails', 'Boards', 'Logs', 'Wire']
const resource_max_distance = 100
const shop_max_distance = 500
const scale_for_32x_markers = 2
const scale_for_32x_card = 20
const inventory_display_width = 3
var inventory_dict = {
	'Nails':0,
	'Boards':0,
	'Logs':0,
	'Wire':0
	}


@onready var map = $ScrollingCenteredMap2
@onready var player = $ScrollingCenteredMap2/playerIndicator
@onready var ui = $CanvasLayer/Control
@onready var bottom_menu = $CanvasLayer/Control/BottomMenu
#@onready var scroll_container = $ScrollContainer
@onready var inventory_root = $inventory_root
@onready var inventory_vbox = $inventory_root/Control/ScrollContainer/VBoxContainer

func _ready() -> void:
	#$ScrollingCenteredMap2.SetLoadableSource(MakeAreaNode)
	$ScrollingCenteredMap2.SetLoadableSource(test_gen_dots)
	OS.request_permission('android.permission.ACCESS_FINE_LOCATION')
	#OS.request_permission('android.permission.ACCESS_BACKGROasdfsdfUND_LOCATION')
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_menu.mouse_filter = Control.MOUSE_FILTER_PASS
	


func get_pluscode_from_coords(lat, lon):
	var plusCode = PlusCodes.EncodeLatLonSize(lat, lon, 11)
	return plusCode

func test_gen_dots(cell8 = null, gridSize = null):
	var pluscodes_to_display = []
	for point in test_coords:
		var new_pluscode = get_pluscode_from_coords(point[0], point[1])
		#pluscodes_to_display.append(new_pluscode)
		var spritePoint = Sprite2D.new()
		var random_resource = test_resource_names.pick_random()
		var resource_image_path = "res://Scenes/testmap/mini-arts/" + random_resource + ".png" 
		var spritePointTexture = load(resource_image_path)
		spritePoint.texture = spritePointTexture
		spritePoint.scale = Vector2(scale_for_32x_markers, scale_for_32x_markers)
		spritePoint.set_meta('location', new_pluscode)
		var data_test = point[0]
		
		var spritePointBtn = Button.new()
		var scaled_size = spritePoint.texture.get_size() * spritePoint.scale / 3
		spritePointBtn.size = scaled_size
		spritePointBtn.position = -scaled_size / 2.0
		spritePointBtn.modulate.a = 0.3
		#spritePointBtn.pressed.connect(test_resource_click.bind(data_test, spritePointBtn, random_resource))
				
		var spritePointCol = CollisionShape2D.new()
		var spritePointColShape = RectangleShape2D.new()
		spritePointColShape.size = scaled_size
		spritePointCol.shape = spritePointColShape
				
		spritePoint.add_child(spritePointCol)
		spritePoint.add_child(spritePointBtn)
		spritePointBtn.pressed.connect(make_resource_popup.bind(spritePoint, random_resource))
		pluscodes_to_display.append(spritePoint)
				
	#print('test dots were: ', pluscodes_to_display)
	return pluscodes_to_display
	

	
func test_resource_click(test_data, resourceBtn, attached_resource):
	#var player = $playerIndicator
	var player_position = player.global_position
	var resource_center = resourceBtn.global_position + (resourceBtn.size / 2.0)
	var x_dist = abs(player_position.x - resource_center.x)
	var y_dist = abs(player_position.y - resource_center.y)
	var dist = sqrt((x_dist * x_dist) + (y_dist * y_dist))
	print('test data was: ', test_data)
	print('resource was: ', attached_resource)
	
	
	print('distance from player was: ', dist)
	if dist < resource_max_distance:
		print('you can gather this resource')
		
	if dist < shop_max_distance: 
		print('you can visit this shop')
	
func make_resource_popup(resource_node, resource_name):
	var canvas_node = CanvasLayer.new()
	var control_node = Control.new()
	
	var resource_sprite = Sprite2D.new()
	var resource_image_path = "res://Scenes/testmap/mini-arts/" + resource_name + ".png" 
	var resource_sprite_texture = load(resource_image_path)
	resource_sprite.texture = resource_sprite_texture
	resource_sprite.z_index = 3
	resource_sprite.scale = Vector2(scale_for_32x_card, scale_for_32x_card)
	resource_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	resource_sprite.position = Vector2(400, 350)
	
	var color_block = ColorRect.new()
	color_block.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_block.size = Vector2(800, 1200)
	color_block.z_index = 1
	
	var add_to_inventory_btn = Button.new()
	add_to_inventory_btn.pressed.connect(add_item_to_inventory.bind(resource_node, resource_name, canvas_node))
	add_to_inventory_btn.text = "Add to inventory"
	add_to_inventory_btn.icon = MeshTexture
	add_to_inventory_btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	add_to_inventory_btn.z_index = 23
	#add_to_inventory_btn.size = Vector2(140, 30)
	add_to_inventory_btn.position = Vector2(230, 1031)
	add_to_inventory_btn.scale = Vector2(2.5, 3)
	
	canvas_node.add_child(control_node)
	control_node.add_child(resource_sprite)
	control_node.add_child(color_block)
	control_node.add_child(add_to_inventory_btn)
	$".".add_child(canvas_node)

func make_inventory_item_display(item_name):
	print('item name: ', item_name)
	var item_qty = inventory_dict[item_name]
	
	var texture_rect = TextureRect.new()			
	var texture_path = "res://Scenes/testmap/mini-arts/" + item_name + ".png" 
	var texture = load(texture_path)
	texture_rect.texture = texture
	texture_rect.custom_minimum_size = Vector2(64, 64)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	var inventory_quantity_label = Label.new()
	inventory_quantity_label.text = str(item_qty)
	inventory_quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	inventory_quantity_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	texture_rect.add_child(inventory_quantity_label)
	
	return texture_rect


func chunk_inv_array(inventory_array, chunk_size):
	var chunked_array = []
	for i in range(0, len(inventory_array), chunk_size):
		var chunk = inventory_array.slice(i, i + chunk_size)
		chunked_array.append(chunk)
	return chunked_array

func make_inventory_hbox(item_array):
	var actual_hbox = HBoxContainer.new()
	print('make one hbox with up to 3 inventory items')
	for item_name in item_array:
		var full_item = make_inventory_item_display(item_name)
		actual_hbox.add_child(full_item)
	
	return actual_hbox
		

func populate_inventory_popup():
	var inventory_array_to_show = []
	var hbox_array = []
	for item_name in test_resource_names:
		if inventory_dict[item_name] > 0:
			print(item_name, ' had qty of: ', inventory_dict[item_name])
			inventory_array_to_show.append(item_name)
	var chunked_item_name_array = chunk_inv_array(inventory_array_to_show, inventory_display_width)
	for chunk in chunked_item_name_array:
		var new_inv_h_box = make_inventory_hbox(chunk)
		hbox_array.append(new_inv_h_box)
	
	
	
	print('populate inventory popup')
	
	
func add_item_to_inventory(resource_node, resource_name, resource_card):
	inventory_dict[resource_name] += 1
	print('added ', resource_name, ' to inventory. Current inv: ', inventory_dict)
	resource_node.queue_free()
	resource_card.queue_free()
	
func display_inventory():
	inventory_root.show()
	populate_inventory_popup()
	var inventory_items_with_sprites = []
	var hbox_container_array = []
	var current_hbox_container = HBoxContainer.new()
	var current_hbox_array_index = 0
	for inventory_item in inventory_dict:
		if inventory_dict[inventory_item] > 0:
			var item_with_sprite = Panel.new()
			
			var item_sprite = Sprite2D.new()			
			var item_sprite_path = "res://Scenes/testmap/mini-arts/" + inventory_item + ".png" 
			var item_sprite_texture = load(item_sprite_path)
			item_sprite.texture = item_sprite_texture
			
			var item_amount_display = Label.new()
			item_amount_display.text = str(inventory_dict[inventory_item])
			item_amount_display.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
			
			item_with_sprite.add_child(item_sprite)
			item_with_sprite.add_child(item_amount_display)
			#if current_hbox_container.get_child_count() >= 3:
				#print('making new hbox container row')
				#hbox_container_array.append(current_hbox_container)
				#var new_hbox_container = HBoxContainer.new()
				#current_hbox_container = new_hbox_container
				#current_hbox_array_index += 1
			#if current_hbox_container.get_child_count() <= 0:
				#var newHb
				
			current_hbox_container.add_child(item_with_sprite)
			
			
	
	#for row in hbox_container_array:
		#scroll_container.add_child(row)
	#print('scroll container: ', scroll_container)
	print('display inv')


func MakeAreaNode(cell8, gridSize):
	print('cell 8 was: ', cell8)
	test_gen_dots()
	var results = []
	for x in gridSize:
		for y in gridSize:
			var thisCell8 = PlusCodes.ShiftCode(cell8, x, -y)
			#Make an RNG that always gives the same values for the same inputs.
			var rng = PraxisCore.GetFixedRNGForPluscode(thisCell8)
			#Pick a Cell10 inside this Cell8
			var yCoord = PlusCodes.CODE_ALPHABET_[rng.randi_range(0,19)]
			var xCoord = PlusCodes.CODE_ALPHABET_[rng.randi_range(0,19)]
			var full_pluscode_coord = thisCell8 + yCoord + xCoord
			#Make a random colored square for that point.
			var color = Color.from_hsv(rng.randf(),rng.randf(),rng.randf())
			var colorRect = ColorRect.new()
			colorRect.size = Vector2(80,80)
			colorRect.color = color
			colorRect.set_meta("location", full_pluscode_coord)
			print('meta was set to: ', full_pluscode_coord)
			results.append(colorRect)
	return results
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
