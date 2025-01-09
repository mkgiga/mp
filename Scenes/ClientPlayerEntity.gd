class_name ClientPlayerEntity extends Node3D

func _ready():
	pass

func move_to(chunk_x: int, chunk_y: int, x: int, y: int):
	emit_signal("move_to", chunk_x, chunk_y, x, y)
