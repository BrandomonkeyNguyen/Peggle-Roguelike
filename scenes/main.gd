extends Node2D
class_name Main

const upgrades = preload("res://scenes/helpers/upgrades/upgrades.gd")

const boardScene = preload("res://scenes/game_board.tscn")
const menuScene = preload("res://scenes/menus/menu.tscn")
const musicScene = preload("res://scenes/helpers/music_player.tscn")

var gameBoard: GameBoard
var stage: Stage

var money = 1 
var dropCost = 1

var menu: Node2D
var menuOpen = true
var currentOptions: Array
var selecting = false

var music: AudioStreamPlayer
var state: Dictionary

var gameOver = false

# Called when the node enters the scene tree for the first time.
func _ready():
	gameBoard = boardScene.instantiate() # Instantiate game board, music, and menu
	music = musicScene.instantiate()
	menu = menuScene.instantiate()
	stage = Stage.new()
	
	gameBoard.init_board(stage) # Initialize variables
	
	add_child(gameBoard) # Add game board, music, and menu as children
	add_child(music)
	add_child(menu)
	
	currentOptions = SetPegs.set_options(menu) # Set up initial menu options
	menu.function = Callable(menu, "randomize_pegs")
	menu.params = {"objArr": gameBoard.objArr}
	
	stage.turnsToNextLevel = Levels.check_level(stage.turnsToNextLevel) # Set up initial level state
	$Level.text = "Next level in " + str(stage.turnsToNextLevel) + " levels"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if gameOver or gameBoard.gameOver:
		do_game_over()
	else:
		$Money.text = "Bank Account: $" + str(money)
		$MoneyEarned.text = "Money Earned: $" + str(stage.moneyEarned)
		$DropCost.text = "Cost to Drop: $" + str(dropCost)

		var inventoryText = "" # Maintain Inventory labels
		for item in gameBoard.inventory:
			inventoryText += "* " + item + "\n"
		$Inventory.text = inventoryText
		
		if gameBoard.selector: # Handle if player is using selector
			selecting = gameBoard.handle_selecting()
		
		elif menuOpen: # Handle if player is using menu
			if menu.selected != -1:
				gameBoard.add_ball()
				if currentOptions[menu.selected]["func"].is_valid():
					if "params" in currentOptions[menu.selected]:
						currentOptions[menu.selected]["func"].call(gameBoard, currentOptions[menu.selected]["params"])
					else:
						currentOptions[menu.selected]["func"].call(gameBoard)
				if menu.function.is_valid():
					menu.function.call()
				menu.free()
				menuOpen = false
		
		else: # Handle if game is in play\
			if stage.ballDropped: # Handle if ball was just dropped
				if money >= dropCost:
					money -= dropCost
					dropCost *= 2
				stage.ballDropped = false
			
			if stage.stageEnd: # Handle if ball has reached the bottom
				money += stage.moneyEarned
				
				if dropCost > money: # Handle if the player cannot afford the drop cost
					gameOver = true
			
				if not gameOver and not gameBoard.gameOver: # Handle what to do in the next stage
					play_sound("res://assets/audio/Hooray Sound Effect.mp3") # Play success sound
					
					var newStage = Stage.new() # Reset variables for next stage
					menu = menuScene.instantiate()
					stage.turnsToNextLevel = Levels.check_level(stage.turnsToNextLevel)
					
					if stage.turnsToNextLevel > 0: # Handle if player is not on a new level
						$Level.text = "Next level in " + str(stage.turnsToNextLevel) + " levels"
						newStage.levelStatus = false
						newStage.levelCharacters = []
						newStage.turnsToNextLevel = stage.turnsToNextLevel
						currentOptions = upgrades.set_options(menu)
					else: # Handle if player is starting a new level
						newStage.levelStatus = Levels.get_level()
						newStage.levelCharacters.append(Levels.get_character(newStage.levelStatus))
						
						var spritePath = "res://assets/sprites/" + newStage.levelStatus + "/" + newStage.levelCharacters[0].get("name") + ".png"
						if FileAccess.file_exists(spritePath):
							var desiredSize = Vector2(384,400)
							$LevelSprite.texture = load(spritePath)
							$LevelSprite.scale = desiredSize / $LevelSprite.texture.get_size()
							$Level.text = generate_level_text(newStage.levelStatus, newStage.levelCharacters)
						else:
							print(spritePath + " does not exist.")
							
						music.stop_all()
						currentOptions = Levels.load_level(menu, music)
					
					stage = newStage
					gameBoard.stage = newStage
					
					Levels.level_handler(gameBoard, "level_start")
					
					call_deferred("add_child", menu)
					menuOpen = true
				
			elif gameBoard.ball: # Handle if ball is still in play
				gameBoard.handle_gameplay() 

func do_game_over():
	music.stop_all()
	$GameOver.visible = true
	stage = Stage.new()

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
