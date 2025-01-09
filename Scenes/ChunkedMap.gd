class_name ChunkedMap extends Node3D

@onready var chunks_node: Node3D = $Chunks

const TILE_SIZE = Global.TILE_SIZE
const CHUNK_SIZE = Global.CHUNK_SIZE

var chunks_data: Dictionary = {}

var preloaded_scene: PackedScene = preload("res://Scenes/ClientChunk.tscn")

func update_chunks(data):
	var chunks = data.chunks
	
	for x in chunks:
		var col = chunks.get(x)
		
		for y in col:
			var chunk = col.get(y).mesh
			
			if chunks_data.get(x) == null:
				chunks_data[x] = {}
				
			if chunks_data.get(x).get(y) == null:
				chunks_data.get(x)[y] = {}
			
			## DESERIALIZE THE DATA INTO A NON-SCHIZO FORMAT
			
			var heights = chunk.get("heights")
			var colors = chunk.get("colors")
			
			# This code causes the function to (return?) early.
			# It does not execute the code in either the if or else blocks.
			if not chunks_data.get(x).get(y).get("heights"):
				var filled = []
				for i in CHUNK_SIZE * CHUNK_SIZE:
					filled.push_back(0)
					
				chunks_data.get(x).get(y).heights = filled
			
			if heights:
				var deserialized = []
				
				for i in range(0, len(heights)):
					deserialized.push_back(int(heights[i]))
				
				chunks_data.get(x).get(y).heights = deserialized
			
			if not chunks_data.get(x).get(y).get("colors"):
				var filled = []
				for i in CHUNK_SIZE * CHUNK_SIZE:
					filled.push_back(Color(0,0,0))
					
				chunks_data.get(x).get(y).colors = filled
			
			if colors:
				var deserialized = []
				
				for i in range(0, len(colors), 3):
					var r = int(colors[i])
					var g = int(colors[i+1])
					var b = int(colors[i+2])
					deserialized.push_back(Color(r, g, b))
				
				chunks_data.get(x).get(y).colors = deserialized
			
			var client_chunk: ClientChunk = preloaded_scene.instantiate()
			var client_chunk_name = String(str(x) + "_" + str(y))
			# This is how we know the location of a chunk in the map.
			client_chunk.name = client_chunk_name
			
			# Update the data variables of the chunk node so it knows how to render itself.
			client_chunk.set_data(
				self,
				chunks_data.get(x).get(y).get("heights"),
				chunks_data.get(x).get(y).get("colors")
			)
			
			# Save node in the data dict.
			chunks_data.get(x).get(y).node = client_chunk
	
	# Smooth the terrain vertices by interpolating it with its neighbors
	for x in chunks_data:
		var col = chunks_data.get(x)
		for y in col:
			var chunk_data = col.get(y)
			var client_chunk: ClientChunk = chunk_data.get("node")
			
			client_chunk.presmooth_terrain()
	
	# Now render the chunks, one by one.
	for x in chunks_data:
		var col = chunks_data.get(x)
		for y in col:
			var chunk_data = col.get(y)
			var client_chunk: ClientChunk = chunk_data.get("node")
			
			client_chunk.rerender()
			
			# Does this chunk already exist as a child of this node?
			var target_child = Nodes.find_first(
				chunks_node,
				func(val): return val.name == client_chunk.name
			)
			
			# Replace existing child (if it exists)
			if target_child:
				target_child.replace_by(client_chunk)
			else:
				chunks_node.add_child(client_chunk)

func get_chunk_at(x: int, y: int):
	return $Chunks.get_node_or_null(str(x) + "_" + str(y))
	
func get_chunk_data_at(x: int, y: int):
	var target_node_name = str(str(x) + "_" + str(y))
	var col = chunks_data.get(str(x))
	
	if not col:
		return null
		
	var chunk_data = col.get(str(y))
	
	if not chunk_data:
		return null
	
	return chunk_data
		
	
