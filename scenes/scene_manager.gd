extends Node2D
class_name SceneManager

const main_menu = preload("res://scenes/main_menu.tscn")
var currScene : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currScene = main_menu.instantiate()
	add_child(currScene)
