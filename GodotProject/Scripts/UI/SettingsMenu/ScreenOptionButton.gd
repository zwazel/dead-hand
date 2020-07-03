extends OptionButton

func _on_WindowMode_item_selected(index):
	match index:
		0: # fullscreen
			OS.window_maximized = false
			OS.window_fullscreen = true
		
		1: # Windowed
			OS.window_fullscreen = false
			OS.window_maximized = true
