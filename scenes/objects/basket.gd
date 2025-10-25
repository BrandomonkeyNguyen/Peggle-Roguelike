extends Area2D

var entered = false
var label: String
var function: Callable
var params: Dictionary

func _ready():
	$Label.text = label

func _on_body_entered(body):
	if body.is_in_group("ball"):
		entered = true

# Basket Functions
func add_money():
	params.ogNode.moneyEarned += params.value
