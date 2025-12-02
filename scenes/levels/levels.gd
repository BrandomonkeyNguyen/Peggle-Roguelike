class_name Levels

static var level_data_file = "res://assets/data/levels.json"
static var level_data_json = FileAccess.get_file_as_string(level_data_file)
static var level_data = JSON.parse_string(level_data_json)

static var level_order_file = "user://level_order.json"
static var level_order_json = FileAccess.get_file_as_string(level_order_file)
static var level_order = JSON.parse_string(level_order_json)

static var levelStageCounterMax = 3

static func level_handler(mainNode: Main, handleType):
	for character in mainNode.stage.levelCharacters:
		if character.has(handleType):
			var newFunction = Callable(LevelHelper,character[handleType])
			newFunction.call(mainNode)

static func get_level():
	if level_order.size() > 0:
		var current_level = JSON.parse_string(level_order[0])
		for level in level_data.keys():
			var characters = level_data[level].get("characters", [])
			for character in characters:
				if character == current_level:
					return level
	return level_data.keys()[randi() % level_data.size()]

static func get_character(level):
	if level_order.size() > 0:
		var next_level = JSON.parse_string(level_order[0])
		level_order.pop_front()
		return next_level
	else:
		var characters = level_data[level].characters
		return characters[randi() % characters.size()]

static func check_level(levelsUntilNext: int) -> int:
	if levelsUntilNext == 0:
		levelsUntilNext = levelStageCounterMax
		return 0
	else:
		levelsUntilNext -= 1
		return levelsUntilNext

static func load_level(menu, music):
	var options = []
	for i in 3:
		options.append({"text": "Next Level", "func": Callable(Levels, "progress_level"), "params": {"music": music}})
	menu.set_options(options)
	return options

static func progress_level(mainNode: Main, params):
	var gameBoard = mainNode.gameBoard
	params.music.set_music(gameBoard.stage.levelStatus)
	params.music.play()
	level_handler(mainNode, "level_start")
