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

func highlight(val):
	if val:
		%mesh.material_overlay = h_mat
	elif !val:
		%mesh.material_overlay = null

func interact():
	pass
