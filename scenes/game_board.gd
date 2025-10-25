extends Node2D
class_name GameBoard

const ballScene = preload("res://scenes/objects/fallingBall.tscn")
const baskScene = preload("res://scenes/objects/basket.tscn")

var main: Main

var menu: Node2D
var menuOpen = true
var selector: Area2D
var selecting = false

var ball: RigidBody2D
var objArr: Array
var leftButtonTriggers: Array
var rightButtonTriggers: Array
var basketArr: Array
var music: AudioStreamPlayer
var state: Dictionary

func init_board(mainNode: Main) -> void:
	main = mainNode
	var newBasket = baskScene.instantiate()
	basketArr.append(newBasket)
	newBasket.label = "Gain $10"
	newBasket.function = Callable(newBasket, "add_money")
	newBasket.params = {"ogNode": main, "value": 10}
	add_child(newBasket)
	newBasket.position = Vector2(main.gameplay_viewport.left,1080)

func _on_resetter_body_entered(body):
	if body.is_in_group("ball"):
		for basket in basketArr:
			if basket.entered:
				basket.function.call()
				basket.entered = false
		main.next_level()
		body.free()

func handle_gameplay() -> Dictionary:
	var return_data = {"just_dropped": false, "is_dropped": false}
	if ball.is_dropped:
		if ball.time_dropped != null: # Do something when ball is dropped
			ball.time_dropped = null
			return_data["just_dropped"] = true
		if ball.impulse_factor > 5:
			objArr.erase(ball.last_touched)
			ball.last_touched.free()
			ball.impulse_factor = 1
		return_data["is_dropped"] = true
		return_data["money_gathered"] = ball.money_gathered
		pass
	else:
		var ball_posx = get_global_mouse_position().x
		if get_global_mouse_position().x + ball.get_radius() < main.gameplay_viewport.left:
			ball_posx = main.gameplay_viewport.left + ball.get_radius()
		elif get_global_mouse_position().x > main.gameplay_viewport.left + main.gameplay_viewport.x - ball.get_radius():
			ball_posx = main.gameplay_viewport.left + main.gameplay_viewport.x - ball.get_radius()
		ball.position = Vector2(ball_posx, 100)
	return return_data

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
