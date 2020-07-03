extends Spatial

signal activateRobotTutorialHint
signal activateRobot

func _ready():
	Global.inMenu = false
	Global.getNewHint = true
	Global.initTutorial = true

func _process(delta):
	if Global.skipTutorial:
		removeActivateRobotHint()

func _on_ActivateRobotTutorialHint_body_entered(body):
	if body.name == "Player":
		emit_signal("activateRobotTutorialHint", self)

func removeActivateRobotHint():
	if has_node("ActivateRobotTutorialHint"):
		$ActivateRobotTutorialHint.queue_free()

func _on_ActivateRobot_body_entered(body):
	if body.name == "Player":
		emit_signal("activateRobot")
		$ActivateRobot.queue_free()

func _on_ActivateCredits_body_entered(body):
	if body.name == "Player":
		$Credits.visible = true

func _on_ActivateCredits_body_exited(body):
	if body.name == "Player":
		$Credits.visible = false
