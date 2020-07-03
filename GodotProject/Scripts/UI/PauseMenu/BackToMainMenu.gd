extends Button

export(String) var scene_to_load
export(NodePath) var pauseScreen

func _ready():
	pauseScreen = get_node(pauseScreen)

func _on_BackToMainMenu_pressed():
	pauseScreen.unpause_game(2) # set the mouse mode to visible
	pauseScreen.change_scene(scene_to_load)

func _on_BackToMainMenu_button_down():
	$ButtonClickSound.play()
