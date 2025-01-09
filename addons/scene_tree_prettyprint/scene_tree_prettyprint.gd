@tool
extends EditorPlugin

var button

func _ready():
	# Create the button
	button = Button.new()
	button.text = "Print Scene Tree"
	button.connect("pressed", print_scene_tree)

	# Add the button to the toolbar using the correct method
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, button)
	

func _exit_tree():
	if is_instance_valid(button):
		button.get_parent().remove_child(button)
		button.queue_free()

func print_scene_tree():
	var stack = [get_node("/root")]
	
	# recurse through the scene tree of the project
