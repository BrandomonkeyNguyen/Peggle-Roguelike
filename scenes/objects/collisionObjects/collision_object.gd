extends StaticBody2D
class_name CollisionObject

const circlePegScene = preload("res://scenes/objects/collisionObjects/circlePeg.tscn")
const flipperScene = preload("res://scenes/objects/collisionObjects/flipper.tscn")
const pop_up = preload("res://scenes/objects/number_pop_up.tscn")

var mainScene: Node2D
var anim: AnimationPlayer
var sound: AudioStreamPlayer
var functions := []
var triggeredFunctions := []
var object: Node2D
var objectName: String
var time_touched = 0
var pop_up_arr = []

func _ready():
	sound = $boingSound

func _process(_delta):
	for obj in pop_up_arr:
		if obj.donePlaying:
			pop_up_arr.erase(obj)
			obj.free()

func do_pop_up():
	if functions.size() > 0:
		var new_pop_up = pop_up.instantiate()
		pop_up_arr.append(new_pop_up)
		add_child(new_pop_up)
		new_pop_up.set_text(functions[0].text)
		new_pop_up.play_anim()

func _on_mouse_entered():
	if !functions.is_empty():
		$HoverBox/HoverText.text = functions[0].text
		$Animate.play("onHover")

func _on_mouse_exited():
	if !functions.is_empty():
		$Animate.play("offHover")

func set_object(obj):
	objectName = obj
	if obj == "Circle Peg":
		object = circlePegScene.instantiate()
		object.color = Color.RED
		add_child(object)
	elif obj == "Flipper":
		object = flipperScene.instantiate()
		object.color = Color.RED
		add_child(object)

func set_color(color):
	object.color = color


# FUNCTIONS

func add_money(params: Dictionary):
	mainScene.ball.money_gathered += params.value

func bump_ball(_params: Dictionary = {}):
	mainScene.ball.linear_velocity = mainScene.ball.linear_velocity.normalized() * 500
	var tween = self.create_tween()
	tween.tween_property(self, "scale", Vector2(2, 2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)

func silver_bullet(_params: Dictionary = {}):
	mainScene.inventory.append("Silver Bullet")
	var is_green = false
	for function in functions:
		if function.get("func").get_method() == "silver_bullet":
			functions.erase(function)
		elif function.get("func").get_method() == "add_money":
			is_green = true
	if is_green:
		set_color(Color.GREEN)
	else:
		set_color(Color.RED)

func giraffe(_params: Dictionary = {}):
	var ball: Ball = mainScene.get("ball")
	if ball:
		ball.gravity_scale *= 0.5
		ball.physics_material_override.bounce *= 0.5
		ball.physics_material_override.friction *= 2
	await get_tree().create_timer(3).timeout
	if ball:
		ball.gravity_scale *= 2
		ball.physics_material_override.bounce *= 2
		ball.physics_material_override.friction *= 0.5

func elephant(_params: Dictionary = {}):
	var space_state = get_world_2d().direct_space_state
	
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 128
	query.shape = shape
	query.transform = Transform2D.IDENTITY.translated(global_position)
	query.collision_mask = 1

	var results = space_state.intersect_shape(query)

	for result in results:
		var peg = result.get("collider")
		if peg.is_in_group("coll_objects"):
			var direction = (peg.global_position - global_position).normalized()
			var new_pos = peg.global_position + (direction * 5)
			var tween := get_tree().create_tween()
			tween.tween_property(peg, "global_position", new_pos, 0.15)
	
	mainScene.ball.linear_velocity = mainScene.ball.linear_velocity.normalized() * 500

func random_monkey_effect():
	print("Random Monkey Effect!")

func monkey1(_params: Dictionary = {}):
	if self == mainScene.ball.last_touched:
		mainScene.state.monkey_last_hit = time_touched
	elif not mainScene.state.monkey_combo_active:
		mainScene.state.monkey_combo_active = true
		mainScene.state.monkey_last_hit = time_touched
		mainScene.state.monkey_combo_count = 1
	elif time_touched - mainScene.state.monkey_last_hit <= 1000:
		mainScene.state.monkey_last_hit = time_touched
		mainScene.state.monkey_combo_count += 1
		if mainScene.state.monkey_combo_count == 5:
			random_monkey_effect()
			mainScene.state.monkey_combo_active = false
			mainScene.state.monkey_last_hit = time_touched
			mainScene.state.monkey_combo_count = 0
	else:
		mainScene.state.monkey_combo_active = true
		mainScene.state.monkey_last_hit = time_touched
		mainScene.state.monkey_combo_count = 1
	for function in functions:
		if function.func == Callable(self, "monkey1"):
			function.text = "COMBO " + str(mainScene.state.monkey_combo_count)


# TRIGGERED FUNCTIONS

func flip(params: Dictionary):
	var tween = create_tween()
	var rotationVal = 1
	if params.direction == "left":
		rotationVal = -1
	tween.tween_property(self, "rotation", rotationVal, 0.1)
	tween.tween_property(self, "rotation", 0, 0.5)
