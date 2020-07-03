extends KinematicBody

onready var camera = $HeadHolder/HeadPos/Head/Camera
onready var head = $HeadHolder/HeadPos/Head
onready var bumpCheck = $HeadHolder/HeadBumpCheck
onready var shake_head_anim_player = $AnimationPlayers/StepsAnimation
onready var movement_anim_player = $AnimationPlayers/MovementAnim
onready var leaning_animation_player = $AnimationPlayers/LeaningAnimation
onready var third_person_animation_player = $AnimationPlayers/ThirdPersonAnimationPlayer
onready var interactRay = $HeadHolder/HeadPos/Head/Interacting
onready var hand = $HeadHolder/HeadPos/Head/Hand

var flashlight
var flashlightLight

# Movement
export(float) var GRAVITY = -20
export(int) var MAX_SPEED = 6
export(int) var MAX_CROUCH_SPEED = 3
export(int) var MAX_SPRINT_SPEED = 12
export(int) var JUMP_SPEED = 8
export(int) var ACCEL = 3
export(int) var CROUCH_ACCEL = 2
export(int) var SPRINT_ACCEL = 6
var is_sprinting = false
var dir = Vector3()
var vel = Vector3()
export(int) var DEACCEL = 10
export(float) var MAX_SLOPE_ANGLE = 40

# flashlight
export(bool) var has_flashlight = false

# breathing
var shouldBreathe = false

# crouching
var crouching = 1 # our current state, 1 = standing, 2 = standing up, -1 = crouching, -2 = going into crouch

# Camera "bobbing" animation
var walk_anim_state = false # false = left, true = right
export(float) var walk_speed_scale = 1 # how fast the animations are "scaled"
export(float) var run_speed_scale = 2
export(float) var crouch_speed_scale = 0.5

# lean
var leaning = 0 # 0 = normal, -1 = from left to normal, 1 = from right to normal
# -2 = from normal to left, 2 = from normal to right, -3 = left, 3 = right
# -4 = from left to right, 4 = from right to left

# third person (mostly just debugging)
var thirdPersonMode = 0 # 0 = normal / first person. 1 = going into thirdperson. 
# -1 = going into firstperson.  2 = thirdperson

# audio
onready var footStepsLibrary = $FootSteps

func _ready():
	if has_flashlight:
		var _flashlight = preload("res://Scenes/Probs/Interactable/Flashlight.tscn")
		flashlight = _flashlight.instance()
		hand.add_child(flashlight)
		
		var _flashlightlight = preload("res://Scenes/FlashLightLight.tscn")
		flashlightLight = _flashlightlight.instance()
		hand.add_child(flashlightLight)
		
		flashlight.visible = Global.flashlight_visible
		flashlightLight.visible = false
	else:
		pass
		
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	yield(get_tree(), "idle_frame");
	get_tree().call_group("robots", "set_player", self);
	get_tree().call_group("pickable", "set_player", self);

func _process(delta):
	if shouldBreathe:
		breathe()
	
	if flashlight and flashlightLight:
		# TODO! Don't check every frame if it changed. make it via signals, inside the global script.
		if flashlight.visible != Global.flashlight_visible:
			flashlight.visible = Global.flashlight_visible

func breathe():
	if !$Breathing/Breathing.playing:
		$Breathing/Breathing.play()

func _physics_process(delta):
	process_input()
	process_movement(delta)

