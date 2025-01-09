extends Node

## Merges two dictionaries, including any nested dictionaries.
## Overwrites dict a with dict b's values in the case of key collisions that aren't
## dictionaries. If [pre]overwrite[/pre] is set to [pre]false[/pre], dictionary a's keys take priority.
func deep_merge(a: Dictionary, b: Dictionary, overwrite: bool = true) -> Dictionary:
	var merged = {}
	
	for key in a:
		var a_val = a.get(key)
		var b_val = b.get(key)
		
		if b_val == null:
			merged[key] = a_val
		else:
			if b_val is Dictionary and a_val is Dictionary:
				merged[key] = deep_merge(a_val, b_val)
			else:
				if overwrite:
					merged[key] = b_val
				else:
					merged[key] = a_val
		
	return merged
