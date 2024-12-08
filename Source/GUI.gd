extends Node
var stone_count = 0
var tree_count = 0
onready var stone_label = $HBoxContainer/Counters/Counter/Background/Number
onready var tree_label = $HBoxContainer/Counters2/Counter/Background/Number


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _add_stone():
	stone_count +=1
	stone_label.text = str(stone_count)
	
func _add_tree():
	tree_count +=1
	tree_label.text = str(tree_count)
