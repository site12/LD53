class_name Task extends Node

var h_mat = preload("res://characters/player/materials/kill_highlight/task_highlight.tres")

enum TaskType {
	BUTTON,
	WAIT}

@export var task_type:TaskType

enum TaskCategories {
	CHURCH,
	BANK,
	SALOON,
	HOTEL,
	STORE,
	WATER_TOWER,
	TRAIN_STATION,
	GRAVEYARD}

@export var task_category:TaskCategories

enum TaskList {
	PRAY,
	STAMP_FORM,
	CLEAN_FORMS,
	TAKE_SHOT,
	CLEAN_BARTABLE,
	SIGN_GUESTBOOK,
	STOKE_FIRE,
	WASH_PRODUCE,
	EMPTY_REGISTER,
	PLUG_LEAK,
	PREPARE_STATION,
	F_TO_RESPECT
}

@export var task_activity:TaskList

@export var wait_time_sec:int = 5

var interacting_player

func highlight(val):
	if val:
		%mesh.material_overlay = h_mat
	elif !val:
		%mesh.material_overlay = null

func interact(player):
	%clayer.layer = 2
	interacting_player = player
	if task_type == 1:
		%wait.visible = true


func _on_begin_button_up():
	%begin.visible = false
	%progress.visible = true
	%progress.max_value = wait_time_sec
	for x in wait_time_sec:
		%progress.value = x
		await get_tree().create_timer(1).timeout
	%progress.value = %progress.max_value
	await get_tree().create_timer(1).timeout
	%wait.visible = false
	interacting_player.network_authority = true
	highlight(false)
	%task.queue_free()
	%clayer.layer = -1
	GameInfo.sroot.get_child(0).rpc_id(1,"server_complete_task")
