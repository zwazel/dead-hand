extends Button

func _on_ExitGame_pressed():
	get_tree().quit()

func _on_ExitGameButton_button_down():
	$ButtonClickSound.play()
