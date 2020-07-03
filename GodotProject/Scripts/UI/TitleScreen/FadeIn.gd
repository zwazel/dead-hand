extends ColorRect

signal fade_finished # create a signal, so we can tell other scenes that the animation has finished

func fade_in():
	$AnimationPlayer.play("fade_in")

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("fade_finished")
