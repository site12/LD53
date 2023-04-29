extends Control



func _ready():
	%server_address.text = GameInfo.get_server_address()

func _on_server_address_text_changed(new_text):
	GameInfo.save_server_address(new_text)



func _on_run_as_server_button_up():
	GameInfo.nroot.network_type = 0
	GameInfo.nroot.initialize_networking()
	get_parent().visible = false


func _on_button_pressed():
	GameInfo.nroot.initialize_networking()
	%screen.visible = false
	%connecting.visible = true
	await get_tree().create_timer(1).timeout
	GameInfo.nroot.client.connect("_connected",_connected)
	

func _connected():
	visible = false
	get_parent().get_node("main_menu").visible = true
	
