extends Node

# NOT IN USE 

const general = preload("res://scenes/helpers/general.gd")
const selectorScene = preload("res://scenes/objects/selector.tscn")
const upgradeOptions = [
	[ #"common":
		"+1 Value Circle",
		"+1 Value Square",
		"Remove Circle",
		"Remove Square"
	],
	[ #"uncommon": 
		"Create Bumper Peg"
	],
	[ #"rare": 
		"+1 Value Circle",
		"+1 Value Square",
		"Remove Circle",
		"Remove Square"
	],
	[ #"epic": 
		"+1 Value Circle",
		"+1 Value Square",
		"Remove Circle",
		"Remove Square"
	],
	[ #"legendary": 
		"+1 Value Circle",
		"+1 Value Square",
		"Remove Circle",
		"Remove Square"
	]
]

static func set_options(menu, weights):
	var currentOptions = []
	for i in range(3):
		var found = true
		while found:
			var rarity = general.weighted_random(weights)
			var optionSet = upgradeOptions[rarity][randi() % upgradeOptions[rarity].size()]
			if optionSet not in currentOptions:
				currentOptions.append(optionSet)
				found = false
	menu.set_options(currentOptions)
	return currentOptions

static func select_pegs(ogNode, function, value, shape):
	print("selecting")
	var selector = selectorScene.instantiate()
	selector.gameBoard = ogNode.gameBoard
	selector.set_function(function, value)
	selector.get_child(0).shape = shape
	ogNode.gameBoard.add_child(selector)
	ogNode.gameBoard.selector = selector
	ogNode.selecting = true

static func run_peg_function(ball, peg):
	match peg.function:
		"Add Money":
			ball.money_gathered += peg.value
		"Bump Ball":
			ball.linear_velocity = ball.linear_velocity.normalized() * 500
			var tween = peg.create_tween()
			tween.tween_property(peg, "scale", Vector2(2, 2), 0.1)
			tween.tween_property(peg, "scale", Vector2(1.5, 1.5), 0.2)
