extends Node

#constants denoting the server address and port
const PORT:int = 44555

# multiplayerpeer object
var multiplayer_peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new() 

signal _connected
signal _connected_to_session

# a reference to the session scene
var session_scene = preload("res://networking/network_nodes/session/session.tscn")

# a reference to the info for our session
var connected_session_info = null
# onready nodes

##
## client functionality
##

# starts the client and connects them to the server
func start_client():
#	pass
	multiplayer_peer.create_client(GameInfo.server_address,PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	GameInfo.peer_id = multiplayer_peer.get_unique_id()
	print("started client ",GameInfo.peer_id)
#when the player connects it emits the connected signal
@rpc
func player_has_connected(_peer_id):
	emit_signal("_connected")

@rpc
func connected_to_session(sname):
	#await get_tree().create_timer(1).timeout
	var s:Session = session_scene.instantiate()
	s.sname = sname
	GameInfo.sroot.add_child(s)
	GameInfo.session = s
	emit_signal("_connected_to_session")
	pass

##
## dupe for server
##

@rpc
func create_session(_peer_id):
	pass

@rpc
func join_session(_peer_id,_session_name):
	pass

#these methods don't do anything yet because the multiplayerspawner handles this
func add_player_to_server(_peer_id):
	pass

#these methods don't do anything yet because the multiplayerspawner handles this
func remove_player_from_server(_peer_id):
	pass
