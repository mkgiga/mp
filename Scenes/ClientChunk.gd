class_name ClientChunk extends StaticBody3D

var terrain: MeshInstance3D
var terrain_collision_shape: CollisionShape3D

var decals: Node3D
var ground_decals
var walls: Node3D

const CHUNK_SIZE = Global.CHUNK_SIZE # 17 (16 tiles, 17 vertices per row)
const TILE_SIZE = Global.TILE_SIZE # 1 distance between vertices (units)

var map: ChunkedMap

## Integer vertex heights (unsmoothed)
## This is populated by the parent ChunkedMap node
var data_heights = []

## Array[Color] (unsmoothed)
## This is populated by the parent ChunkedMap node
var data_colors = []

var smoothed_heights = []
var smoothed_colors = []

var terrain_shader_mat: ShaderMaterial = preload("res://terrain_shader_mat.tres")

## Rerender the chunk using the pre-smoothed heightmap and interpolated color map
func rerender():
	var map_coords = get_coords()
	
	self.position = Vector3(
		map_coords.x * (CHUNK_SIZE - 1) * TILE_SIZE,
		0,
		map_coords.y * (CHUNK_SIZE - 1) * TILE_SIZE,
	)
	
	# initialize child nodes
	if terrain == null:
		var mesh_instance = MeshInstance3D.new()
		self.add_child(mesh_instance)
		mesh_instance.name = "Terrain"
		terrain = mesh_instance
	else:
		print("Terrain already exists")
	
	var st: SurfaceTool = SurfaceTool.new()

	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for y in range(CHUNK_SIZE - 1):
		for x in range(CHUNK_SIZE - 1):
			# ... (calculate i, h, color, pos) ...

			# Define the two triangles that form the quad
			var indices = [
				xy_to_i(x, y),        # Top-left
				xy_to_i(x + 1, y),    # Top-right
				xy_to_i(x, y + 1),    # Bottom-left
				xy_to_i(x + 1, y + 1) # Bottom-right
			]

			# Triangle 1 (Top-left, Bottom-left, Top-right) - Original
			# st.set_color(smoothed_colors[indices[0]])
			# st.add_vertex(Vector3(x * TILE_SIZE, smoothed_heights[indices[0]], y * TILE_SIZE))

			# st.set_color(smoothed_colors[indices[2]])
			# st.add_vertex(Vector3(x * TILE_SIZE, smoothed_heights[indices[2]], (y + 1) * TILE_SIZE))

			# st.set_color(smoothed_colors[indices[1]])
			# st.add_vertex(Vector3((x + 1) * TILE_SIZE, smoothed_heights[indices[1]], y * TILE_SIZE))

			# Triangle 1 (Top-left, Top-right, Bottom-left) - Corrected (swap last two vertices)
			st.set_color(smoothed_colors[indices[0]])
			st.add_vertex(Vector3(x * TILE_SIZE, smoothed_heights[indices[0]], y * TILE_SIZE))

			st.set_color(smoothed_colors[indices[1]])
			st.add_vertex(Vector3((x + 1) * TILE_SIZE, smoothed_heights[indices[1]], y * TILE_SIZE))

			st.set_color(smoothed_colors[indices[2]])
			st.add_vertex(Vector3(x * TILE_SIZE, smoothed_heights[indices[2]], (y + 1) * TILE_SIZE))

			# Triangle 2 (Top-right, Bottom-left, Bottom-right) - Original
			# st.set_color(smoothed_colors[indices[1]])
			# st.add_vertex(Vector3((x + 1) * TILE_SIZE, smoothed_heights[indices[1]], y * TILE_SIZE))

			# st.set_color(smoothed_colors[indices[2]])
			# st.add_vertex(Vector3(x * TILE_SIZE, smoothed_heights[indices[2]], (y + 1) * TILE_SIZE))

			# st.set_color(smoothed_colors[indices[3]])
			# st.add_vertex(Vector3((x + 1) * TILE_SIZE, smoothed_heights[indices[3]], (y + 1) * TILE_SIZE))

			# Triangle 2 (Top-right, Bottom-right, Bottom-left) - Corrected (swap last two vertices)
			st.set_color(smoothed_colors[indices[1]])
			st.add_vertex(Vector3((x + 1) * TILE_SIZE, smoothed_heights[indices[1]], y * TILE_SIZE))

			st.set_color(smoothed_colors[indices[3]])
			st.add_vertex(Vector3((x + 1) * TILE_SIZE, smoothed_heights[indices[3]], (y + 1) * TILE_SIZE))

			st.set_color(smoothed_colors[indices[2]])
			st.add_vertex(Vector3(x * TILE_SIZE, smoothed_heights[indices[2]], (y + 1) * TILE_SIZE))
	
	st.generate_normals()
	
	var material = StandardMaterial3D.new()
	
	material.albedo_color = Color(1, 1, 1)  # Set to white
	material.metallic = 0.0
	material.roughness = 1.0
	
	st.set_material(material)
	
	# Commit the mesh
	var mesh = st.commit()
	
	print("Number of surfaces in mesh: ", mesh.get_surface_count())
	
	# Update the terrain mesh with the new data
	terrain.mesh = mesh
	
	terrain.set_surface_override_material(0, terrain_shader_mat)
	
	# Collision Shape (only create once, and only update if necessary)
	if terrain_collision_shape == null:
		terrain_collision_shape = CollisionShape3D.new()
		add_child(terrain_collision_shape)
		terrain_collision_shape.name = "TerrainCollisionShape"

	var concave_trimesh = mesh.create_trimesh_shape()
	terrain_collision_shape.shape = concave_trimesh

