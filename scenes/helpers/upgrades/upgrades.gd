class_name Upgrades

const general = preload("res://scenes/helpers/general.gd")
const selectorScene = preload("res://scenes/objects/selector.tscn")

static var normal_selector_scale = 64

static var upgrade_data_file = "res://assets/data/upgrades.json"
static var upgrade_data_json = FileAccess.get_file_as_string(upgrade_data_file)
static var upgradeOptions = JSON.parse_string(upgrade_data_json)

static func set_options(menu, weights: Array = [5,4,3,2,1]):
	var currentOptions = []
	while currentOptions.size() < 3:
		var rarity = general.weighted_random(weights)
		var optionSet = upgradeOptions[rarity].pick_random()
		if optionSet["func"] is String:
			optionSet["func"] = Callable(Upgrades, optionSet["func"])
		if optionSet not in currentOptions:
			currentOptions.append(optionSet)
	menu.set_options(currentOptions)
	return currentOptions


# Helper Functions
static func make_shape(shape_type: String, scale: float = 1.0) -> Shape2D:
	match shape_type:
		"circle":
			var c = CircleShape2D.new()
			c.radius = normal_selector_scale * scale
			return c
		"square":
			var r = RectangleShape2D.new()
			r.size = Vector2.ONE * (normal_selector_scale * scale * 2)
			return r
	return null

static func select(gameBoard: GameBoard, function: String, params: Dictionary, shape: Shape2D):
	var selector = selectorScene.instantiate()
	selector.gameBoard = gameBoard
	selector.function = Callable(selector, function)
	selector.params = params
	selector.get_child(0).shape = shape
	gameBoard.add_child(selector)
	gameBoard.selector = selector

# Upgrade Functions
static func add_value(mainNode: Main, params: Dictionary = {}):
	var shape = make_shape(params.shape, params.scale)
	if shape:
		select(mainNode.gameBoard, "add_money", {"value": params.value}, shape)

static func remove(mainNode: Main, params: Dictionary = {}):
	var shape = make_shape(params.shape, params.scale)
	if shape:
		select(mainNode.gameBoard, "remove_pegs", {}, shape)

static func add_bumper(mainNode: Main, params: Dictionary = {}):
	var shape = make_shape(params.shape, params.scale)
	if shape:
		select(mainNode.gameBoard, "add_bumper", {}, shape)

static func silver_bullet(mainNode: Main, _params: Dictionary = {}):
	mainNode.gameBoard.inventory.append("Silver Bullet")

static func change_size(mainNode: Main, params: Dictionary = {}):
	var shape = make_shape(params.shape, params.scale)
	if shape:
		select(mainNode.gameBoard, "change_size", {"value": params.value}, shape)

static func add_flipper(mainNode: Main, params: Dictionary = {}):
	var shape = make_shape(params.shape, params.scale)
	if shape:
		select(mainNode.gameBoard, "add_flipper", {"side": params.side}, shape)
