extends Node2D
#testing push from tablet
var resource_placeholders = []
const test_coords = [[44.08328, -123.11245], [44.08338, -123.11370], [44.08117, -123.11280]]
const test_nodes_coords = [[44.08193,-123.1130902],[44.0819524,-123.1127246],[44.0817925,-123.1127239],[44.0818266,-123.1128404],[44.0818162,-123.1130446],[44.0817967,-123.1130426],[44.0819085,-123.1128166],[44.0818602,-123.1127966],[44.0818885,-123.1126645],[44.0819368,-123.1126845],[44.081967,-123.1126657],[44.0819577,-123.1126933],[44.0819443,-123.1128576],[44.0819031,-123.1130831],[44.081853,-123.1130804],[44.0818586,-123.1128779],[44.0819087,-123.1128806],[44.0820186,-123.1132066],[44.0821332,-123.1130889],[44.0820036,-123.1130681],[44.0820136,-123.1129463],[44.0820326,-123.1129494],[44.0820379,-123.1128849],[44.0820198,-123.112882],[44.0820293,-123.1127678],[44.0820146,-123.1131929],[44.0820991,-123.1127253],[44.0819748,-123.1126511]]
const test_resource_names = ['Nails', 'Boards', 'Logs', 'Wire']
const resource_max_distance = 100
const shop_max_distance = 500
const scale_for_32x_markers = 2
const scale_for_32x_card = 20
#const inventory_display_width = 3
const local_poi_host_base_url = 'http://127.0.0.1:5000/api/loc'
const url_code_for_plus_symbol = '%2b'



@onready var map = $ScrollingCenteredMap2
@onready var player = $ScrollingCenteredMap2/playerIndicator
@onready var ui = $CanvasLayer/Control
@onready var bottom_menu = $CanvasLayer/Control/BottomMenu
@onready var inventory_root = $inventory_root
@onready var http_request_node = $HTTPRequest
@onready var poi_coords := []
@onready var old_pluscode = PraxisCore.currentPlusCode

func _ready() -> void:
	#$ScrollingCenteredMap2.SetLoadableSource(MakeAreaNode)
	$ScrollingCenteredMap2.SetLoadableSource(test_gen_dots)
	OS.request_permission('android.permission.ACCESS_FINE_LOCATION')
	#OS.request_permission('android.permission.ACCESS_BACKGROasdfsdfUND_LOCATION')
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_menu.mouse_filter = Control.MOUSE_FILTER_PASS
	ping_once()
	


func get_pluscode_from_coords(lat, lon):
	var plusCode = PlusCodes.EncodeLatLonSize(lat, lon, 11)
	return plusCode

#http://127.0.0.1:5000/api/
func gps_from_pluscode(pluscode):
	const api_base_url_local = 'http://127.0.0.1:5000/api/pc'
	var trimmed_pluscode_space = pluscode.replace(" ", "")
	var trimmed_pluscode_plus = trimmed_pluscode_space.replace("+", "")
	var url_pluscode = trimmed_pluscode_plus.insert(8, url_code_for_plus_symbol)
	var query_parameter = '?pc='+url_pluscode
	var full_url_local = api_base_url_local + query_parameter
	print('full pluscode request url: ', full_url_local)
	http_request_node.request(full_url_local)
	var response = await http_request_node.request_completed
	var coords =  response[3].get_string_from_utf8()
	print('response: ', coords)
	return JSON.parse_string(coords)
	
func ping_once():
	poi_coords = await get_poi_from_api()
	print("poi_coords: ", poi_coords)
	#var gps_test_coords = await gps_from_pluscode('84PR3VJP%2bJM')

	$ScrollingCenteredMap2.RefreshTiles(PraxisCore.currentPlusCode)

#http://127.0.0.1:5000/api/loc?lat=44.08195&lon=-123.11291
func get_poi_from_api(lat=44.08195, lon=-123.11291):
	const api_base_url_local = "http://127.0.0.1:5000/api/loc"
	var query_parameters = "?lat=" + str(lat) + "&lon=" + str(lon)
	var full_req_url = api_base_url_local + query_parameters
	print('full req url was: ', full_req_url)
	#var http_request_poi = HTTPRequest.new()
	http_request_node.request(full_req_url)
	var response = await http_request_node.request_completed
	print('response was: ', response)
	var body = response[3]
	var body_string = body.get_string_from_utf8()
	
	return JSON.parse_string(body_string)

func get_more_pois(previous_pc, current_pc):
	#if player moves more than 500m from last loaded pc, load new resources
	print('previous plus code: ', previous_pc, ", current plus code: ", current_pc)

func test_gen_dots(cell8 = null, gridSize = null):
	print('poi coords were: ', poi_coords)
	var pluscodes_to_display = []
	#for point in test_coords:
	for point in poi_coords:
		print('getting point for: ', str(point))
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
	color_block.size = Vector2(800,1200)
	#color_block.set_deferred('size', Vector2(800, 1200))
	color_block.z_index = 1
	
	var add_to_inventory_btn = Button.new()
	add_to_inventory_btn.pressed.connect(inventory_root.add_item_to_inventory.bind(resource_node, resource_name, canvas_node))
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

#Very rough est - will be different near equator or poles
func get_gps_dist(first_coords, second_coords):
	print('first coord: ', str(first_coords))
	var lat_dist = abs(first_coords[0] - second_coords[0])
	var lon_dist = abs(first_coords[1] - second_coords[1])
	#var lat_dist = abs(first_coords['lat'] - second_coords['lon'])
	#var lon_dist = abs(first_coords['lat'] - second_coords['lon'])
	var total_dist_dec = sqrt(lat_dist * lat_dist + lon_dist * lon_dist)
	var total_dist_meters = total_dist_dec * 90000
	return total_dist_meters

func get_new_stuff():
	print('get new stuff')
	var current_pc = PraxisCore.currentPlusCode
	print('current pc: ', current_pc)
	var old_gps_coords = await gps_from_pluscode(old_pluscode)
	print('old gps: ', str(old_gps_coords))
	var current_gps_coords = await gps_from_pluscode(current_pc)
	var distance = get_gps_dist(old_gps_coords, current_gps_coords)
	print('distance: ', str(distance))
	

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


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print('body string: ', body.get_string_from_utf8()) # Replace with function body.
	var coords_array = body.get_string_from_utf8()
	return
