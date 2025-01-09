extends Node

var highlight_material_path = "res://terrain_shader_mat.tres"  # Path to your terrain material

@onready var highlight_radius: LabeledHSlider = Global.map_editor_brush_size
@onready var highlight_spread: LabeledHSlider = Global.map_editor_brush_spread
@onready var highlight_feather: LabeledHSlider = Global.map_editor_brush_feather
@onready var highlight_opacity: LabeledHSlider = Global.map_editor_brush_opacity

# Has the 'cast_ray' method, which returns a dictionary.
@onready var camera: CinematicCamera3D = Global.camera

var brush_radius:
	get():
		return highlight_radius.value

var brush_spread:
	get():
		return highlight_spread.value

var brush_feather:
	get():
		return highlight_feather.value

var brush_opacity:
	get():
		return highlight_opacity.value

var last_mouse_pos: Vector2  # Store the last mouse position

func _ready():
	# Initialize last_mouse_pos
	last_mouse_pos = get_viewport().get_mouse_position()

func _process(dt: float):
	var mouse_pos = get_viewport().get_mouse_position()

	# Raycast only once per frame
	var raycast_result = camera.cast_ray()

	if raycast_result:
		var intersection_point = raycast_result.position

		# Update shader parameters if the mouse has moved
		if mouse_pos != last_mouse_pos:
			last_mouse_pos = mouse_pos
			update_shader_parameters(intersection_point)  # Pass intersection_point directly

		if Input.is_action_pressed("LMB"):
			# Use the same intersection_point for terrain editing
			var normal = raycast_result.normal
			var affected_chunks = get_affected_chunks(intersection_point)
			for chunk in affected_chunks:
				chunk.elevate_at(intersection_point, brush_radius, brush_opacity * dt * 10)

# No need for raycast inside this function anymore
func update_shader_parameters(intersection_point: Vector3):
	for chunk in get_nearby_chunks(intersection_point, brush_radius * 2):
		var chunk_mesh = chunk.find_child("Terrain")
		
		if chunk_mesh:
			chunk_mesh.mesh.surface_set_material(0, chunk_mesh.mesh.surface_get_material(0))
		
			if not chunk_mesh.get_surface_override_material(0):
				chunk.rerender()
			var mat = chunk_mesh.get_surface_override_material(0)
			if mat:
				print("Setting shader params for chunk: ", chunk.name)
				mat.set_shader_parameter("highlight_center", to_local(chunk_mesh, intersection_point))
				mat.set_shader_parameter("highlight_radius", brush_radius)
				mat.set_shader_parameter("highlight_color", Color(1, 0, 0, 0.5))

# Helper function to find chunks affected by the brush
func get_affected_chunks(intersection_point: Vector3) -> Array:
	var affected_chunks = []
	var chunk_size_world = (Global.CHUNK_SIZE - 1) * Global.TILE_SIZE

	# Calculate the range of chunk coordinates affected
	var min_chunk_x = floori((intersection_point.x - brush_radius) / chunk_size_world)
	var max_chunk_x = floori((intersection_point.x + brush_radius) / chunk_size_world)
	var min_chunk_y = floori((intersection_point.z - brush_radius) / chunk_size_world)
	var max_chunk_y = floori((intersection_point.z + brush_radius) / chunk_size_world)

	for x in range(min_chunk_x, max_chunk_x + 1):
		for y in range(min_chunk_y, max_chunk_y + 1):
			var chunk = get_parent().get_chunk_at(x, y)  # Assuming ChunkedMap has a get_chunk_at() method
			if chunk:
				affected_chunks.append(chunk)

	return affected_chunks

func get_nearby_chunks(intersection_point: Vector3, radius: float) -> Array:
	print("Intersection Point: ", intersection_point)
	print("Brush Radius: ", radius)
	var nearby_chunks = []
	var chunk_size_world = (Global.CHUNK_SIZE - 1) * Global.TILE_SIZE

	# Calculate the range of chunk coordinates within the radius
	var min_chunk_x = floori((intersection_point.x - radius) / chunk_size_world)
	var max_chunk_x = floori((intersection_point.x + radius) / chunk_size_world)
	var min_chunk_y = floori((intersection_point.z - radius) / chunk_size_world)
	var max_chunk_y = floori((intersection_point.z + radius) / chunk_size_world)

	print("Calculated Chunk Ranges: ", min_chunk_x, max_chunk_x, min_chunk_y, max_chunk_y)

	for x in range(min_chunk_x, max_chunk_x + 1):  # Add +1 to include the max chunk
		for y in range(min_chunk_y, max_chunk_y + 1):  # Add +1 to include the max chunk
			var chunk = get_parent().get_chunk_at(x, y)
			print("Checking Chunk At: ", x, y, chunk)  # Print chunk details
			if chunk:
				nearby_chunks.append(chunk)

	print("Nearby Chunks Found: ", nearby_chunks.size())
	return nearby_chunks
func to_local(node: Node3D, global_position: Vector3) -> Vector3:
	return node.global_transform.affine_inverse() * global_position
