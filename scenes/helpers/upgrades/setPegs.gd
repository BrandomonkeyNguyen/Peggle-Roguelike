class_name SetPegs

const collScene = preload("res://scenes/objects/collisionObjects/collision_object.tscn")

# Set Pegs Option Handlers
const gridOptions = [
	{"text": "Circles", "func": Callable(SetPegs, "set_circles")},
	{"text": "Grid", "func": Callable(SetPegs, "set_grid")},
	{"text": "Offset Grid", "func": Callable(SetPegs, "set_grid_offset")},
	{"text": "Tapered", "func": Callable(SetPegs, "set_tapered")},
	{"text": "Triangles", "func": Callable(SetPegs, "set_triangles")}
]

static func set_options(menu):
	var currentOptions = []
	var temp_arr = gridOptions.duplicate()
	for i in range(3):
		var optionSet = temp_arr.pop_at(randi_range(0,temp_arr.size()-1))
		currentOptions.append(optionSet)
	menu.set_options(currentOptions)
	return currentOptions


# Helpers
static func get_viewport_size(ogNode):
	return ogNode.gameplay_viewport


# Set Pegs Functions
static func set_grid(ogNode):
	var viewport = get_viewport_size(ogNode)
	var i = -4.5
	while i < 5:
		var x = viewport.x / 11 * i + (viewport.x/2 + viewport.left)
		var j = -4.5
		while j < 5:
			var y = viewport.y / 11 * j + (viewport.y/2 + viewport.top)
			ogNode.gameBoard.add_coll_object(Vector2(x,y), collScene, "Circle Peg")
			j += 1
		i += 1

static func set_grid_offset(ogNode):
	var viewport = get_viewport_size(ogNode)
	var i = -4.5
	while i < 5:
		var j = -4.5
		while j < 5:
			var x = viewport.x / 11 * i + (viewport.x/2 + viewport.left)
			var y = viewport.y / 11 * j + (viewport.y/2 + viewport.top)
			if int(j - 0.5) % 2 == 0:
				x += (viewport.x/11/4)
			else:
				x -= (viewport.x/11/4)
			ogNode.gameBoard.add_coll_object(Vector2(x,y), collScene, "Circle Peg")
			j += 1
		i += 1

static func set_circles(ogNode):
	var viewport = get_viewport_size(ogNode)
	for i in range(1,21):
		for j in range(1,6):
			var x = cos(2 * PI / 20 * i) * (viewport.x / 11 * j) + (viewport.x/2 + viewport.left)
			var y = sin(2 * PI / 20 * i) * (viewport.y / 10 * j) + (viewport.y/2 + viewport.top)
			ogNode.gameBoard.add_coll_object(Vector2(x,y), collScene, "Circle Peg")

static func set_triangles(ogNode):
	var viewport = get_viewport_size(ogNode)
	var base_width = viewport.x  # Width of the widest (last) row
	var center_x = viewport.left + viewport.x / 2
	var start_y = viewport.top + viewport.y
	var row_height = viewport.y / 15
	var total_rows = 15
	for i in range(1, total_rows):
		var num_pegs = i
		var row_width = (base_width / total_rows) * i
		var x_start = center_x - (row_width / 2)
		for j in range(num_pegs):
			var x = x_start + (row_width / (num_pegs - 1)) * j if num_pegs > 1 else center_x
			var y = start_y - row_height * (i - 1)
			ogNode.gameBoard.add_coll_object(Vector2(x, y), collScene, "Circle Peg")


static func set_tapered(ogNode):
	var viewport = get_viewport_size(ogNode)
	var center_x = viewport.x / 2 + viewport.left
	var start_y = viewport.top + viewport.y
	var row_height = viewport.y / 15
	for i in range(1, 15):
		var row_width = viewport.x
		var left = center_x - (row_width / 2)
		for j in range(1, i + 1):
			var x = left + (row_width / (i + 1)) * j
			var y = start_y - row_height * i
			ogNode.gameBoard.add_coll_object(Vector2(x, y), collScene, "Circle Peg")
