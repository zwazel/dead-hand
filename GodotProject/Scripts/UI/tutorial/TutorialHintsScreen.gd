extends Control

var allHints = []
var currentHint
var currentTaskComplete = false
var ready = false
var canCallRemoveHint = true

func _ready():
	for hints in get_children(): # get all the hints
		if hints.name != "Timer":
			allHints.append(hints) # add all the hints to the array
	currentHint = allHints.front()

func getNewHint():
	currentHint = allHints.front()
	canCallRemoveHint = true
	currentHint.visible = true
	Global.getNewHint = false
	allHints.remove(0) # remove the first one

func removeHint(withNewHint = true):
	if currentHint:
		currentHint.get_child(0).didTutorial(withNewHint) # play the animation

func _process(delta):
	if Global.getNewHint:
		getNewHint()
	
	# check if task is completed
	if currentHint:
		match currentHint.name:
			"OpenCapsuleHint":
				Global.playerCanOpenCapsule = true
			
			"FlashlightHint":
				Global.realPlayerCanInteract = true
				
				if Global.playerTookFlashlight:
					if canCallRemoveHint:
						removeHint()
						canCallRemoveHint = false
			
			"OpenBigDoorHint":
				Global.playerCanOpenbigDoor = true
				
				if Global.playerOpenedBigDoor:
					if canCallRemoveHint:
						print("Called remove hint in playerOpenedBigDoor")
						removeHint(false)
						canCallRemoveHint = false
			
			"DefeatTheRobotHint":
				pass

func _input(event):
	if currentHint:
		match currentHint.name:
			"LookAroundHint":
				if ready:
					if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: # if the mouse is moving
						if canCallRemoveHint:
							removeHint()
							canCallRemoveHint = false

			"OpenCapsuleHint":
				if Global.playerCanOpenCapsule:
					if event.is_action_pressed("interacting"):
						if canCallRemoveHint:
							removeHint()
							canCallRemoveHint = false

			"MoveHint":
				if Global.playerCanMove:
					if canCallRemoveHint:
						removeHint()
						canCallRemoveHint = false

			"CrouchHint":
				if event.is_action_pressed("crouch"):
					if canCallRemoveHint:
						removeHint()
						canCallRemoveHint = false

			"SprintHint":
				if event.is_action_pressed("sprint"):
					if canCallRemoveHint:
						removeHint()
						canCallRemoveHint = false

func _on_Timer_timeout():
	ready = true
	$Timer.queue_free()

func getDefeatRobotHint():
	getNewHint()
