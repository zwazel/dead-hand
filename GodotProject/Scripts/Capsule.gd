extends Spatial

signal capsuleIsOpen
export(String, "Open", "Closed") var state = "Closed"

func _on_StaticBody_interact():
	if !$AnimationPlayer.is_playing():
		match state:
			"Open":
				$AnimationPlayer.play_backwards("kapselOpen")
				state = "Closed"
			
			"Closed":
				$AnimationPlayer.play("kapselOpen")
				state = "Open"

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name: # match the name of the finished animation
			"kapselOpen": # if the name of the animation is "kapselOpen"
				if !Global.cutscene_finished:
					if state == "Open": # if the capsule is open
						emit_signal("capsuleIsOpen") # emit signal
