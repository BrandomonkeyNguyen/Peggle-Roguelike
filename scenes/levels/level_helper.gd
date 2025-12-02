extends Node
class_name LevelHelper

# Level Multipurpose Functions
static func clear_game_board(mainNode: Main):
	mainNode.gameBoard.free()
	mainNode.add_game_board(mainNode.stage)

static func reset_game_board(mainNode: Main):
	clear_game_board(mainNode)
	mainNode.load_game(true)

# Level Specific Functions
static func dracula(mainNode: Main):
	var gameBoard = mainNode.gameBoard
	var objsHit = gameBoard.ball.all_touched
	for obj in objsHit:
		obj.functions = []
		obj.set_color(Color.RED)
		obj.sound = obj.get_node("boingSound")

static func frankenstein_lab(mainNode: Main):
	# Setting up game board
	clear_game_board(mainNode)
	var gameBoard = mainNode.gameBoard
	var viewport = mainNode.gameBoard.gameplay_viewport
	var collScene = mainNode.collScene

	var center_x = viewport.x / 2 + viewport.left
	var start_y = viewport.top + viewport.y
	var row_height = viewport.y / 15
	for i in range(1, 15):
		var row_width = viewport.x
		var left = center_x - (row_width / 2)
		for j in range(1, i + 1):
			var x = left + (row_width / (i + 1)) * j
			var y = start_y - row_height * i
			gameBoard.add_coll_object(Vector2(x, y), collScene, "Circle Peg")
	
	for item in [{"side":"left","offset":-1},{"side":"right","offset":1}]:
		var functions = [{
			"func": "flip",
			"text": "Flip Ball",
			"trigger": item["side"] + "_button",
			"params": {"direction": item["side"]}
		}]
		var flipper = gameBoard.add_coll_object(Vector2(center_x + (item["offset"] * viewport.x / 5), start_y), collScene, "Flipper", functions)
		flipper.scale = Vector2(item["offset"],1)
		if item["side"] == "left":
			gameBoard.leftButtonTriggers.append(flipper)
		elif item["side"] == "right":
			gameBoard.rightButtonTriggers.append(flipper)
	
	# Pick random frankenstein position
	var rng = RandomNumberGenerator.new()
	rng.randomize() # Optional: Seeds the generator with a time-dependent value.
	var random_float = rng.randf_range(viewport.left,viewport.left+viewport.x)
	var arrowScene = load("res://scenes/levels/arrow_symbol.tscn")
	var dropPoint = arrowScene.instantiate()
	mainNode.add_child(dropPoint)
	dropPoint.color = Color.GREEN
	dropPoint.position = Vector2(random_float, 100)
	
	mainNode.levelState = {"dropPoint": dropPoint, "dropX": random_float}

static func drop_frankenstein(mainNode: Main):
	var gameBoard = mainNode.gameBoard
	var levelState = mainNode.levelState
	
	# Create and drop frankenstein
	var ballScene = load("res://scenes/objects/fallingBall.tscn")
	var frankenstein_ball = ballScene.instantiate()
	
	levelState.dropPoint.free()
	frankenstein_ball.position = Vector2(levelState.dropX, 140)
	frankenstein_ball.modulate(Color.GREEN)
	gameBoard.add_child(frankenstein_ball)
	mainNode.levelState = {"frankenstein": frankenstein_ball, "dropTime": Time.get_ticks_msec(), "caught": false}

static func frankenstein(mainNode: Main):
	var levelState = mainNode.levelState
	if "frankenstein" in levelState: 
		var ball = mainNode.gameBoard.ball
		if Time.get_ticks_msec() < levelState.dropTime + 1000:
			ball.position.y = 100
			ball.linear_velocity = Vector2(0,0)
		if not levelState["caught"]:
			if not is_instance_valid(levelState["frankenstein"]):
				mainNode.do_game_over()
			elif levelState["frankenstein"] in ball.unknown_touches:
				levelState["caught"] = true
				levelState["frankenstein"].free()

