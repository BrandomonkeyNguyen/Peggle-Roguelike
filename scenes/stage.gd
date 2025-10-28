extends Node
class_name Stage

var stageEnd: bool = false

var moneyEarned: float = 0 # Money Variabless
var ballDropped: bool = false

var levelStatus = false # Level Variables
var levelCharacters: Array = []
var turnsToNextLevel: int = Levels.levelStageCounterMax
