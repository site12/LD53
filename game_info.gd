extends Node

var player_name:String = "Outlaw Jones"
var peer_id:int = -1
var server_address:String = "127.0.0.1"
var is_server = false
var connected_to_server = false
var connected_to_session = false

@onready var nroot = get_tree().get_root().get_node("/root/game_root/network_root")
@onready var uiroot = get_tree().get_root().get_node("/root/game_root/ui_root")
@onready var sroot = get_tree().get_root().get_node("/root/game_root/session_root")

var session:Session

func _ready():
	if !load_player_name():
		save_player_name("Outlaw Jones") 
	if !load_server_address():
		save_server_address("127.0.0.1")

func get_player_name()->String:
	return player_name

func save_player_name(pname:String):
	player_name = pname
	var cfg = ConfigFile.new()
	cfg.set_value("local_player","player_name",player_name)
	cfg.set_value("local_player","server_address",server_address)
	cfg.save("user://config.cfg")

func load_player_name() -> bool:
	var cfg = ConfigFile.new()
	
	var err = cfg.load("user://config.cfg")
	
	if err!= OK:
		return false
	
	for player in cfg.get_sections():
		var pname = cfg.get_value(player,"player_name")
		player_name = pname
	return true

func get_server_address()->String:
	return server_address

func save_server_address(address:String):
	server_address = address
	var cfg = ConfigFile.new()
	cfg.set_value("local_player","player_name",player_name)
	cfg.set_value("local_player","server_address",server_address)
	cfg.save("user://config.cfg")

func load_server_address() -> bool:
	var cfg = ConfigFile.new()
	
	var err = cfg.load("user://config.cfg")
	
	if err!= OK:
		return false
	
	for player in cfg.get_sections():
		var address = cfg.get_value(player,"server_address")
		server_address = address
	return true

func get_player_info()->Array:
	var arr = [peer_id,player_name]
	return arr
