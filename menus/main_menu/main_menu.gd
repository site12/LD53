extends MenuPanel


func _ready():
	%playername.text = GameInfo.get_player_name()

func _on_playername_text_changed(new_text):
	GameInfo.save_player_name(new_text)



func _on_quit_button_up():
	get_tree().quit()

func _on_host_button_up():
	GameInfo.nroot.client.rpc_id(1,"create_session",GameInfo.get_player_info())
	self.visible = false
	get_parent().get_node("%splash").visible = false

func _on_join_button_up():
	GameInfo.nroot.client.rpc_id(1,"join_session",GameInfo.get_player_info(),%roomcode.text)
	self.visible = false
	get_parent().get_node("%splash").visible = false
