extends KinematicBody2D

export var speed = 150
export var maxHealth = 100


#---Player Info
var team=1
var health = maxHealth
var Mouse_position
var globalMousePosition = Vector2()
var networkID
var is_throwing=false
var is_dead=false
var spawn=Vector2()
#------Harvesting vars--------
var harvesting  = false

#-----Equipment vars-----
var current_equipID = 0

#onready var GUI=preload("res://Source/GUI.tscn")
var healthText
var healthSlider
onready var cameraScene=preload("res://Source/Camera2D.tscn")

#------------------------
#---  Equipment List  ---
#------------------------
onready var crosshairScene=preload("res://Source/Equipment/Crosshair.tscn")
var crosshair_instance = null

var inventoryClass = null

#onready var arrowScene=preload("res://Source/Arrow.tscn")

var spearHeldScene = preload("res://Source/Equipment/Spear_Held.tscn")
var spearHeld = null #1

onready var pickaxeScene = preload("res://Source/Equipment/Pickaxe.tscn")
var pickaxe = null #2

onready var hatchetScene = preload("res://Source/Equipment/Hatchet.tscn")
var hatchet = null #4

onready var grenadeScene = preload("res://Source/Equipment/Grenade.tscn")
var grenade=null #3


#Network Stuff
puppet var slave_position = Vector2()
puppet var slave_rotation = 0
var velocity = Vector2()
# Called when the node enters the scene tree for the first time.
func _ready():
	if is_network_master():
		name=str(get_tree().get_network_unique_id())
		var GUI=preload("res://Source/GUI.tscn")
		var localGUI= GUI.instance()
		var localInventory= preload("res://Source/Inventory.tscn")
		inventoryClass=localInventory.instance()
		
		get_tree().get_root().add_child(inventoryClass)
		
		get_tree().get_root().add_child(localGUI)
		healthText= get_node("/root/GUI_NODE/GUI/HBoxContainer/Bars/Bar/Count/Background/Number")
		healthSlider=get_node("/root/GUI_NODE/GUI/HBoxContainer/Bars/Bar/Gauge")
		
	
#		for children in get_tree().get_root().get_children():
#			print(children.name)
		crosshair_instance = crosshairScene.instance()
		
		add_child(cameraScene.instance())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _get_input():
	Mouse_position=get_local_mouse_position()
	if !is_dead:
		if is_network_master():
			globalMousePosition=get_global_mouse_position()
			velocity = Vector2()
			#-----Movement Block-----
			if Input.is_action_pressed("move_right"):
				velocity.x += 1
			if Input.is_action_pressed("move_left"):
				velocity.x -= 1
			if Input.is_action_pressed("move_down"):
				velocity.y += 1
			if Input.is_action_pressed("move_up"):
				velocity.y -= 1
			if velocity.length() > 0:
				velocity = velocity.normalized() * speed
			#position += velocity * delta
			rotation += Mouse_position.angle()
		#		position.x = clamp(position.x, 0, screen_size.x)
		#		position.y = clamp(position.y, 0, screen_size.y)
			rset_unreliable("slave_position", position)
			rset_unreliable("slave_rotation", rotation)
			
			#-----Equipment Block-----
			
			#----- Spear Block -----
			if Input.is_action_just_pressed("equip1"):
				if current_equipID != 1:
					rpc('_unequip',current_equipID)
					rpc('_equip',1)
					
					current_equipID=1
		
			#----- Pickaxe Block -----
			if Input.is_action_just_pressed("equip2"):
				if current_equipID != 2:
					rpc('_unequip',current_equipID)
					rpc('_equip',2)
					current_equipID=2
			
			if Input.is_action_just_pressed("equip4"):
				if current_equipID != 4:
					rpc('_unequip', current_equipID)
					rpc('_equip',4)
					current_equipID=4
			
				#----- Grenade Block -----
			if Input.is_action_just_pressed("throw"):
				if !is_throwing:
					rpc('_unequip',current_equipID)
					rpc('_equip',3)
					current_equipID=3
					is_throwing=true
					get_tree().get_root().add_child(crosshair_instance)
				else:
					get_tree().get_root().remove_child(crosshair_instance)
					is_throwing=false
			if Input.is_action_just_pressed("left_click"):
				if is_throwing==true && crosshair_instance.in_Range==true:
					rpc('_throwGrenade',position,rotation,globalMousePosition)
					rpc('_unequip',3)
					get_tree().get_root().remove_child(crosshair_instance) #Removes the crosshair when grenade is thrown
		
		#				_localThrowGrenade()
					is_throwing=false
		
			if is_throwing==true:
				crosshair_instance.playerPosition = position
				
		else:
			position = slave_position
			rotation = slave_rotation
#Benjamins ADDED CODE to try and make collisions work
func _physics_process(delta):
	_get_input()
	move_and_collide(velocity * delta)

#This function will equip a set item:
#---Purpose---
#Will take an item ID (int) input and change the sprite of the equipment on the player
sync func _equip(id):
	match id:
		1: #ID 1= Spear
			spearHeld=spearHeldScene.instance()
			spearHeld.set_network_master(networkID)
			add_child(spearHeld)
			current_equipID=1
		2: #ID 2= Pickaxe
			pickaxe=pickaxeScene.instance()
			pickaxe.set_network_master(networkID)
			add_child(pickaxe)
			current_equipID=2
		4: #ID 4 = hatchet
			hatchet = hatchetScene.instance()
			hatchet.set_network_master(networkID)
			add_child(hatchet)
			current_equipID=4
		3: #ID 3= Grenade
			grenade=grenadeScene.instance()
#			grenade.set_network_master(networkID)
			add_child(grenade)
			current_equipID=3
			
	pass


sync func _unequip(id):
	match id:
		0:
			pass
		1: #ID 1 = Spear
			remove_child(spearHeld)
		2: #ID 2 = Pickaxe
			remove_child(pickaxe)
		4: #ID 3 = Hatchet
			remove_child(hatchet)
		3: #ID 3 = Grenade
			remove_child(grenade)
	current_equipID=0
	

remote func _hit(damage):
	health-= damage
#	GUI/HBoxContainer/Bars/Bar/Gauge.text
	print("IM HIT!!!")
	if health <= 0:
		health=0
		rpc('_die')
	if is_network_master():
		healthSlider.value=health
		healthText.text=str(health)


func _localHit(damage):
	health-= damage

	print("IM HIT LOCALLY!!!")
	if health <= 0:
		health=0
		rpc('_die')
	healthSlider.value=health
	healthText.text=str(health)
	


sync func _die():
	set_process(false)
	rpc('_unequip',current_equipID)
	hide()
	is_dead=true
	$rstime.start()

sync func respawn_N():
	print("respawning Network")
	self.show()
	set_process(true)
	position=spawn
	health=maxHealth
	is_dead=false


sync func _throwGrenade(inPosition,inRotation,inTarget):
	var projectile=grenadeScene.instance()
	projectile.position=inPosition
	projectile.rotation=inRotation
	projectile.is_thrown=true
	projectile.target=inTarget
	get_tree().get_root().add_child(projectile)
	
	
#	### ATM I THINK THIS IS UNNEEDED> AFRAID TO DELETE UNTIL CONFRIMED
#func set_player_name(player_name):
#	pass

func _on_rstime_timeout():
	rpc('respawn_N')
	if is_network_master():
		healthSlider.value=health
		healthText.text=str(health)

func walked_in_range_of_dropped_item(itemName):
	var gridContainerClass = inventoryClass.get_node("Panel/GridContainer")
	gridContainerClass.pickup_item(itemName)

