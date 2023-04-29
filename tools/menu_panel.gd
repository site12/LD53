class_name MenuPanel extends Control

@export var prev_menu: Control = null
@export var next_menu: Control = null
@export var back_enabled:bool = false

var active = false

func activate():
	self.active = true
	self.visible = true
	if back_enabled:
		$back_text.visible = true

func deactivate():
	self.active = false
	self.visible = false
	if back_enabled:
		$back_text.visible = false

func move_to_next_menu():
	if next_menu==null:
		return
	self.deactivate()
	next_menu.activate()
	print("moving to next menu ", next_menu.name)
	
func move_to_specified_menu(menu_panel):
	self.deactivate()
	menu_panel.activate()
	print("moving to next menu ", menu_panel.name)

func move_to_prev_menu():
	if prev_menu==null:
		return
	self.deactivate()
	prev_menu.activate()
	print("moving to prev menu ", prev_menu.name)


func _input(_event):
	if Input.is_action_pressed("ui_cancel") and active and back_enabled:
		await get_tree().create_timer(0.1).timeout
		move_to_prev_menu()
		#self.mouse_filter = Control.MOUSE_FILTER_IGNORE
