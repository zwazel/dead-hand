extends KinematicBody

onready var head = $HeadPos/Head
onready var interactRay = $HeadPos/Head/Interact
onready var blinkTimer = $BlinkTimer
export(float) var blinkOpenTime = 3
export(float) var blinkClosedTime = 0.3
var blinkState = "Open" # Open = can see, Closed = blink

func _process(delta):
	# interacting
	if Global.playerCanOpenCapsule:
		if Input.is_action_just_pressed("interacting"): # if the interacting button is pressed
			if interactRay.is_colliding(): # check if the ray is colliding
				var coll = interactRay.get_collider() # save the colliding object in a temp var
				if coll.has_method("interact"): # if coll has a method called "interact"
					coll.interact() # call the method
	# ----------------------------------

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_x(deg2rad(event.relative.y * Global.GLOBAL_MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * Global.GLOBAL_MOUSE_SENSITIVITY * -1))
		
		var camera_rot = head.rotation_degrees
		var self_rot = self.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70) # clamp the camera rotation
		self_rot.y = clamp(self_rot.y, -120, 120)
		head.rotation_degrees = camera_rot
		self.rotation_degrees = self_rot

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name: # match the animation name
		"CutScene": # if the name is CutScene
			if blinkState == "Open": # if the blink state is Open
				blinkTimer.wait_time = blinkOpenTime # set wait time of the timer
				blinkTimer.start() # start the timer

func _on_BlinkTimer_timeout(): # when the timer reaches 0
	if Global.blinking:
		if blinkState == "Open": # if state is open
			blinkTimer.wait_time = blinkClosedTime # set wait time
			blinkTimer.start() # start timer
			$AnimationPlayer.play("blink") # play blink animation
			blinkState = "Closed" # set blink state to closed
		elif blinkState == "Closed": # if blink state is closed
			blinkTimer.wait_time = blinkOpenTime # set wait time
			blinkTimer.start() # start timer
			$AnimationPlayer.play_backwards("blink") # play blink animation backwards
			blinkState = "Open" # set state to open
