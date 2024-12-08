extends Node

#var positionInArea_stone = Vector2()
#var positionInArea_tree = Vector2()

#Tree Spawnpoints



onready var stone = preload("res://Source/Stone.tscn")
onready var tree = preload("res://Source/Tree.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	_spawning()
#	_spawning()
#	_spawning()

#func _spawning():
#
#	#STONES
#	positionInArea_stone.x = (randi() % 100) - (100/2) + 50
#	positionInArea_stone.y = (randi() % 300) - (300/2) + 30
#
#	#Trees
#	positionInArea_tree.x = (randi() % 100) - (100/2) + 50
#	positionInArea_tree.y = (randi() % 300) - (300/2) + 30
##
#
#	var newRock=stone.instance()
#	var newTree = tree.instance()
#
#	newRock.position = positionInArea_stone
#	newTree.position = positionInArea_tree
#
#	get_tree().get_root().add_child(newRock)
#	get_tree().get_root().add_child(newTree)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
