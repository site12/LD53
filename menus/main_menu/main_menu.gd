extends MenuPanel


func _ready():
	%playername.text = GameInfo.get_player_name()
	%server_address.text = GameInfo.get_server_address()

func _on_playername_text_changed(new_text):
	GameInfo.save_player_name(new_text)



func _on_quit_button_up():
	get_tree().quit()

func _on_host_button_up():
	%connecting.visible = true
	GameInfo.nroot.initialize_networking()
	GameInfo.nroot.client.connect("_connected",connected_host)

func _on_join_button_up():
	%connecting.visible = true
	GameInfo.nroot.initialize_networking()
	GameInfo.nroot.client.connect("_connected",connected_client)


func _on_run_as_server_button_up():
	GameInfo.nroot.network_type = 0
	GameInfo.nroot.initialize_networking()
	visible = false

func connected_host():
	GameInfo.nroot.client.rpc_id(1,"create_session",GameInfo.get_player_info())
	visible = false
	
func connected_client():
	GameInfo.nroot.client.rpc_id(1,"join_session",GameInfo.get_player_info(),%roomcode.text)
	visible = false
