class_name Player extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var sussy = false

@export var dead = false

@export var skin_num = 0

@onready var animtree = $anims/AnimationTree

var network_authority = false

enum PlayerState {
	IDLE,
	MOVING,
	INTERACTING,
	DEAD}

@export var player_state = PlayerState.IDLE

@onready var bodymeshes = [%head,%body]

var overlapped_object = null
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
	
	GameInfo.uiroot.get_node("%loading").visible = false
	
	if str(GameInfo.sroot.get_child(0).host_id) == name and %Camera3D.current:
		GameInfo.sroot.get_child(0).hosting()
	randomize()
	set_skin(randi_range(0,GameInfo.sroot.get_child(0).players_info.size()))
	#await get_tree().create_timer(5).timeout
	#death()

func _process(_delta):
	move_and_slide()
	%camera_pos.position = position
	%name_pos.position = position
	
	#if not dead and player_state == PlayerState.DEAD:
		#dead = true
		#death()

func _physics_process(delta):
	handle_state()
	if not network_authority:
		return
		
	handle_locations()
	handle_movement(delta)

func _unhandled_input(event):
	handle_interactions(event)

func handle_name_label():
	var players = GameInfo.sroot.get_child(0).players_info
	for player in players:
		if str(player[0]) == str(name):
			%name_label.text = player[1]

func handle_locations():
	#print($RayCast3D.get_collider().get_parent().name)
	var sesh = GameInfo.sroot.get_child(0)
	match $floorcast.get_collider().get_parent().name:
		"church_main_building":
			sesh.update_location("Church")
		"hotel_main_bldg":
			sesh.update_location("Hotel")
		"train_station":
			sesh.update_location("Train Station")
		"saloon_main":
			sesh.update_location("Saloon")
		"water tower":
			sesh.update_location("Water Tower")
		"graveyard":
			sesh.update_location("Graveyard")
		"bank_main":
			sesh.update_location("Bank")
		"store_main":
			sesh.update_location("General Store")
		"MeshInstance3D":
			sesh.update_location("")

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

@rpc
func death(peer_id):
	var dead_body = preload("res://characters/dead_body.tscn")
	if peer_id == GameInfo.peer_id:
		#print("killing player locally")
		
		#network_authority = false
		var ded = preload("res://characters/player/materials/kill_highlight/ded.tres")
		for y in bodymeshes:
			y.material_overlay = ded
		get_node("%cowboyhat").material_overlay = ded
		var sesh = GameInfo.sroot.get_child(0)
		var body = dead_body.instantiate()
		sesh.add_child(body)
		body.global_position = global_position
	else:
		var sesh = GameInfo.sroot.get_child(0)
		for x in sesh.players:
			if x.name.to_int() == peer_id:
				x.get_node("%charmesh").visible = false
				x.get_node("%name_label").visible = false
				var body = dead_body.instantiate()
				sesh.add_child(body)
				body.global_position = x.global_position
	
	
	

func _on_area_3d_area_entered(area):
	if not network_authority:
		return
	var sus = GameInfo.sroot.get_child(0).sussy
	
	## highlight players
	var baka = false
	if area.get_parent().name == str(GameInfo.peer_id):
		baka = true
	
	if area.get_parent().is_in_group("player") and sus and not baka:
		overlapped_object = area.get_parent()
		overlapped_object.highlight(true)
		
	##highlight tasks
	#print(area.get_parent().name)
	if area.get_parent().is_in_group("task") and not sus:
		var tasks = GameInfo.sroot.get_child(0).local_tasks
		for x in tasks:
			if area.get_parent().name == x:
				overlapped_object = area.get_parent()
				overlapped_object.highlight(true)
				
	if area.get_parent().is_in_group("sheriff") and not dead:
		overlapped_object = area.get_parent()
		overlapped_object.highlight(true)

func _on_area_3d_area_exited(area):
	if not network_authority:
		return
	var sus = GameInfo.sroot.get_child(0).sussy
	
	var baka = false
	if area.get_parent().name == str(GameInfo.peer_id):
		baka = true
	if area.get_parent().is_in_group("player") and sus and not baka:
		area.get_parent().highlight(false)
	
	if area.get_parent().is_in_group("task") and not sus:
		area.get_parent().highlight(false)
	
	if area.get_parent().is_in_group("sheriff") and not dead:
		area.get_parent().highlight(false)
	
	overlapped_object = null

func handle_interactions(_event):
	sussy = GameInfo.sroot.get_child(0).sussy
	if Input.is_action_pressed("interaction") and overlapped_object != null:
		if overlapped_object.is_in_group("player") and sussy and !overlapped_object.dead:
			GameInfo.sroot.get_child(0).rpc_id(1,"server_kill_player",overlapped_object.name)
		elif not sussy:
			overlapped_object.interact(self)
			network_authority = false
		if overlapped_object.is_in_group("sheriff") and not dead:
			overlapped_object.interact(self)
			network_authority = false
