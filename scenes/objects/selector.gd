extends Area2D
class_name Selector

const collScene = preload("res://scenes/objects/collisionObjects/collision_object.tscn")
@onready var shape = $Shape.shape
const normal_scale = 64

var gameBoard: GameBoard
var function: Callable
var params: Dictionary
var value: int
var area_selected = false
var pegs_to_remove = null

func _ready():
	pass

func _process(_delta):
	global_position = get_global_mouse_position()

func _draw():
	if shape is CircleShape2D:
		var radius := (shape as CircleShape2D).radius
		draw_circle(Vector2(0,0), radius, Color(Color.YELLOW,0.5))
	elif shape is RectangleShape2D:
		var size := (shape as RectangleShape2D).size
		draw_rect(Rect2(-size.x/2,-size.y/2,size.x,size.y),Color(Color.YELLOW,0.5),true)

func _input(event):
	if event.is_action_pressed("left_click"):
		var pegs = get_overlapping_bodies()
		var result = []
		for body in pegs:
			if body.is_in_group("coll_objects"):
				result.append(body)
		area_selected = function.call(result)


func add_money(pegs: Array) -> bool:
	if pegs.size() == 0: # Ensure pegs are selected
		return false

	for peg in pegs: # Apply to each peg in selection
		var replaced = false
		for i in range(peg.functions.size()): # Check for and update existing add_money function
			var existing = peg.functions[i]
			if existing.get("func").get_method() == "add_money":
				existing["params"]["value"] += params.value
				peg.functions[i] = existing
				replaced = true
				break

		if not replaced: # Add the function if it does not already exist
			var new_function = {
				"func": Callable(peg,"add_money"),
				"text": "Add Money",
				"params": {"value": params.value}
			}
			peg.functions.append(new_function)

		peg.set_color(Color.GREEN) # Update peg color
		peg.sound = peg.get_node("moneySound") # Update peg sound
	return true


func remove_pegs(pegs: Array) -> bool:
	if pegs.size() == 0: # Ensure pegs are selected
		return false
	pegs_to_remove = pegs # Set selection to be removed
	return true


func add_bumper(pegs: Array) -> bool:
	if pegs.size() > 0:
		return false
	var new_function = {
		"func": "bump_ball",
		"text": "Bump Ball",
		"params": {}
	}
	var newObj = gameBoard.add_coll_object(global_position, collScene, "Circle Peg", new_function)
	newObj.scale = Vector2(1.5, 1.5)
	return true

func change_size(pegs: Array) -> bool:
	if pegs.size() == 0:
		return false
	for peg in pegs:
		peg.scale *= params.value
	return true

func add_flipper(pegs: Array) -> bool:
	if pegs.size() > 0:
		return false
	var new_function = {
		"func": "flip",
		"text": "Flip Ball",
		"trigger": params.side + "_button",
		"params": {"direction": params.side}
	}
	var newObj = gameBoard.add_coll_object(global_position, collScene, "Flipper", new_function)
	if params.side == "right":
		gameBoard.rightButtonTriggers.append(newObj)
	elif params.side == "left":
		newObj.scale = Vector2(-1,1)
		gameBoard.leftButtonTriggers.append(newObj)
	return true
