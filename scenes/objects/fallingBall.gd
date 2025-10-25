extends RigidBody2D
class_name Ball

@onready var shape = $ballShape.shape
var last_position: Vector2
var movement_direction: Vector2
var last_position_stuck: Vector2
var impulse_factor = 1
var last_touched: StaticBody2D
var all_touched: Array
var is_dropped = false
var time_dropped = null
var money_gathered = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	last_position = global_position
	last_position_stuck = global_position


func _physics_process(_delta):
	movement_direction = last_position.direction_to(global_position)
	last_position = global_position
	if movement_direction.x == 0 and movement_direction.y > 0:
		apply_central_impulse(Vector2(randf() - 0.5, 0))
	if abs(linear_velocity.x) < 0.05 and abs(linear_velocity.y) < 0.05:
		if get_colliding_bodies().size() > 1:
			if global_position.distance_to(last_position_stuck) < 50:
				impulse_factor *= 1.5
			else:
				impulse_factor = 1
			last_position_stuck = global_position
			apply_central_impulse(Vector2(100 * impulse_factor * (randf() - 0.5), -250 * impulse_factor))
		else:
			apply_central_impulse(Vector2(randf() - 10, 0))


func _input(event):
	if event.is_action_pressed("left_click") and !is_dropped:
		is_dropped = true
		time_dropped = Time.get_ticks_msec()
		linear_velocity = Vector2(0,0.1)


func _on_body_entered(body):
	if body.is_in_group("coll_objects") and Time.get_ticks_msec() - body.time_touched > 250:
		body.time_touched = Time.get_ticks_msec()
		
		for function in body.functions:
			function["func"].call(function["params"])
			body.do_pop_up()
		body.sound.play()
		
		last_touched = body
		if body not in all_touched:
			all_touched.append(body)


func get_radius():
	return $ballShape.shape.radius
