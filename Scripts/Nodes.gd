extends Node

func find_first(node: Node, predicate: Callable):
	for child in node.get_children():
		if predicate.call(child):
			return child
			
	return null
	
func find_all(node: Node, predicate: Callable) -> Array[Node]:
	var arr: Array[Node] = []
	for child in node.get_children():
		if predicate.call(child):
			arr.push_back(child)
	return arr
