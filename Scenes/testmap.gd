extends Node2D

var resource_placeholders = []
var test_coords = [[44.08328, -123.11245], [44.08338, -123.11370], [44.08117, -123.11280]]

func _ready() -> void:
	#$ScrollingCenteredMap2.SetLoadableSource(MakeAreaNode)
	$ScrollingCenteredMap2.SetLoadableSource(test_gen_dots)
	#splats.append(preload("res://Scenes/SplatScene/splat35.png"))
	#for i in range(5):
		#var preload_path = 'res://Scenes/testmap/splat0' 
		#preload_path += i 
		#preload_path += '.png'
		#
		#resource_placeholders.append(preload(preload_path))
	OS.request_permission('android.permission.ACCESS_FINE_LOCATION')
	#OS.request_permission('android.permission.ACCESS_BACKGROasdfsdfUND_LOCATION')


func get_pluscode_from_coords(lat, lon):
	var plusCode = PlusCodes.EncodeLatLonSize(lat, lon, 11)
	return plusCode

func test_gen_dots(cell8 = null, gridSize = null):
	var pluscodes_to_display = []
	for point in test_coords:
		var new_pluscode = get_pluscode_from_coords(point[0], point[1])
		#pluscodes_to_display.append(new_pluscode)
		var spritePoint = Sprite2D.new()
		var spritePointTexture = load("res://Scenes/testmap/splats/splat00.png")
		spritePoint.texture = spritePointTexture
		spritePoint.scale = Vector2(.5,.5)
		spritePoint.set_meta('location', new_pluscode)
		var data_test = point[0]
		
		var spritePointBtn = Button.new()
		var scaled_size = spritePoint.texture.get_size() * spritePoint.scale
		spritePointBtn.size = scaled_size	
		spritePointBtn.position = -scaled_size / 2.0
		spritePointBtn.pressed.connect(test_resource_click.bind(data_test))
		spritePoint.add_child(spritePointBtn)
		pluscodes_to_display.append(spritePoint)
		
	print('test dots were: ', pluscodes_to_display)
	return pluscodes_to_display
	

func test_resource_click(test_data):
	print('test data was: ', test_data)
	
	
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
