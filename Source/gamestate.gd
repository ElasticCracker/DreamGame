extends Node

# Default game port
const DEFAULT_PORT = 10567

# Max number of players
const MAX_PEERS = 12

# Name for my player
var player_name = "The Warrior"
var player_team = 1
# Names for remote players in id:name format
var players = {}
var players_teams= {}
# Signals to let lobby GUI know what's going on
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)
# Callback from SceneTree
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here
	rpc_id(id, "register_player", player_name, player_team)
# Callback from SceneTree
func _player_disconnected(id):
	if has_node("/root/world"): # Game is in progress
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else: # Game is not in progress
		# Unregister this player
		unregister_player(id)

# Callback from SceneTree, only for clients (not server)
func _connected_ok():
	# We just connected to a server
	emit_signal("connection_succeeded")

# Callback from SceneTree, only for clients (not server)
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()

# Callback from SceneTree, only for clients (not server)
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")

# Lobby management functions

sync func register_player(new_player_name, playerTeam):
	var id = get_tree().get_rpc_sender_id()
#	print(id)
	players[id] =new_player_name
	players_teams[id] = playerTeam
	
	emit_signal("player_list_changed")

sync func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")

func join_team1():
	player_team=1
	rpc("register_player", player_name, 1)

	
	
func join_team2():
	player_team=2
	rpc("register_player", player_name, 2)


#remote func set_teamLists(id, team):
##	playerTeams[id]=team
#	if get_tree().is_network_server():
#		for p in playerTeams:
#			rpc("set_teamLists", p, playerTeams[p])
#		rpc("player_list_changed_func")
#sync func player_list_changed_func():
#	emit_signal("player_list_changed")

remote func pre_start_game(spawn_points):
	# Change scene
	var world = load("res://Source/Main.tscn").instance()
	get_tree().get_root().add_child(world)

	get_tree().get_root().get_node("Lobby").hide()

	var player_scene = load("res://Source/Ship.tscn")
	var spawn_pos 
	
	for p_id in spawn_points:
		if spawn_points[p_id]==1:
			 spawn_pos = world.get_node("Spawn1").position
		if spawn_points[p_id]==2:
			 spawn_pos = world.get_node("Spawn2").position
		var player = player_scene.instance()
		player.networkID=int(p_id)
		player.spawn=spawn_pos
		player.team=int(spawn_points[p_id])
		player.set_name(str(p_id)) # Use unique ID as node name
		print(player.name)
		player.position=spawn_pos
		player.set_network_master(int(p_id)) #set unique id as master


### ATM I THINK THIS IS UNNEEDED> AFRAID TO DELETE UNTIL CONFRIMED
#		if int(p_id) == get_tree().get_network_unique_id():
#			# If node for this peer id, set name
#			player.set_player_name(player_name)
#		else:
#			# Otherwise set name from peer
#			player.set_player_name(players[p_id])

		world.get_node("players").add_child(player)

	# Set up score
#	world.get_node("score").add_player(get_tree().get_network_unique_id(), player_name)
#	for pn in players:
#		world.get_node("score").add_player(pn, players[pn])

	if not get_tree().is_network_server():
		# Tell server we are ready to start
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()

remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!

var players_ready = []

remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()

func host_game(new_player_name):
	player_name = new_player_name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)

func join_game(ip, new_player_name):
	player_name = new_player_name
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)

func get_player_list():
	return players

func get_player_name():
	return player_name
	
func get_players_team():
	return players_teams

func begin_game():
	assert(get_tree().is_network_server())

	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing
	var spawn_points = {}
	spawn_points[1] = 1 # Server in spawn point 0
	for p_id in players:
		if players_teams[p_id]==1:
			spawn_points[p_id] = 1
		if players_teams[p_id]==2:
			spawn_points[p_id] = 2
	# Call to pre-start game with the spawn points
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)
#@@@@@@@
	pre_start_game(spawn_points)

func end_game():
	if has_node("/root/world"): # Game is in progress
		# End it
		get_node("/root/world").queue_free()

	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer(null) # End networking

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


