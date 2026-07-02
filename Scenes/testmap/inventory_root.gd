extends Node
const inventory_display_width = 3
var inventory_dict = {
	'Nails':0,
	'Boards':0,
	'Logs':0,
	'Wire':0
	}
const test_resource_names = ['Nails', 'Boards', 'Logs', 'Wire']

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory_show_button.pressed.connect(display_inventory)
	inventory_hide_button.pressed.connect(hide_inventory)
	inventory_hide_button_x.pressed.connect(hide_inventory)


@onready var inventory_root = $"."
@onready var inventory_vbox = $Control/ScrollContainer/VBoxContainer
@onready var inventory_show_button = $"../CanvasLayer/Control/BottomMenu/InventoryButton"

@onready var inventory_hide_button = $"../CanvasLayer/Control/BottomMenu/InventoryButtonHide"
@onready var inventory_hide_button_x = $Button

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
	for hbox in hbox_array:
		inventory_vbox.add_child(hbox)
	
	
	print('populate inventory popup')
	

func add_item_to_inventory(resource_node, resource_name, resource_card):
	inventory_dict[resource_name] += 1
	print('added ', resource_name, ' to inventory. Current inv: ', inventory_dict)
	resource_node.queue_free()
	resource_card.queue_free()
	
func display_inventory():
	inventory_root.show()
	inventory_hide_button.show()
	populate_inventory_popup()
	var current_hbox_container = HBoxContainer.new()
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
				
			current_hbox_container.add_child(item_with_sprite)
	print('display inv')

func hide_inventory():
	inventory_root.hide()
	inventory_hide_button.hide()
	for child in inventory_vbox.get_children():
		child.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
