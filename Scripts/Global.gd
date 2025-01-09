extends Node

const CHUNK_SIZE = 17
const TILE_SIZE = 1

@onready var client: NetworkClient = get_node("/root/Game").find_child("NetworkClient")
@onready var map_editor_brushes = get_node("/root/Game/UI/Control/MapEditor/PanelContainer2/Brush Options Panel/Map Editor Brushes")

# Map Editor Controls
@onready var map_editor_brush_size: LabeledHSlider = map_editor_brushes.get_node("Map Brush Size")
@onready var map_editor_brush_feather: LabeledHSlider = map_editor_brushes.get_node("Map Brush Feather")
@onready var map_editor_brush_opacity: LabeledHSlider =  map_editor_brushes.get_node("Map Brush Opacity")
@onready var map_editor_brush_spread: LabeledHSlider =  map_editor_brushes.get_node("Map Brush Spread")

@onready var camera: CinematicCamera3D = get_node("/root/Game").find_child("CinematicCamera3D")

const Editor: Dictionary = {
	"map": {
		"enabled": true
	},
	"item": {
		"enabled": false
	},
	"character": {
		"enabled": false
	}
}
