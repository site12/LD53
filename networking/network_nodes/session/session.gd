class_name Session extends Node

@export var sname = ""
@export var host_id = 0
var sussy = false
#player peer id, player name
@export var players_info = []

var player_scene = preload("res://characters/player/player.tscn")

var players:Array = []

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
		
	
	await get_tree().create_timer(1).timeout
	server_spawn_player(player_info)
	
@rpc("any_peer")
func server_start_game():
	start_game()
	randomize()
	var amogus = randi_range(0,players_info.size()-1)
	#print(amogus)
	var p = 0
	for player in players_info:
		rpc_id(player[0],"client_start_game")
		if amogus == p:
			rpc_id(player[0],"assign_role",true)
		else:
			rpc_id(player[0],"assign_role",false)
		
		p +=1

@rpc
func assign_role(is_sus):
	if is_sus:
		%monster.visible = true
		%pre_game.visible = false
		sussy = true
	else:
		%townsfolk.visible = true
		%pre_game.visible = false
	%AnimationPlayer.play("fade_assign")

func hosting():
	%host_controls.visible = true
	%room_code.text = "Room Code: "+str(name)


@rpc
func client_start_game():
	start_game()

func start_game():
	%blocker1.queue_free()
	%blocker2.queue_free()

func server_spawn_player(player_info):
	spawn_player(player_info)
	for player in players_info:
		rpc_id(player[0],"client_spawn_player",player_info)
		pass

@rpc
func client_spawn_player(player_info):
	#await get_tree().create_timer(1).timeout
	#var num_players = players_info.size()
	#print(num_players)
	if not GameInfo.peer_id == host_id:
		for x in players_info:
			spawn_player(x)
	spawn_player(player_info)

func spawn_player(player_info):
	var p = player_scene.instantiate()
	p.name = str(player_info[0])
	%players.add_child(p,true)
	players.append(p)
	
	for player in players:
		player.get_node("%player_synchronizer").set_visibility_for(1,true)
		for x in players_info:
			player.get_node("%player_synchronizer").set_visibility_for(x[0],true)
	

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



func _on_help_open_button_up():
	%help.visible = true


func _on_help_close_button_up():
	%help.visible = false


func _on_begin_game_button_up():
	rpc_id(1,"server_start_game")
