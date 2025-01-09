class_name CinematicCamera3D extends Camera3D

@export var initial_target: Node3D

## Targets to keep in the viewport
var targets: Dictionary = {}

## Height from the ground
var h: float = 20.0

@onready var player: ClientEntity = %"Player"

func _ready():
	targets[initial_target.get_instance_id()] = initial_target
	look_at(initial_target.global_position)

func _physics_process(delta: float) -> void:
	var sum_x = 0
	var sum_y = 0
	var sum_z = 0
	
	var i = 0
	
	for key in targets:
		var ent = targets.get(key)
		var vec = ent.global_position
		sum_x += vec.x
		sum_y += vec.y
		sum_z += vec.z
		i += 1
		
	var lin_x = sum_x / (i + 1)
	var lin_y = sum_y / (i + 1)
	var lin_z = sum_z / (i + 1)
	
	look_at(Vector3(lin_x, lin_y, lin_z))
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		var ray_result = cast_ray()
		if ray_result:
			var pos: Vector3 = ray_result.get("position")
			var body: PhysicsBody3D = ray_result.collider
		
			
func add_targets(entities: Array[Node3D]):
	for i in range(0, len(entities)):
		var ent = entities[i]
		targets[ent.get_instance_id()] = ent

func remove_targets(entities: Array[Node3D]):
	for i in range(0, len(entities)):
		var ent = entities[i]
		if (targets.get(ent.get_instance_id())):
			targets.erase(ent.get_instance_id())

func cast_ray() -> Dictionary:
	var camera = self
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_areas = false
	return space.intersect_ray(ray_query)
	
func get_closest_corner(at: Vector3) -> Vector3:
	var snapped_2d = snapped(Vector2(at.x, at.z), Vector2(Global.TILE_SIZE, Global.TILE_SIZE))
	return Vector3(snapped_2d.x, at.y, snapped_2d.y)
	
func place_vertex_marker(at: Vector3):
	pass
