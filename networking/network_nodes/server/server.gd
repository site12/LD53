class_name Server extends Node
## server functionality

##
## constants and variables
##

# constants for port and maximum players connected to server
const PORT:int = 44555
const MAX_PLAYERS:int = 1500


signal _server_started

# our multiplayer peer object
var multiplayer_peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new() 

# a reference to the session scene
var session_scene = preload("res://networking/network_nodes/session/session.tscn")

# a list of connected IDs
@export var connected_peer_ids = []

# an array of the created sessions
@export var sessions:Array[Session] = []

##
## Server Functionality
##

# starts the server and connects the peer_connected and peer_disconnected signals to
# add_player_to_server and remove_player_from_server methods

func start_server():
	GameInfo.is_server = true
	multiplayer_peer.create_server(PORT,MAX_PLAYERS)
	multiplayer.multiplayer_peer = multiplayer_peer
	print("Started Server")
	GameInfo.peer_id = multiplayer_peer.get_unique_id()
	print(GameInfo.peer_id)
	multiplayer_peer.peer_connected.connect(
		func(new_peer_id):
			await get_tree().create_timer(1).timeout
			add_player_to_server(new_peer_id)
	)
	
	multiplayer_peer.peer_disconnected.connect(
		func(new_peer_id):
			await get_tree().create_timer(1).timeout
			remove_player_from_server(new_peer_id)
	)

# when the player connects to the server it will add their peer id to the list, and 
# sends an rpc to that player to let them know they are now connected

func add_player_to_server(peer_id):
	emit_signal("_server_started")
	print("Player has connected ",peer_id)
	connected_peer_ids.append(peer_id)
	rpc_id(peer_id,StringName("player_has_connected"),peer_id)


# currently only removes player from server, needs to be updated to remove player from
# the session too
func remove_player_from_server(peer_id):
	print("Player will be removed ",peer_id)
	for id in connected_peer_ids:
		if id == peer_id:
			connected_peer_ids.erase(id)
	for session in sessions:
		for p in session.players_info:
			if p[0] == peer_id:
				session.server_remove_player_from_session(peer_id)
	attempt_to_kill_session()
			

func attempt_to_kill_session():
	for session in sessions:
		if session.players_info.size() == 0:
			sessions.erase(session)
			session.queue_free()

# called when a player hosts a session
@rpc("any_peer")
func create_session(player_info:Array):
	var s:Session = session_scene.instantiate()
	s.sname = set_session_name()
	GameInfo.sroot.add_child(s)
	sessions.push_back(s)
	print("session ",str(s.name)," created on server by host player ",player_info[0])
	rpc_id(player_info[0],"connected_to_session",s.sname)
	s.add_player_to_session(player_info)
	

@rpc("any_peer")
func join_session(player_info:Array,session_name):
	for session in sessions:
		if session.sname == session_name:
			print("session ",str(session.sname)," has been joined by player ",player_info[0])
			rpc_id(player_info[0],"connected_to_session",session.sname)
			session.add_player_to_session(player_info)
			

##	
## helper functions, misc
##

func set_session_name() ->String:
	randomize()
	var dig1 = randi()%9+1
	var dig2 = randi()%9+1
	var dig3 = randi()%9+1
	var dig4 = randi()%9+1
	var code = str(str(dig1)+str(dig2)+str(dig3)+str(dig4))
	return code

##
## dupe functions for client
##

@rpc("call_remote")
func player_has_connected(_peer_id):
	pass

#@rpc("call_remote")
#func player_get_info(_peer_id):
#	pass

@rpc("call_remote")
func connected_to_session(_session_info:Array):
	pass
