class_name NetworkClient extends Node

var client: SocketIOClient
var backendURL: String

@onready var game: Node3D = get_node("/root/Game")
@onready var packet_handler: PacketHandler = %"PacketHandler"

signal move_to(chunk_x: int, chunk_y: int, x: int, y: int)

func _ready():
	
	# prepare URL
	backendURL = "ws://127.0.0.1:3000/socket.io/"

	# initialize client
	client = SocketIOClient.new(backendURL);

	# this signal is emitted when the socket is ready to connect
	client.on_engine_connected.connect(on_socket_ready)

	# this signal is emitted when socketio server is connected
	client.on_connect.connect(on_socket_connect)

	# this signal is emitted when socketio server sends a message
	client.on_event.connect(on_socket_event)

	# add client to tree to start websocket
	add_child(client)
	
func _exit_tree():
	# optional: disconnect from socketio server
	client.socketio_disconnect()

func on_socket_ready(_sid: String):
	# connect to socketio server when engine.io connection is ready
	print("Socket ready")
	client.socketio_connect()
	

func on_socket_connect(_payload: Variant, _name_space, error: bool):
	if error:
		push_error("Failed to connect to backend!")
	else:
		print("Socket connected")

func on_socket_event(event_name: String, data: Variant, _name_space):
	match(event_name):
		"chunks":
			packet_handler.chunks(data)

func send_move_to(chunk_x: int, chunk_y: int, x: int, y: int):
	send("move_to", { "chx": chunk_x, "chy": chunk_y, "x": x, "y": y })

func send(event: String, data: Variant):
	client.socketio_send(event, data)
