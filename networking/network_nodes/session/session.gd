class_name Session extends Node

@export var sname = ""
@export var host_id = 0
var sussy = false
#player peer id, player name
@export var players_info = []

@export var peer_ids = []

@export var game_begun = false

var player_scene = preload("res://characters/player/player.tscn")

var players:Array = []

var winner_of_duel = -1

var tasks = [
	"Church - Pray",
	"Bank - Stamp Form",
	"Bar - Take a Shot",
	"Bar - Clean Table",
	"Hotel - Sign Guestbook",
	"Hotel - Stoke Fire",
	"General Store - Wash Produce",
	"General Store - Empty Cash Register",
	"Water Tower - Plug Leak",
	"Train Station - Prepare Station for Arrival",
	"Graveyard - Pay Respects"
]

var local_tasks = []

@export var num_tasks = 5
@export var completed_tasks = 0

func _ready():
	%duelcam.current = false
	self.name = sname
	%session_synchronizer.set_visibility_for(1,true)
	await get_tree().create_timer(5).timeout
	

func _process(_delta):
	
	if game_begun:
		%progress_t.value = completed_tasks
		%progress_m.value = completed_tasks
		
	
	for x in %players.get_children():
		var id:int = x.name.to_int()
		if peer_ids.find(id) == -1:
			players.erase(x)
			x.queue_free()
			

func add_player_to_session(player_info:Array):
	if game_begun:
		return
	%session_synchronizer.set_visibility_for(player_info[0],true)
	if players_info.size() == 0:
		host_id = player_info[0]
		players_info.push_back(player_info)
		peer_ids.push_back(player_info[0])
	else:
		players_info.push_back(player_info)
		peer_ids.push_back(player_info[0])
		
	
	await get_tree().create_timer(1).timeout
	server_spawn_player(player_info)
	
	
	
@rpc("any_peer")
func server_start_game():
	start_game()
	randomize()
	var amogus = randi_range(0,players_info.size()-1)
	
	num_tasks = (%players.get_child_count()-1)*5
	%progress_t.max_value = num_tasks
	%progress_m.max_value = num_tasks
	
	#print(amogus)
	var p = 0
	for player in players_info:
		rpc_id(player[0],"client_start_game")
		if amogus == p:
			rpc_id(player[0],"assign_role",true)
		else:
			rpc_id(player[0],"assign_role",false)
			rpc_id(player[0],"assign_tasks",player[0],5)
		
		p +=1

@rpc
func assign_tasks(peer_id,_num_tasks):
	if str(peer_id) == str(GameInfo.peer_id):
		randomize()
		var list = tasks
		list.shuffle()
		local_tasks.resize(_num_tasks)
		var text = "TASK LIST: \n"
		for x in _num_tasks:
			local_tasks[x] = list[x]
			text += local_tasks[x] +"\n"
		%task_list.text = text

func update_task_list():
	%task_list.text = ""
	var text = "TASK LIST: \n"
	#print(local_tasks)
	for x in local_tasks.size():
		text += local_tasks[x] +"\n"
	%task_list.text = text

@rpc("any_peer")
func server_kill_player(peer_id):
	#print("attempting to kill player with ID "+str(peer_id))
	for x in players:
		if x.name == str(peer_id) and x.dead == false:
			#print("killing player with ID "+str(peer_id))
			x.dead = true

			for z in players:
				z.rpc_id(z.name.to_int(),"death",peer_id.to_int())

@rpc
func assign_role(is_sus):
	if is_sus:
		%monster.visible = true
		%pre_game.visible = false
		sussy = true
		%AnimationPlayer.play("fade_assign_monster")
	else:
		%townsfolk.visible = true
		%pre_game.visible = false
		%AnimationPlayer.play("fade_assign_townsfolk")
	

func hosting():
	%host_controls.visible = true
	%room_code.text = "Room Code: "+str(name)

func update_location(location:String):
	%location_t.text = location
	%location_m.text = location
@rpc
func client_start_game():
	start_game()

func start_game():
	game_begun = true
	%blocker1.queue_free()
	%blocker2.queue_free()
	populate_challenge_menu()
	

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
	#p.skin_num = skin_num
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

@rpc("any_peer")
func server_complete_task():
	completed_tasks +=1
	
	
func populate_challenge_menu():
	var p_button = preload("res://networking/network_nodes/session/p_button.tscn")
	for x in players_info:
		if x[0] != GameInfo.peer_id:
			var p = p_button.instantiate()
			p.name = str(x[0])
			p.text = x[1]
			p.connect("button_up",_challenge_player.bind(p.name.to_int()))
			get_node("%p_button_spot").add_child(p)


func _on_back_button_up():
	%challenge.visible = false
	%town.get_node("%sheriff").highlight(false)
	for x in players:
		if x.name.to_int() == GameInfo.peer_id:
			x.network_authority = true
	

func _challenge_player(_peer_id):
	var challenger = GameInfo.peer_id
	var accused = _peer_id
	
	rpc_id(1,"server_start_duel",challenger,accused)

@rpc("any_peer")
func server_start_duel(challenger,accused):
	winner_of_duel = -1
	for x in players_info:
		rpc_id(x[0],"client_start_duel",challenger,accused)
	await get_tree().create_timer(5).timeout
	for x in players_info:
		rpc_id(x[0],"advance_duel_1")
	await get_tree().create_timer(3).timeout
	for x in players_info:
		rpc_id(x[0],"advance_duel_2")
	await get_tree().create_timer(2).timeout
	for x in players_info:
		rpc_id(x[0],"advance_duel_3")
	await get_tree().create_timer(2).timeout
	for x in players_info:
		rpc_id(x[0],"advance_duel_4")
	await get_tree().create_timer(2).timeout
	for x in players_info:
		rpc_id(x[0],"advance_duel_5")
	
@rpc
func client_start_duel(challenger,accused):
	%duel_status.text = "Challenges"
	%duelcam.current = true
	%duel_viewports.visible = true
	%duel_ui.visible = true
	if challenger == GameInfo.peer_id:
		%challenger_ui.visible = true
	if accused == GameInfo.peer_id:
		%accused_ui.visible = true
		
	for x in players_info:
		if challenger == x[0]:
			%ch_label.text = x[1]
		if accused == x[0]:
			%ac_label.text = x[1]

@rpc
func advance_duel_1():
	%duel_status.text = "Get Ready!"
@rpc
func advance_duel_2():
	%duel_status.text = "3..."
@rpc
func advance_duel_3():
	%duel_status.text = "2..."
@rpc
func advance_duel_4():
	%duel_status.text = "1..."

@rpc
func advance_duel_5():
	%duel_status.text = "SHOOT!"
	%challenger_shoot.disabled = false
	%accused_shoot.disabled = false
	

@rpc("any_peer")
func server_receive_winner(winner):
	if winner_of_duel == -1:
		winner_of_duel = winner
		for x in players_info:
			rpc_id(x[0],"client_receive_winner",winner_of_duel)

@rpc
func client_receive_winner(winner):
	if %end.visible == false:
		%end.visible = true
	await get_tree().create_timer(2).timeout
	var winner_name = ""
	for x in players_info:
		if x[0] == winner:
			winner_name = x[1]
	%winner_status.text = winner_name + " has won the duel."

func end_game(_did_sussy_win):
	pass


func _on_challenger_shoot_button_up():
	%end.visible = true
	rpc_id(1,"server_receive_winner",GameInfo.peer_id)


func _on_accused_shoot_button_up():
	%end.visible = true
	rpc_id(1,"server_receive_winner",GameInfo.peer_id)