## Set the data of the data dict. Null values may be entered.
func set_data(map: ChunkedMap, heights = null, colors = null):
	
	self.map = map
	
	if typeof(heights) == TYPE_ARRAY:
		data_heights = heights
		smoothed_heights = Array(data_heights)
		
	if typeof(colors) == TYPE_ARRAY:
		data_colors = colors
		smoothed_colors = Array(data_colors)
		
	
## When this is called, all the relevant data arrays have been assigned.
func presmooth_terrain():
	smoothed_heights = Array(data_heights)
	var unsmoothed_heights = data_heights

	for i in range(len(data_heights)):
		var sum_heights = 0.0
		var count = 0

		var coords = i_to_xy(i)
		var _x = coords.x
		var _y = coords.y

		# Iterate through the 8 neighbors and self
		for nx in range(_x - 1, _x + 2):
			for ny in range(_y - 1, _y + 2):
				var nh = get_height_relative(nx, ny)
				if nh != null:
					sum_heights += nh
					count += 1

		# Average the height
		smoothed_heights[i] = sum_heights / count
	
 	# Check for invalid values in smoothed_heights
	for h in smoothed_heights:
		if not is_finite(h):  # Check for NaN or Infinity
			print("Error: Invalid height value found in smoothed_heights: ", h)
			
## Returns the height at relative coordinates, or null if no chunk exists there.
## 0,0 returns the height at 0,0
## -1,0 returns the height at 17,0 at its left neighbor.
## -1,-1 returns the height at 17,17 at its top-left neighbor
## ...etc
func get_height_relative(x: int = 0, y: int = 0):
	
	# Determine the target chunk coordinates
	var my_chunk_coords = get_coords()
	
	var target_chunk_x = my_chunk_coords.x + (x / CHUNK_SIZE)
	var target_chunk_y = my_chunk_coords.y + (y / CHUNK_SIZE)

	# Calculate local coordinates within the chunk
	var target_chunk_local_x = x % CHUNK_SIZE
	var target_chunk_local_y = y % CHUNK_SIZE

	# Get the target chunk data from the nested dictionary
	var relative_chunk_data = self.map.get_chunk_data_at(target_chunk_x, target_chunk_y)
	if relative_chunk_data == null:
		return null

	# Return the height from the target chunk's data
	var target_index = xy_to_i(target_chunk_local_x, target_chunk_local_y)
	return relative_chunk_data["heights"][target_index]

## Convert 2D coordinates to the index in a flattened array. (1, 2) -> 18
func xy_to_i(x, y):
	return floori(y * CHUNK_SIZE + x)
	
## Convert the index of a flattened array to 2D coordinates. 18 -> (1, 2)
func i_to_xy(i):
	var x: int = i % CHUNK_SIZE
	var y: int = floori(i / CHUNK_SIZE)
	return Vector2(x, y)

## Returns the coordinates of this chunk.
func get_coords() -> Vector2:
	var xy = self.name.split("_")
	return Vector2(int(xy[0]), int(xy[1]))

## Returns a dict of { heights: Array[int], colors: Array[Color], node: ClientChunk, smoothed_heights: Array[float] }
func get_chunk_data_at(x: int, y: int):
	return self.map.get_chunk_data_at(x, y)

## Raise or lower terrain at a position (height can be positive or negative)
## Raise or lower terrain at a position (height can be positive or negative)
func elevate_at(world_pos: Vector3, radius: float, height_delta: float):
	var chunk_origin = position # World position of the chunk's origin (0,0)
	var brush_feather = Global.map_editor_brush_feather.value
	
	print("Elevating at", world_pos, ", with radius: ", radius, ", height delta: ", height_delta)
	
	for i in range(data_heights.size()):
		var vertex_pos_local = Vector3(i_to_xy(i).x * TILE_SIZE, 0, i_to_xy(i).y * TILE_SIZE)
		var vertex_pos_world = chunk_origin + vertex_pos_local

		var dist = world_pos.distance_to(vertex_pos_world)

		if dist < radius:
			# Apply height change based on distance and brush feather
			var influence = 1.0 - (dist / radius) # Linear falloff for simplicity
			influence = pow(influence, brush_feather)  # You can adjust this for different falloff curves

			# Modify the data_heights array
			data_heights[i] += height_delta * influence
			data_heights[i] = clamp(data_heights[i], 0, 50) # prevent the heightmap from going under 0 or over 50

	# Smooth and rerender after modifying data_heights
	presmooth_terrain()
	rerender()
