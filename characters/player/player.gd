class_name Player extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var animtree = $anims/AnimationTree

var network_authority = false

enum PlayerState {
	IDLE,
	MOVING,
	INTERACTING,
	DEAD
}

@export var player_state = PlayerState.IDLE

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

func _process(_delta):
	move_and_slide()
	%camera_pos.position = position

func _physics_process(delta):
	handle_state()
	if not network_authority:
		return
	handle_movement(delta)
	

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
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
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