static func frankenstein_escape(mainNode: Main):
	if mainNode.levelState["caught"]:
		mainNode.levelState = {}
		reset_game_board(mainNode)
	else:
		mainNode.do_game_over()

static func place_silver_bullet(mainNode: Main):
	var allObjs = mainNode.gameBoard.objArr
	var selection = allObjs[randi() % allObjs.size()]
	var new_function = {
		"func": Callable(selection,"silver_bullet"),
		"text": "Receive Silver Bullet",
		"params": {}
	}
	selection.functions.append(new_function)
	selection.set_color(Color.SILVER)

static func werewolf(mainNode: Main):
	var gameBoard = mainNode.gameBoard
	if "Silver Bullet" not in gameBoard.inventory:
		gameBoard.gameOver = true
	else:
		gameBoard.inventory.erase("Silver Bullet")

static func ghost(mainNode: Main):
	var color_rect := ColorRect.new()
	color_rect.color = Color.BLACK
	color_rect.name = "DarknessOverlay"
	color_rect.size = Vector2(1080, 1080)
	color_rect.position = Vector2(420, 0)
	color_rect.z_index = 100
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Create the shader
	var shader := Shader.new()
	shader.code = """
		shader_type canvas_item;
		uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
		uniform vec2 light_center;
		uniform float radius = 100.0;
		uniform float softness = 100.0;
		void fragment() {
			vec2 screen_pos = SCREEN_UV * vec2(textureSize(SCREEN_TEXTURE, 0));
			float dist = distance(screen_pos, light_center);
			float alpha = smoothstep(radius, radius + softness, dist);
			COLOR = vec4(0.0, 0.0, 0.0, alpha);
		}
	"""

	# Assign the shader to a material and set on the ColorRect
	var shader_material := ShaderMaterial.new()
	shader_material.shader = shader
	color_rect.material = shader_material
	mainNode.gameBoard.add_child(color_rect)

static func ghost_light(mainNode: Main):
	var gameBoard = mainNode.gameBoard
	var overlay = gameBoard.get_node("DarknessOverlay")
	if overlay:
		var shader_material = overlay.material as ShaderMaterial
		var screen_pos = gameBoard.ball.global_position
		shader_material.set_shader_parameter("light_center", screen_pos)

static func reset_ghost(mainNode: Main):
	var overlay = mainNode.gameBoard.get_node("DarknessOverlay")
	overlay.free()

static func giraffe(mainNode: Main):
	var pegs = mainNode.gameBoard.get("objArr")
	for peg in pegs:
		if randi() % 10 == 0:
			var new_function = {
				"func": Callable(peg, "giraffe"),
				"text": "Giraffe Effect",
				"params": {}
			}
			peg.get("functions").append(new_function)
			peg.set_color(Color.MEDIUM_PURPLE)

static func elephant(mainNode: Main):
	var pegs = mainNode.gameBoard.get("objArr")
	for peg in pegs:
		if randi() % 10 == 0:
			var new_function = {
				"func": Callable(peg, "elephant"),
				"text": "Elephant Effect",
				"params": {}
			}
			peg.get("functions").append(new_function)
			peg.set_color(Color.MEDIUM_PURPLE)

static func monkey1(mainNode: Main):
	mainNode.levelState = {"monkey_combo_active": false, "monkey_combo_count": 0, "monkey_last_hit": Time.get_ticks_msec()}
	var pegs = mainNode.gameBoard.get("objArr")
	for peg in pegs:
		if randi() % 5 == 0:
			var new_function = {
				"func": Callable(peg, "monkey1"),
				"text": "Melody Monkey Effect",
				"params": {}
			}
			peg.get("functions").append(new_function)
			peg.set_color(Color.MEDIUM_PURPLE)

static func reset_monkey1(mainNode: Main):
	for peg in mainNode.gameBoard.objArr:
		for function in peg.functions:
			if function.func == Callable(peg, "monkey1"):
				peg.functions.erase(function) 
				peg.set_color(Color.RED)
