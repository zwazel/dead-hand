extends Label

var willGetNewHint

func didTutorial(getNewHint):
	willGetNewHint = getNewHint
	$ProgressBar.visible = true
	$AnimationPlayer.play("closeHint")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"closeHint":
			if willGetNewHint:
				Global.getNewHint = true
			queue_free()
