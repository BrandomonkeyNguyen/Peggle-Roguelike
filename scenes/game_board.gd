extends Node2D
class_name GameBoard

const ballScene = preload("res://scenes/objects/fallingBall.tscn")
const baskScene = preload("res://scenes/objects/basket.tscn")

var ball: RigidBody2D # Objects on board
var objArr: Array
var leftButtonTriggers: Array
var rightButtonTriggers: Array
var basketArr: Array
var inventory: Array
var selector: Area2D

# Game Variables
var gameplay_viewport: Dictionary
var stage: Stage
var state: Dictionary

var gameOver: bool

func init_board(init_stage: Stage) -> void:
	stage = init_stage
	gameplay_viewport = { # Set gameplay viewport variable
		"top": $BoardArea/Shape.shape.size.y / 8,
		"left": $BoardArea/Shape.position.x - ($BoardArea/Shape.shape.size.x / 2),
		"x": $BoardArea/Shape.shape.size.x,
		"y": $BoardArea/Shape.shape.size.y * 3 / 4
	}

func handle_gameplay():
	if ball.is_dropped: # Handle ball after it is dropped
		if ball.time_dropped != null: # Do something when ball is initially dropped
			ball.time_dropped = null
			stage.ballDropped = true
		if ball.impulse_factor > 5:
			objArr.erase(ball.last_touched)
			ball.last_touched.free()
			ball.impulse_factor = 1
		stage.moneyEarned = ball.money_gathered
		
	else: # Handle ball during drop input sequence
		var ball_posx = get_global_mouse_position().x
		if get_global_mouse_position().x + ball.get_radius() < gameplay_viewport.left:
			ball_posx = gameplay_viewport.left + ball.get_radius()
		elif get_global_mouse_position().x > gameplay_viewport.left + gameplay_viewport.x - ball.get_radius():
			ball_posx = gameplay_viewport.left + gameplay_viewport.x - ball.get_radius()
		ball.position = Vector2(ball_posx, 100)

func add_ball():
	ball = ballScene.instantiate()
	add_child(ball)

func add_basket(label, function, params):
	var newBasket = baskScene.instantiate() # Set up initial Basket
	basketArr.append(newBasket)
	newBasket.gameBoard = self
	newBasket.label = label
	newBasket.function = Callable(newBasket, function)
	newBasket.params = params
	add_child(newBasket)
	newBasket.position = Vector2(gameplay_viewport.left,1080)

func add_coll_object(objPosition, scene, shape, newFunctions: Array = [], color: Color = Color.RED, sound: String = "boingSound"):
	var newObj = scene.instantiate()
	objArr.append(newObj)
	call_deferred("add_child", newObj)
	newObj.global_position = objPosition
	newObj.set_object(shape)
	newObj.set_color(color)
	newObj.sound = newObj.get_node(sound)
	newObj.mainScene = self
	if newFunctions != []:
		for function in newFunctions:
			var callableFunc = Callable(newObj, function["func"])
			function.func = callableFunc
			if function.has("trigger"):
				newObj.triggeredFunctions.append(function)
			else:
				newObj.functions.append(function)
	return newObj

func handle_selecting() -> bool:
	if selector == null:
		add_ball()
		return false
	if selector.area_selected:
		if selector.pegs_to_remove != null:
			for peg in selector.pegs_to_remove:
				objArr.erase(peg)
				peg.free()
		selector.free()
		add_ball()
		return false
	else: return true

func trigger_left_button() -> void:
	for obj in leftButtonTriggers:
		for function in obj.triggeredFunctions:
			if function.trigger == "left_button":
				function.func.call(function.params)

func trigger_right_button() -> void:
	for obj in rightButtonTriggers:
		for function in obj.triggeredFunctions:
			if function.trigger == "right_button":
				function.func.call(function.params)
