class_name Session extends Node

@export var sname = ""
@export var host_id = 0
@export var players_info = []

var player_scene = preload("res://characters/player/player.tscn")

var players:Array[Player] = []

func _ready():
	self.name = sname
	%session_synchronizer.set_visibility_for(1,true)

func add_player_to_session(player_info:Array):
	%session_synchronizer.set_visibility_for(player_info[0],true)
	if players_info.size() == 0:
		host_id = player_info[0]
		players_info.push_back(player_info)
	else:
		players_info.push_back(player_info)
	
	spawn_player(player_info)


func spawn_player(player_info):
	var p = player_scene.instantiate()
	p.name = str(player_info[0])
	await get_tree().create_timer(1).timeout
	%players.add_child(p,true)
	players.append(p)
	p.get_node("%player_synchronizer").set_visibility_for(1,true)
	for x in players_info:
		p.get_node("%player_synchronizer").set_visibility_for(x[0],true)

func server_remove_player_from_session(peer_id):
	remove_player_from_session(peer_id)
	for player in players_info:
		rpc_id(player[0],"client_remove_player_from_session",peer_id)

@rpc
func client_remove_player_from_session(peer_id):
	remove_player_from_session(peer_id)

func remove_player_from_session(peer_id):
	for player_info in players_info:
		if player_info[0] == peer_id:
			players_info.erase(player_info)
	for player in players:
		if str(player.name) == str(peer_id):
			players.erase(player)
			player.queue_free()


func hide_ui():
	GameInfo.uiroot.get_node("main_menu").deactivate()
