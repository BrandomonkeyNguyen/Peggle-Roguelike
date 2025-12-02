extends Node2D
class_name Main

const upgrades = preload("res://scenes/helpers/upgrades/upgrades.gd")

const boardScene = preload("res://scenes/game_board.tscn")
const menuScene = preload("res://scenes/menus/menu.tscn")
const musicScene = preload("res://scenes/helpers/music_player.tscn")

const collScene = preload("res://scenes/objects/collisionObjects/collision_object.tscn")
const basketScene = preload("res://scenes/objects/basket.tscn")

var gameBoard: GameBoard
var stage: Stage

var turnCount = 0
var money = 1 
var dropCost = 1

var menu: Node2D
var menuOpen = true
var currentOptions: Array
var selecting = false

var music: AudioStreamPlayer
var levelState: Dictionary

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
	
	if load_game() == false:
		currentOptions = SetPegs.set_options(menu) # Set up initial menu options
		menu.function = Callable(menu, "randomize_pegs")
		menu.params = {"objArr": gameBoard.objArr}
		
		stage.turnsToNextLevel = Levels.check_level(stage.turnsToNextLevel) # Set up initial level state
		
		gameBoard.add_basket("Gain $10", "add_money", {"value": 10})
	else:
		currentOptions = upgrades.set_options(menu) # Set up next menu options
	
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
		
		if selecting == true: # Handle if player is using selector
			selecting = gameBoard.handle_selecting()
		
		elif menuOpen: # Handle if player is using menu
			if menu.selected != -1:
				if currentOptions[menu.selected]["func"].is_valid():
					if "params" in currentOptions[menu.selected]:
						currentOptions[menu.selected]["func"].call(self, currentOptions[menu.selected]["params"])
					else:
						currentOptions[menu.selected]["func"].call(self)
				if menu.function.is_valid():
					menu.function.call()
				menu.free()
				menuOpen = false
				selecting = true
		
		else: # Handle if game is in play
			if stage.ballDropped: # Handle if ball was just dropped
				if money >= dropCost:
					money -= dropCost
					dropCost *= 2
				stage.ballDropped = false
				Levels.level_handler(self, "on_drop")
			
			if stage.stageEnd: # Handle if ball has reached the bottom
				money += stage.moneyEarned
				
				if dropCost > money: # Handle if the player cannot afford the drop cost
					gameOver = true
			
				if not gameOver and not gameBoard.gameOver: # Handle what to do in the next stage
					play_sound("res://assets/audio/Hooray Sound Effect.mp3") # Play success sound
					turnCount = turnCount + 1
					save_high_scores()
					
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
					
					call_deferred("add_child", menu)
					menuOpen = true
				
			elif gameBoard.ball: # Handle if ball is still in play
				gameBoard.handle_gameplay()
				Levels.level_handler(self, "during_drop")

func _on_resetter_body_entered(body):
	if body == gameBoard.ball and not gameOver: # Ensure the ball has entered basket
		for basket in gameBoard.basketArr: # Handle Basket functions
			if basket.entered:
				basket.function.call()
				basket.entered = false
		stage.stageEnd = true
		body.free() # Free ball
		Levels.level_handler(self, "after_landing")
		save_game()
	elif body.is_in_group("ball"):
		body.free()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func do_game_over():
	var file = FileAccess.open("user://save_data.json", FileAccess.WRITE) # Empty out save file
	file.store_string("{}") 
	file.close()
	
	music.stop_all()
	$GameOver.visible = true
	stage = Stage.new()

func play_sound(path: String):
	var sound_stream = load(path)
	$SoundPlayer.stream = sound_stream
	$SoundPlayer.play()

func add_game_board(new_stage):
	gameBoard = boardScene.instantiate() # Instantiate game board, music, and menu
	gameBoard.init_board(new_stage) # Initialize variables
	call_deferred("add_child", gameBoard) # Add game board, music, and menu as children

func save_high_scores():
	var high_score_file = "user://high_scores.json"
	var result = {}
	
	if not FileAccess.file_exists(high_score_file):
		result = {"money": money, "turns": turnCount}
		print("No save file found.")
	else:
		var read_file = FileAccess.open(high_score_file, FileAccess.READ)
		var read_json_string = read_file.get_as_text()
		read_file.close()
		
		result = JSON.parse_string(read_json_string)
		
		if result is Dictionary and "money" in result and "turnCount" in result:
			if result.money < money:
				result.money = money
			if result.turnCount < turnCount:
				result.turnCount = turnCount
		else: 
			result = {"money": money, "turns": turnCount}
	
	var file = FileAccess.open(high_score_file, FileAccess.WRITE)
	var json_string = JSON.stringify(result)
	
	if file:
		file.store_string(json_string)
		file.close()
		print("Saved game data to: ", high_score_file)
	else:
		print("Failed to save file!")

func save_game():
	var save_file = "user://save_data.json"
	
	var save_data = {
		"money": money,
		"dropCost": dropCost,
		"turnCount": turnCount,
		"turnsToNextLevel": stage.turnsToNextLevel,
		"objArr": [],
		"basketArr": [],
		"inventory": gameBoard.inventory
	}
	
	for obj in gameBoard.objArr:
		var newObj = {
			"objectName": obj.objectName,
			"position": {"x": obj.position.x, "y": obj.position.y},
			"color": obj.object.color.to_html(),
			"sound": obj.sound.name,
			"functions": []
		}
		for function in obj.functions:
			var saveFunc = {
				"func": function.func.get_method(),
				"text": function.text,
				"params": function.params
			}
			newObj.functions.append(saveFunc)
		save_data.objArr.append(newObj)
	
	for basket in gameBoard.basketArr:
		var newBasket = {
			"label": basket.label,
			"function": basket.function.get_method(),
			"params": basket.params
		}
		save_data.basketArr.append(newBasket)
	
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	var json_string = JSON.stringify(save_data, "\t")
	
	if file:
		file.store_string(json_string)
		file.close()
		print("Saved game data to: ", save_file)
	else:
		print("Failed to save file!")

func load_game(boardOnly: bool = false) -> bool:
	if not FileAccess.file_exists("user://save_data.json"):
		print("No save file found.")
		return false
	
	var file = FileAccess.open("user://save_data.json", FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	if not json_string == "":
		var result = JSON.parse_string(json_string)
		if result is Dictionary:
			if not boardOnly:
				money = result.money
				dropCost = result.dropCost
				gameBoard.inventory = result.inventory
				turnCount = result.turnCount
				stage.turnsToNextLevel = result.turnsToNextLevel
			
			for obj in result.objArr:
				gameBoard.add_coll_object(
					Vector2(obj.position.x, obj.position.y), 
					collScene, obj.objectName, obj.functions, 
					Color.html(obj.color),
					obj.sound
				)
			
			for basket in result.basketArr:
				gameBoard.add_basket(basket.label, basket.function, basket.params)
			
			return true
	
	return false

func generate_level_text(level: String, characters: Array):
	var returnText = ""
	returnText += level + "\n"
	for character in characters:
		returnText += character.get("name","No Name Found")
	returnText += "\n"
	returnText += characters[0].get("desc", "No Description")
	return returnText

func _on_input_event_left(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		gameBoard.trigger_left_button()

func _on_input_event_right(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		gameBoard.trigger_right_button()
