extends Node
class_name LevelHelper

static func level_handler(gameBoard: GameBoard, handleType: String):
	for character in gameBoard.stage.levelCharacters:
		if character.has(handleType):
			var newFunction = Callable(LevelHelper,character[handleType])
			newFunction.call(gameBoard)

static func dracula(gameBoard: GameBoard):
	var objsHit = gameBoard.ball.all_touched
	for obj in objsHit:
		obj.functions = []
		obj.set_color(Color.RED)
		obj.sound = obj.get_node("boingSound")

static func frankenstein(gameBoard: GameBoard):
	var ticks = Time.get_ticks_msec()
	if ticks % 3000 == 0:
		gameBoard.money -= 5

static func place_silver_bullet(gameBoard: GameBoard):
	var allObjs = gameBoard.objArr
	var selection = allObjs[randi() % allObjs.size()]
	var new_function = {
		"func": Callable(selection,"silver_bullet"),
		"text": "Receive Silver Bullet",
		"params": {}
	}
	selection.functions.append(new_function)
	selection.set_color(Color.SILVER)

static func werewolf(gameBoard):
	if "Silver Bullet" not in gameBoard.inventory:
		gameBoard.gameOver = true
	else:
		gameBoard.inventory.erase("Silver Bullet")

static func ghost(gameBoard: GameBoard):
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
	gameBoard.add_child(color_rect)

static func ghost_light(gameBoard: GameBoard):
	var overlay = gameBoard.get_node("DarknessOverlay")
	if overlay:
		var shader_material = overlay.material as ShaderMaterial
		var screen_pos = gameBoard.ball.global_position
		shader_material.set_shader_parameter("light_center", screen_pos)

static func reset_ghost(gameBoard: GameBoard):
	var overlay = gameBoard.get_node("DarknessOverlay")
	overlay.free()

static func giraffe(gameBoard: GameBoard):
	var pegs = gameBoard.get("objArr")
	for peg in pegs:
		if randi() % 10 == 0:
			var new_function = {
				"func": Callable(peg, "giraffe"),
				"text": "Giraffe Effect",
				"params": {}
			}
			peg.get("functions").append(new_function)
			peg.set_color(Color.MEDIUM_PURPLE)

static func elephant(gameBoard: GameBoard):
	var pegs = gameBoard.get("objArr")
	for peg in pegs:
		if randi() % 10 == 0:
			var new_function = {
				"func": Callable(peg, "elephant"),
				"text": "Elephant Effect",
				"params": {}
			}
			peg.get("functions").append(new_function)
			peg.set_color(Color.MEDIUM_PURPLE)

static func monkey1(gameBoard: GameBoard):
	gameBoard.state = {"monkey_combo_active": false, "monkey_combo_count": 0, "monkey_last_hit": Time.get_ticks_msec()}
	var pegs = gameBoard.get("objArr")
	for peg in pegs:
		if randi() % 5 == 0:
			var new_function = {
				"func": Callable(peg, "monkey1"),
				"text": "Melody Monkey Effect",
				"params": {}
			}
			peg.get("functions").append(new_function)
			peg.set_color(Color.MEDIUM_PURPLE)

static func reset_monkey1(gameBoard: GameBoard):
	gameBoard.state.erase("monkey_combo_count")
	gameBoard.state.erase("monkey_last_hit")
	for peg in gameBoard.objArr:
		for function in peg.functions:
			if function.func == Callable(peg, "monkey1"):
				peg.functions.erase(function) 
				peg.set_color(Color.RED)
