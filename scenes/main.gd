extends Node2D
class_name Main

const upgrades = preload("res://scenes/helpers/upgrades/upgrades.gd")
const levelHelper = preload("res://scenes/levels/level_helper.gd")

const boardScene = preload("res://scenes/game_board.tscn")
const menuScene = preload("res://scenes/menus/menu.tscn")
const musicScene = preload("res://scenes/helpers/music_player.tscn")

var gameBoard: GameBoard

var menu: Node2D
var menuOpen = true
var selector: Area2D
var selecting = false

var music: AudioStreamPlayer
var gameplay_viewport: Dictionary
var state: Dictionary

var inventory: Array

var money = 1
var moneyEarned = 0
var dropCost = 1
var upgradeWeights = [5,4,3,2,1]

var moneyToLevel = 0
var levelStatus = false
var levelCharacters = []
var currentOptions: Array
var gameOver = false


# Called when the node enters the scene tree for the first time.
func _ready():
	gameplay_viewport = { # Set gameplay viewport variable
		"top": $LeftBorder/Shape.shape.size.y / 8,
		"left": ($LeftBorder/Shape.position.x + ($LeftBorder/Shape.shape.size.x) / 2),
		"x": ($RightBorder/Shape.position.x - ($RightBorder/Shape.shape.size.x) / 2) - ($LeftBorder/Shape.position.x + ($LeftBorder/Shape.shape.size.x) / 2),
		"y": $LeftBorder/Shape.shape.size.y * 3 / 4
	}
	
	gameBoard = boardScene.instantiate() # Instantiate game board, music, and menu
	music = musicScene.instantiate()
	menu = menuScene.instantiate()
	
	gameBoard.init_board(self) # Initialize variables
	
	add_child(gameBoard) # Add game board, music, and menu as children
	add_child(music)
	add_child(menu)
	
	currentOptions = SetPegs.set_options(menu) # Set up initial menu options
	menu.function = Callable(menu, "randomize_pegs")
	menu.params = {"objArr": gameBoard.objArr}
	
	moneyToLevel = Levels.check_level(money) # Set up initial money state
	$Level.text = "Next level at $" + str(moneyToLevel)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Money.text = "Bank Account: $" + str(money)
	$MoneyEarned.text = "Money Earned: $" + str(moneyEarned)
	$DropCost.text = "Cost to Drop: $" + str(dropCost)
	var inventoryText = ""
	for item in inventory:
		inventoryText += "* " + item + "\n"
	$Inventory.text = inventoryText
	if selecting:
		if selector.area_selected:
			if selector.pegs_to_remove != null:
				for peg in selector.pegs_to_remove:
					gameBoard.objArr.erase(peg)
					peg.free()
			selecting = false
			selector.free()
			gameBoard.add_ball()
	elif menuOpen:
		if menu.selected != -1:
			gameBoard.add_ball()
			if currentOptions[menu.selected]["func"].is_valid():
				if "params" in currentOptions[menu.selected]:
					currentOptions[menu.selected]["func"].call(self, currentOptions[menu.selected]["params"])
				else:
					currentOptions[menu.selected]["func"].call(self)
			if menu.function.is_valid():
				menu.function.call()
			menu.free()
			menuOpen = false
	elif !gameOver:
		var gameData = gameBoard.handle_gameplay()
		if gameData["is_dropped"]:
			if gameData["just_dropped"] and dropCost <= money:
				money -= dropCost
				dropCost *= 2
			moneyEarned = gameData["money_gathered"]
			levelHelper.level_handler(self, "during_drop")

func next_level():
	money += moneyEarned
	moneyEarned = 0
	# Update Baskets
	moneyToLevel = Levels.check_level(money) # Fine the next level
	if dropCost > money:
		do_game_over()
	else:
		play_sound("res://assets/audio/Hooray Sound Effect.mp3")
		menu = menuScene.instantiate()
		if levelStatus:
			levelHelper.level_handler(self, "after_landing")
			levelStatus = false
			levelCharacters = []
			$Level.text = "Next level at $" + str(moneyToLevel)
			currentOptions = upgrades.set_options(menu, upgradeWeights)
		else:
			levelStatus = Levels.get_level()
			levelCharacters.append(Levels.get_character(levelStatus))
			
			var spritePath = "res://assets/sprites/" + levelStatus + "/" + levelCharacters[0].get("name") + ".png"
			if FileAccess.file_exists(spritePath):
				var desiredSize = Vector2(384,400)
				$LevelSprite.texture = load(spritePath)
				$LevelSprite.scale = desiredSize / $LevelSprite.texture.get_size()
				$Level.text = generate_level_text(levelStatus, levelCharacters)
			else:
				print(spritePath + " does not exist.")
			
			music.stop_all()
			currentOptions = Levels.load_level(menu)
			levelHelper.level_handler(self, "level_start")
		if not gameOver:
			call_deferred("add_child", menu)
			menuOpen = true

func do_game_over():
	music.stop_all()
	$GameOver.visible = true
	gameOver = true

func play_sound(path: String):
	var sound_stream = load(path)
	$SoundPlayer.stream = sound_stream
	$SoundPlayer.play()

func generate_level_text(level: String, characters: Array):
	var returnText = ""
	returnText += level + "\n"
	for character in characters:
		returnText += character.get("name","No Name Found")
	returnText += "\n"
	returnText += characters[0].get("desc", "No Description")
	return returnText

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_input_event_left(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		gameBoard.trigger_left_button()

func _on_input_event_right(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		gameBoard.trigger_right_button()
