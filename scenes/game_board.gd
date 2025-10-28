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

var gameplay_viewport: Dictionary # Game Variables
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
	
	var newBasket = baskScene.instantiate() # Set up initial Basket
	basketArr.append(newBasket)
	newBasket.label = "Gain $10"
	newBasket.function = Callable(newBasket, "add_money")
	newBasket.params = {"gameBoard": self, "value": 10}
	add_child(newBasket)
	newBasket.position = Vector2(gameplay_viewport.left,1080)

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
		Levels.level_handler(self, "during_drop")
	else: # Handle ball during drop input sequence
		var ball_posx = get_global_mouse_position().x
		if get_global_mouse_position().x + ball.get_radius() < gameplay_viewport.left:
			ball_posx = gameplay_viewport.left + ball.get_radius()
		elif get_global_mouse_position().x > gameplay_viewport.left + gameplay_viewport.x - ball.get_radius():
			ball_posx = gameplay_viewport.left + gameplay_viewport.x - ball.get_radius()
		ball.position = Vector2(ball_posx, 100)

func _on_resetter_body_entered(body):
	if body.is_in_group("ball"): # Ensure a ball has entered basket
		for basket in basketArr: # Handle Basket functions
			if basket.entered:
				basket.function.call()
				basket.entered = false
		Levels.level_handler(self, "after_landing")
		stage.stageEnd = true
		body.free() # Free ball

func add_ball():
	ball = ballScene.instantiate()
	add_child(ball)

func add_coll_object(objPosition, scene, shape, function: Dictionary = {}):
	var newObj = scene.instantiate()
	objArr.append(newObj)
	add_child(newObj)
	newObj.global_position = objPosition
	newObj.set_object(shape)
	newObj.mainScene = self
	if function != {}:
		var callableFunc = Callable(newObj, function["func"])
		function.func = callableFunc
		if function.has("trigger"):
			newObj.triggeredFunctions.append(function)
		else:
			newObj.functions.append(function)
	return newObj

func handle_selecting() -> bool:
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
