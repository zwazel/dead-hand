extends Node

var player

func set_player(p):
	player = p
	
func _on_Area_pickUp():
	player.has_flashlight = true
	player.add_flashlight()
	queue_free()
