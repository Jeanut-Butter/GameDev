extends Node2D

@export var seedName = ""

func _ready() -> void:
	var seedToUse : int = hash( seedName ) if (seedName) else randi()
	seed( seedToUse)
	print(seedToUse, " is the seed being used")
