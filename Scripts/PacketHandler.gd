class_name PacketHandler extends Node

@onready var node_chunks: ChunkedMap = get_node("/root/Game/World/ChunkedMap")
@onready var network_client: NetworkClient = %"NetworkClient"

func message(sender: String, text: String, timestamp: String):
	pass
	
func chunks(data):
	node_chunks.update_chunks(data)
	
func entities(entities: Variant):
	pass
	
