extends Node3D

var h_mat = preload("res://characters/player/materials/kill_highlight/task_highlight.tres")


func highlight(val):
	if val:
		%mesh.material_overlay = h_mat
		%head.material_overlay = h_mat
		%cowboyhat.material_overlay = h_mat
	elif !val:
		%mesh.material_overlay = null
		%head.material_overlay = null
		%cowboyhat.material_overlay = null


func interact(_player):
	if _player.dead:
		return
	GameInfo.sroot.get_child(0).populate_challenge_menu()
	GameInfo.sroot.get_child(0).get_node("%challenge").visible = true
	
