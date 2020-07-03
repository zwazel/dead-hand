extends Control

signal backButtonPressed

func _on_BackButton_pressed():
	emit_signal("backButtonPressed") # emit signal

func _on_BackButton_button_down():
	$ButtonClickSound.play() # play the click sound
