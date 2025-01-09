class_name ClientEntity extends CharacterBody3D

## A brief description of the class's role and functionality.
## 
## The description of the script, what it can do,
## and any further detail.
## 
## @tutorial:             https://example.com/tutorial_1
## @tutorial(Tutorial 2): https://example.com/tutorial_2
## @experimental
## 

var identity: Dictionary = {
	"name": "Anonymous",
	"description": ""
}

var stats: Dictionary = {
	"hp": { "current": 100, "base": 100 },
	"mp": { "current": 100, "base": 100 }
}

var model_type: Types.Model = Types.Model.None
var model: Node3D = null

@onready var collider = $"CollisionShape3D"
@onready var mesh_instance = $"CollisionShape3D/MeshInstance3D"

@export var is_player: bool = false
@export var is_local_player: bool = false

@export_category("Appearance")
@export var entity_model: PackedScene

var model_scene

func _ready():
	pass

## Test
func set_stat_current(name: String, value: int) -> void:
	self.stats[name] = value

## Set the base stat value of the entity
func set_stat_base(name: String, value: int):
	self.stats[name] = value

func snap_to_ground():
	pass

func set_pos(x: int, y: int):
	pass
