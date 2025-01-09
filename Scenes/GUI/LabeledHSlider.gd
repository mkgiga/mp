@tool

class_name LabeledHSlider extends VBoxContainer

@export var _text: String = ""
@export var _value: float = 0

@export var min_value: float = 0
@export var max_value: float = 1

@onready var slider: HSlider = $"HSlider"
@onready var display_label: Label = $"Display Label"
@onready var value_label: Label = $"Value Label"

@onready var value: float:
	get(): 
		return slider.value
	set(val): 
		slider.value = val

func _ready():
	slider.value = _value
	display_label.text = _text
	slider.max_value = max_value
	slider.min_value = min_value
	
	slider.step = calculate_step()
	
func calculate_step():
	return slider.max_value / 100
	
func _process(dt: float):
	value_label.text = str(slider.value)
