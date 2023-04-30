class_name Player extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var sussy = false

@onready var animtree = $anims/AnimationTree

var network_authority = false

enum PlayerState {
	IDLE,
	MOVING,
	INTERACTING,
	DEAD}

@export var player_state = PlayerState.IDLE

@onready var bodymeshes = [%head,%body]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#for multiplayer, allows us to figure out if the player is local or not
func _enter_tree():
	get_node("player_synchronizer").set_multiplayer_authority(str(name).to_int())
	pass

func _ready():
	network_authority = get_node("player_synchronizer").is_multiplayer_authority()
	if name == str(GameInfo.peer_id):
		%Camera3D.current = true
	else:
		%Camera3D.current = false
	handle_name_label()
	
	if str(GameInfo.sroot.get_child(0).host_id) == name and %Camera3D.current:
		GameInfo.sroot.get_child(0).hosting()

func _process(_delta):
	move_and_slide()
	%camera_pos.position = position
	%name_pos.position = position

func _physics_process(delta):
	handle_state()
	if not network_authority:
		return
		
	handle_locations()
	handle_movement(delta)

func handle_name_label():
	var players = GameInfo.sroot.get_child(0).players_info
	for player in players:
		if str(player[0]) == str(name):
			%name_label.text = player[1]

func handle_locations():
	#print($RayCast3D.get_collider().get_parent().name)
	match $floorcast.get_collider().get_parent().name:
		"church_main_building":
			%location.text = "Church"
		"hotel_main_bldg":
			%location.text = "Hotel"
		"train_station":
			%location.text = "Train Station"
		"saloon_main":
			%location.text = "Saloon"
		"water tower":
			%location.text = "Water Tower"
		"graveyard":
			%location.text = "Graveyard"
		"bank_main":
			%location.text = "Bank"
		"store_main":
			%location.text = "Store"
		"MeshInstance3D":
			%location.text = ""

func handle_movement(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if velocity != Vector3.ZERO:
		player_state = PlayerState.MOVING
	else:
		player_state = PlayerState.IDLE
	
	if not transform.origin == transform.origin + velocity:
		%charmesh.look_at(transform.origin + -velocity, Vector3.UP)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward").rotated(-deg_to_rad(45))
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func handle_state():
	if player_state == PlayerState.IDLE:
		animtree["parameters/playback"].travel("idle")
	elif player_state == PlayerState.MOVING:
		animtree["parameters/playback"].travel("jog")

func set_skin(val):
	match val:
		1:
			var skin = preload("res://characters/player/materials/skin1/skin1.tres")
			var hat = preload("res://characters/player/materials/skin1/hat1.tres")
			for x in bodymeshes:
				x.material_override = skin
			%cowboyhat.material_override = hat
		2:
			var skin = preload("res://characters/player/materials/skin2/skin2.tres")
			var hat = preload("res://characters/player/materials/skin2/hat2.tres")
			for x in bodymeshes:
				x.material_override = skin
			%cowboyhat.material_override = hat
		3:
			var skin = preload("res://characters/player/materials/skin3/skin3.tres")
			var hat = preload("res://characters/player/materials/skin3/hat3.tres")
			for x in bodymeshes:
				x.material_override = skin
			%cowboyhat.material_override = hat
		4:
			var skin = preload("res://characters/player/materials/skin4/skin4.tres")
			var hat = preload("res://characters/player/materials/skin4/hat4.tres")
			for x in bodymeshes:
				x.material_override = skin
			%cowboyhat.material_override = hat
		5:
			var skin = preload("res://characters/player/materials/skin5/skin5.tres")
			var hat = preload("res://characters/player/materials/skin5/hat5.tres")
			for x in bodymeshes:
				x.material_override = skin
			%cowboyhat.material_override = hat
		6:
			var skin = preload("res://characters/player/materials/skin6/skin6.tres")
			var hat = preload("res://characters/player/materials/skin6/hat6.tres")
			for x in bodymeshes:
				x.material_override = skin
			%cowboyhat.material_override = hat
		7:
			var skin = preload("res://characters/player/materials/skin7/skin7.tres")
			var hat = preload("res://characters/player/materials/skin7/hat7.tres")
			for x in bodymeshes:
				x.material_override = skin
			%cowboyhat.material_override = hat
		8:
			var skin = preload("res://characters/player/materials/skin8/skin8.tres")
			var hat = preload("res://characters/player/materials/skin8/hat8.tres")
			for x in bodymeshes:
				x.material_override = skin
			%cowboyhat.material_override = hat

func highlight(val:bool):
	var _highlight = preload("res://characters/player/materials/kill_highlight/kill_highlight.tres")
	if val:
		for x in bodymeshes:
			x.material_overlay = _highlight
			%cowboyhat.material_overlay = _highlight
	else:
		for x in bodymeshes:
			x.material_overlay = null
			%cowboyhat.material_overlay = null

func _on_area_3d_area_entered(area):
	var sus = GameInfo.sroot.get_child(0).sussy
	#print(area.get_parent().name)
	var baka = false
	if area.get_parent().name == str(GameInfo.peer_id):
		baka = true
	if area.get_parent().is_in_group("player") and sus and not baka:
		area.get_parent().highlight(true)

func _on_area_3d_area_exited(area):
	var sus = GameInfo.sroot.get_child(0).sussy
	#print(area.get_parent().name)
	var baka = false
	if area.get_parent().name == str(GameInfo.peer_id):
		baka = true
	if area.get_parent().is_in_group("player") and sus and not baka:
		area.get_parent().highlight(false)
