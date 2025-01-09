extends Node

## Contains the `window` object in the browser.
@onready var window: JavaScriptObject = JavaScriptBridge.get_interface("window")
var console: JavaScriptObject

func _ready():
	if window != null:
		console = window.get("console")
