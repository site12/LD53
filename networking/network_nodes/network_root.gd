class_name NetworkRoot extends Node

## functionality for switching between being a server and a client

##
## constants and variables
##

#choose whether its a server or not
enum NetworkType {SERVER,CLIENT}
@export var network_type = NetworkType.CLIENT

#references to server or client nodes
var servernode = preload("res://networking/network_nodes/server/network.tscn")
var clientnode = preload("res://networking/network_nodes/client/network.tscn")

var client = null
var server = null

##
## built-in functions
##

#instantiates the chosen network node and starts it
func initialize_networking():
	if get_child_count()>0:
		return
	if network_type == NetworkType.SERVER:
		var _server = servernode.instantiate()
		
		add_child(_server,true)
		_server.start_server()
		server = _server

	if network_type == NetworkType.CLIENT:
		var _client = clientnode.instantiate()
		add_child(_client,true)
		_client.start_client()
		client = _client

