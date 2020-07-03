extends Button

export(String) var scene_to_load

func _on_MenuButton_button_down():
	$ButtonClickSound.play()
