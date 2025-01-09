class_name Game extends Node3D

var printed = false

@onready var chunks = $"World/ChunkedMap/Chunks"

var pretty_print_stack = []

func pretty_print_tree(current: Node):
	# Recurse through the scene tree
	print_node(len(pretty_print_stack), current)

	for child in current.get_children():
		pretty_print_stack.append(current)
		pretty_print_tree(child)
		pretty_print_stack.pop_back()
		
func print_node(depth: int, node: Node):
	var prefix = ""

	if depth > 0:
		prefix = "".lpad((depth - 1) * 2, " ") + "- "

	var node_type = node.get_class()
	
	print(prefix + node.name + ": (" + node_type + ")")