func process_input():
	var cam_xform = camera.get_global_transform()
	# ----------------------------------
	# Walking
	dir = Vector3() # set dir to an empty Vector3, dir is our direction the player intends to move towards
	var input_movement_vector = Vector2()

	if Input.is_action_pressed("move_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("move_backwards"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("move_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()

	dir += -cam_xform.basis.z * input_movement_vector.y # Forwards/Backwards
	dir += cam_xform.basis.x * input_movement_vector.x # Left/Right
	# ----------------------------------

	# Jumping/Springen
	if is_on_floor(): # Check if we're on the floor, if we are, we can jump
		if Input.is_action_just_pressed("jump"):
			vel.y = JUMP_SPEED # Set the y axis of our vel(ocity) to jump_speed
	# ----------------------------------
	
	# Sprinting / Crouching
	if Input.is_action_pressed("sprint"): # if button is pressed
		# dont crouch and sprint
		is_sprinting = true # sprint
		
		if crouching < 0: # if we're crouching or going into crouch
			crouching = 2 # go into standing up
	else: # if button is not pressed
		is_sprinting = false # don't sprint
	
	if Input.is_action_just_pressed("crouch"):
		match crouching: # match crouching
			-1: # if we're already crouching, uncrouch
				crouching = 2 # uncrouch / stand up
			1: # if we're not crouching
				if !is_sprinting: # if we're not sprinting
					crouching = -2 # crouch
	# ----------------------------------
	
	# leaning left
	if Input.is_action_just_pressed("lean_left"):
		match leaning: # match leaning
			0: # we're in the mid / normal pos
				leaning = -2 # we're going from normal to left
			-2: # we're left
				leaning = -1 # we're going from left to normal
			-3: # we're left
				leaning = -1 # we're going from left to normal
			3: # if we're right
				leaning = 4 # go from right to left
	
	# leaning right
	if Input.is_action_just_pressed("lean_right"):
		match leaning:
			0: # we're in normal pos
				leaning = 2 # we're going from normal to right
			2: # we're right
				leaning = 1 # we're going from right to normal
			3: # we're right
				leaning = 1 # we're going from right to normal
			-3: # if we're left
				leaning = -4 # go from left to right
	# ----------------------------------
	
	# Third person mode
	if Input.is_action_just_pressed("thirdperson"):
		match thirdPersonMode:
			0: # we're in firstpersonmode
				thirdPersonMode = 1 # go into thirdperson mode
			2: # we're in thirdperson mode
				thirdPersonMode = -1 # go into firstperson mode
	# ----------------------------------
	
	# flashlight
	if flashlightLight:
		if Input.is_action_just_pressed("flashlight"): # if button is pressed
			flashlightLight.visible = not flashlightLight.visible # turn flashlight on/off
			$FlashlightToggle/FlashlightToggle.play() # make sound
	# ----------------------------------
	
	# interacting
	if Global.realPlayerCanInteract:
		if Input.is_action_just_pressed("interacting"): # if the interacting button is pressed
			if interactRay.is_colliding(): # check if the ray is colliding
				var coll = interactRay.get_collider() # save the colliding object in a temp var
				if coll.has_method("interact"): # if coll has a method called "interact"
					coll.interact() # call the method
		# ----------------------------------

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()
	vel.y += delta * GRAVITY # apply gravity
	var hvel = vel # horizontal velocity (horizontal because y is 0)
	hvel.y = 0
	var target = dir

	if is_sprinting: # sprint speed
		target *= MAX_SPRINT_SPEED
	elif crouching < 0: # crouch speed
		if !Global.player_invisible:
				Global.previous_player_sound_mode = Global.player_sound_mode
				Global.player_sound_mode = Global.PLAYER_SOUND_MODES.CROUCHING
		target *= MAX_CROUCH_SPEED
	else: # normal / Walk speed
		target *= MAX_SPEED

	var accel # schlussendliche beschleunigung
	if dir.dot(hvel) > 0: # check if we're moving on the x and z axis (y is 0)
		Global.playerCanMove = true
		if is_sprinting: # if we're moving and sprinting
			if $Breathing/startBreathingTimer.time_left <= 0:
				$Breathing/startBreathingTimer.start()
			if !Global.player_invisible:
				Global.previous_player_sound_mode = Global.player_sound_mode
				Global.player_sound_mode = Global.PLAYER_SOUND_MODES.SPRINTING
			accel = SPRINT_ACCEL # set accel to our sprint accel
			if is_on_floor(): # if we're on the floor (so not jumping) move the head / Need to replace with a jump animation
				shake_head(run_speed_scale) # shake head with the run speed modifier
		elif crouching < 0: # if we're crouching
			$Breathing/startBreathingTimer.stop()
			accel = CROUCH_ACCEL # crouch accel
			if is_on_floor():
				shake_head(crouch_speed_scale) # shake head with the crouch speed modifier
		else: # if we're not sprinting or crouching
			$Breathing/startBreathingTimer.stop()
			if !Global.player_invisible:
				Global.previous_player_sound_mode = Global.player_sound_mode
				Global.player_sound_mode = Global.PLAYER_SOUND_MODES.WALKING
			accel = ACCEL # normal/walk accel
			if is_on_floor():
				shake_head(walk_speed_scale) # shake head with the walk speed modifier
	else: # if we're not moving, start deaccalerating
		$Breathing/startBreathingTimer.stop()
		if !Global.player_invisible:
			if crouching > 0:
				Global.previous_player_sound_mode = Global.player_sound_mode
				Global.player_sound_mode = Global.PLAYER_SOUND_MODES.STANDING
		accel = DEACCEL # slow down

	hvel = hvel.linear_interpolate(target, accel * delta) # interpolate the horizontal velocity
	vel.x = hvel.x # set the velocity to the interpolated horizontal velocity
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE)) # move
	# deg2rad = degrees converted to radians
	# ----------------------------------
	
	# Leaning
	if leaning != 0 or leaning != -3 or leaning != 3: # if we want to move/lean
		lean(leaning)
	# ----------------------------------
	
	# crouching
	if crouching == -2 or crouching == 2: # only call the function when we want to go into crouch / standing up
		crouch(crouching)
	# ----------------------------------
	
	# thirdperson mode
	if thirdPersonMode == 1 or thirdPersonMode == -1: # if we want to change mode
		thirdPerson(thirdPersonMode) # change mode
	# ----------------------------------
	
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_x(deg2rad(event.relative.y * Global.GLOBAL_MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * Global.GLOBAL_MOUSE_SENSITIVITY * -1))
		
		var camera_rot = head.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70) # clamp the camera rotation
		head.rotation_degrees = camera_rot

func shake_head(speed): # get the speed_scale for the animations
	if thirdPersonMode == 0:
		if !shake_head_anim_player.is_playing(): # if we're not already playing a animation
			if !walk_anim_state: # left step
				if !footStepsLibrary.get_node("FootStep1").playing: # if not already playing audio
					footStepsLibrary.get_node("FootStep1").play() # play footstep sound
				shake_head_anim_player.set_speed_scale(speed) # set animation speed scale
				shake_head_anim_player.play("left_step") # play animation
				walk_anim_state = true # make ready for right step
			elif walk_anim_state: # right step
				if !footStepsLibrary.get_node("FootStep2").playing: # if not already playing audio
					footStepsLibrary.get_node("FootStep2").play() # play footstep sound
				shake_head_anim_player.set_speed_scale(speed) # set animation speed scale
				shake_head_anim_player.play("right_step") # play animation
				walk_anim_state = false # make ready for left step
	else:
		shake_head_anim_player.stop(true)

func crouch(state):
	# crouching
	if bumpCheck.is_colliding() and state == 2: # if we're colliding with something (example wall)
		movement_anim_player.stop(false) # pause the animation
		return # exit the function
	if !movement_anim_player.is_playing(): # if not already playing an animation
		if state == -2: # we want to crouch
			movement_anim_player.play("crouching") # play crouch animation
		elif state == 2: # we want to crouch
			movement_anim_player.play_backwards("crouching") # play crouch animation backwards

func lean(state):
	if !leaning_animation_player.is_playing():
		match state: # match state
			1: # from right to normal
				leaning_animation_player.play_backwards("leaning_right") # play animation
			2: # from normal to right
				leaning_animation_player.play("leaning_right") # play animation
			-1: # from left to normal
				leaning_animation_player.play_backwards("leaning_left") # play animation
			-2: # from normal to left
				leaning_animation_player.play("leaning_left") # play animation
			
			# left to right / right to left
			-4:
				leaning_animation_player.play("left_to_right")
			4:
				leaning_animation_player.play_backwards("left_to_right")

func thirdPerson(state):
	if !third_person_animation_player.is_playing():
		match state: # match state
			1: # if we're going into thirdperson
				third_person_animation_player.play("move_head_back") # play animation
			-1: # if we're going into firstperson
				third_person_animation_player.play_backwards("move_head_back") # play animation


# Animation finished signals
func _on_MovementAnim_animation_finished(anim_name):
	match anim_name: # match the anim name
		"crouching": # crouch animation finished
			if crouching == -2: # if we're going into crouch
				crouching = -1 # we have reached crouch
			elif crouching == 2: # if we're standing up
				crouching = 1 # we've reached standing up

func _on_ThirdPersonAnimationPlayer_animation_finished(anim_name):
	match anim_name: # match the anim name
		"move_head_back": # move_head_back animation finished
			match thirdPersonMode: # match thirdpersonmode
				1: # if we're going into thirdperson
					thirdPersonMode = 2 # we have reached thirdperson
				-1: # if we're going into firstperson
					thirdPersonMode = 0 # we have reached firstperson

func _on_LeaningAnimation_animation_finished(anim_name):
	match anim_name: # match the anim name
		"leaning_left": # leaning_left animation finished
			if leaning == -2: # if we're going from normal to left
				leaning = -3 # we have reached left
			elif leaning == -1: # if we're going from left to normal
				leaning = 0 # we have reached normal
		"leaning_right": # leaning_right animation finished
			if leaning == 2: # if we're going from normal to right
				leaning = 3 # we have reached right
			elif leaning == 1: # if we're going from right to normal
				leaning = 0 # we have reached normal
		"left_to_right": # left_to_right animation finished
			if leaning == -4: # if we're going from left to right
				leaning = 3 # we have reached right
			elif leaning == 4: # if we're going from right to left
				leaning = -3 # we have reached left

func add_flashlight():
	var _flashlight = preload("res://Scenes/Probs/Interactable/Flashlight.tscn")
	flashlight = _flashlight.instance()
	hand.add_child(flashlight)
	
	var _flashlightlight = preload("res://Scenes/FlashLightLight.tscn")
	flashlightLight = _flashlightlight.instance()
	hand.add_child(flashlightLight)
	
	flashlight.visible = Global.flashlight_visible
	flashlightLight.visible = false
	
	Global.playerTookFlashlight = true

func _on_startBreathingTimer_timeout():
	shouldBreathe = true

func _on_Breathing_finished():
	shouldBreathe = false
