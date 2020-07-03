extends KinematicBody

onready var visionRays = $HeadAnchor/VisionRayCasts
onready var attackRays = $HeadAnchor/AttackRayCasts
onready var interactRays = $HeadAnchor/InteractRayCasts
onready var headAnchor = $HeadAnchor
onready var animPlayer = $AnimationPlayer
onready var update_path_timer = $update_path
onready var sound_turning_off = $SFX/RobotPowerOff
onready var sound_turning_on = $SFX/RobotPowerOn
onready var soundLibrary = $SFX
onready var SoundTimer = $SoundCooldown
onready var interactingTimer = $InteractingTimer
onready var hearingRaycast = $Hearing

var player_visible = false # is the player visible?
var player_hearable = false # is the player.... "hearable"?
var player_in_attack_range = false # is the player in attack range?
var player = null # our player, is being set in func set_player

# pathfinding
var path = [] # the full path
var path_ind = 0 # what path node we're on
var path_created = false # used to control how often the path can be updated
var path_timer = 0 # used to control how often the path can be updated
export(int) var move_speed = 5 # move speed
export(NodePath) var nav # our navigation node
export(float) var min_path_distance_to_reach = 0.5

# turning
export(float) var rotation_speed = 3 # our rotation speed

# audio
var can_make_sound = true # used to control the sounds.

# hearing
export(Vector3) var crouch_hearing = Vector3(0,0,-5)
export(Vector3) var walking_hearing = Vector3(0,0,-15)
export(Vector3) var sprinting_hearing = Vector3(0,0,-30)

# vision
export(Vector3) var standing_view_distance = Vector3(0,0,15)
export(Vector3) var crouch_view_distance = Vector3(0,0,10)
export(Vector3) var walking_view_distance = Vector3(0,0,20)
export(Vector3) var sprinting_view_distance = Vector3(0,0,30)

# behaviour and STATES
enum STATES {
	LOOKING_AROUND, # look around
	WANDERING, # wander to random spots
	ALERTED, # the player has been detected
	ATTACKING, # the player is in range for an attack
	LOST_PLAYER, # the player was seen, now i've lost him. check last known spot
	POWERING_ON, # the robot is turning on
	POWERING_OFF, # the robot is turning off
	INTERACTING, # the robot tries to interact with something
	FOUND_PLAYER, # the robot found the player in hiding place
}
var state # our current state
var previous_state # our previous state
var previous_previous_state # our previous previous state
var created_static_path = false # check if we have created a path for the "lost_player" state

# state: lost_player
var last_known_player_pos = Vector3() # the last known position of the player. so we can check there

# state: looking_around
var look_state = false # false = left, true = right
var target_amount_looks # if we reach this amount, go to the "wandering" state
var amount_looks = 0 # track how many "looks" we've made
var created_target_amount_looks = false # we created the target amount of looks

# STATES powering on/off
export var powered_on = false # is the robot powered or not
var powering_finished = false # is the transition between powered and not powered finished?

# state: wandering
export(NodePath) var patrolPath # our path we have to follow
var patrol_points = [] # all of the points in the path
var patrol_index = 0 # our current patrol point

# state: interacting
var interactingPosition # the position we need to go so we can interact with the thing
var lookAtPosition # the position we need to look at
var interactingObject # the object we want to interact with
var can_interact = true # can we interact?
var is_in_interact_range = false # are we in the interacting area?

func _ready():
	randomize()
	add_to_group("robots") # add the robot to the group robots
	if powered_on:
		state = STATES.POWERING_ON # set our current state
	else:
		state = STATES.POWERING_OFF
	previous_state = state # set our previous state
	previous_previous_state = previous_state # set our previous previous state
	
	# wandering
	if patrolPath: # if we've set a patrolPath....
		patrol_points = get_node(patrolPath).get_children() # get all the points in the path
		#print("Patrol points size: " + str(patrol_points.size()))
	else: # if we haven't set a patrol path
		print("WARNING: No patrolPath set in " + str(name)) # print a warning
	
	if nav: # if we've set a navigation node....
		nav = get_node(nav) # get the node
	else: # if we haven't set a navigation node....
		print("WARNING: No nav set in " + str(name)) # print a warning

func _process(delta):
	if player: # if the player exists...
		if !Global.player_invisible: # if the player is not invisible
			check_vision() # check the "vision" rays.
			if !player_visible: # if the player is not visible, check if we can "hear" him
				check_hearing()
			else:
				hearingRaycast.visible = false
			if state == STATES.ALERTED or state == STATES.ATTACKING: # if we're in the alerted state or the attack state....
				check_attack_range() # check the attack raycasts
		elif Global.player_invisible: # if the player is invisible(debug), the enemy should not see him
			hearingRaycast.visible = false
			player_visible = false
			player_in_attack_range = false
			player_hearable = false
	
	if player_visible or player_hearable: # if the player IS visible...
		last_known_player_pos = player.get_translation() # update the last_known pos of the player
		
	match state: # depending on the state we're currently in, do thing
		STATES.LOOKING_AROUND: # if state == looking_around
			if !created_target_amount_looks: # if we haven't already created the target amount...
				amount_looks = 0 # reset the current amount of looks
				target_amount_looks = rand_range(2,4) # set the amount of looks
				target_amount_looks = round(target_amount_looks) # round the amount of looks to the nearest int
				created_target_amount_looks = true # est to true so we dont create a new amount
				#print("Target_Amount_Looks = " + str(target_amount_looks)) # print the amount
			looking_around(target_amount_looks) #look around until we reach the target amount of looks
		
		STATES.WANDERING: # if state is wandering
			# !!LOGIC IS MADE IN FUNC _PHYSICS_PROCESS!!
			pass
		
		STATES.ALERTED:
			pass
			# !!LOGIC IS MADE IN FUNC _PHYSICS_PROCES!!
		
		STATES.ATTACKING:
			attacking(delta) # run the state
		
		STATES.LOST_PLAYER:
			pass
			# !!LOGIC IS MADE IN FUNC _PHYSICS_PROCESS!!
		
		STATES.POWERING_ON:
			powering_on() # run the state
		
		STATES.POWERING_OFF:
			powering_off() # run the state
		
		STATES.INTERACTING:
			interacting(delta) # run the state
		
		STATES.FOUND_PLAYER:
			found_player()
	
	if state != STATES.LOOKING_AROUND: # if we are NOT in the "Looking_around" state...
		created_target_amount_looks = false # reset it so we are ready to go back in the look_around state
	if state != STATES.INTERACTING:
		can_interact = true

func _physics_process(delta):
	match state: # depending on what state we're in, do thing
		STATES.ALERTED: # if we're alerted....
			alerted(delta) # run the alerted function
		STATES.LOST_PLAYER: # if we lost the player....
			lost_player(delta) # run the lost player function
		STATES.WANDERING: # if we have looked around, wander around...
			wandering(delta) # run the wandering function

func check_hearing():
	hearingRaycast.visible = true
	match Global.player_sound_mode:
		Global.PLAYER_SOUND_MODES.STANDING:
			player_hearable = false
			hearingRaycast.visible = false
			return # exit the function
		
		Global.PLAYER_SOUND_MODES.CROUCHING:
			hearingRaycast.cast_to = crouch_hearing
		
		Global.PLAYER_SOUND_MODES.WALKING:
			hearingRaycast.cast_to = walking_hearing
		
		Global.PLAYER_SOUND_MODES.SPRINTING:
			hearingRaycast.cast_to = sprinting_hearing

	hearingRaycast.look_at(player.global_transform.origin,Vector3(0,1,0))
	
	if hearingRaycast.is_colliding():
		var coll = hearingRaycast.get_collider()
		if coll == player:
			player_hearable = true
			return
	player_hearable = false

func check_vision():
	for raycast in visionRays.get_children(): # get every raycast
		match Global.player_sound_mode:
			Global.PLAYER_SOUND_MODES.CROUCHING:
				raycast.cast_to = crouch_view_distance
			
			Global.PLAYER_SOUND_MODES.SPRINTING:
				raycast.cast_to = sprinting_view_distance
			
			Global.PLAYER_SOUND_MODES.WALKING:
				raycast.cast_to = walking_view_distance
			
			Global.PLAYER_SOUND_MODES.STANDING:
				raycast.cast_to = standing_view_distance
	
	for raycast in visionRays.get_children(): # get every raycast
		if raycast.is_colliding(): # check every raycast if they are colliding
			var coll = raycast.get_collider() # save our collider in a temp variable
			if coll == player: # check if the collider is our player
				player_visible = true # player is visible
				return # exit the whole function so we dont check the other raycasts
		player_visible = false # if none of the raycast has hit the player, set it to false
	
	if previous_state == STATES.LOST_PLAYER: # if we WERE in the state lost_player, and the player is not visible (because if he is, we would return)
		for raycast in interactRays.get_children(): # get every raycast
			if raycast.is_colliding(): # check every raycast if they are colliding
				var coll = raycast.get_collider() # save our collider in a temp variable
				if coll.is_in_group("hiding_places"): # check if the collider is in the group hiding_places
					interactingObject = coll.get_parent()
					interactingPosition = coll.find_node("OpeningPosition", true) # find the node named "OpeningPosition". true because it needs to be owned by "coll"
					lookAtPosition = coll.find_node("LookingPosition", true) # find the node named "LookingPosition". true because it needs to be owned by "coll"
					previous_state = state
					state = STATES.INTERACTING
					created_static_path = false
					return # exit the whole function so we dont check the other raycasts

func check_attack_range():
	for raycast in attackRays.get_children(): # get every raycast
		if raycast.is_colliding(): # check every raycast if they are colliding
			var coll = raycast.get_collider() # save our collider in a temp variable
			if coll == player: # check if the collider is our player
				player_in_attack_range = true # player is in attack_range
				return # exit the whole function so we dont check the other raycasts
	player_in_attack_range = false # if none of the raycast has hit the player, set it to false

func create_path(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_ind = 0
	#print("created path")

func set_player(p):
	player = p # set the player

# choose a random thing from an array
func choose(array): # take an array
	array.shuffle() # shuffle the array
	return array.front() # return the first value in the array

func turn_face(target, rotationSpeed, delta):
	var global_pos = global_transform.origin
	var wtransform = global_transform.looking_at(Vector3(target.x,global_pos.y,target.z),Vector3(0,1,0))
	var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), rotationSpeed*delta)

	global_transform = Transform(Basis(wrotation), global_transform.origin)

# State / Behaviour functions
func looking_around(target_looks):
	if player_hearable or player_visible: # if the player is visible...
		animPlayer.stop() # stop the animation.
		animPlayer.seek(0, true) # reset the position of the animation to 0. so the roboter actually looks at the player.
		previous_previous_state = previous_state # set our previous previous state
		previous_state = state
		state = STATES.ALERTED # set the state to alerted
	else: # if the player is not visible....
		if !animPlayer.is_playing(): # if no animation is playing...
			if amount_looks < target_looks: # if we HAVE NOT reached our target of looks....
				amount_looks += 1 # everytime a new animation starts, add 1
				#print("Amount_looks = " + str(amount_looks)) # print our current amount of looks
				if !look_state: # if look_state is false...
					animPlayer.play("looking_left") # play the looking_left animation
					look_state = true # set look_state to true
				elif look_state: # if look_state is true....
					animPlayer.play("looking_right") # play the looking_right animation
					look_state = false # set look_state to false
			else: # if we HAVE reached our target amount of looks....
				created_static_path = false # reset so we can create a new path to a new location
				previous_previous_state = previous_state # set our previous previous state
				previous_state = state
				state = STATES.WANDERING # change the state to wander

func alerted(delta):
	# pathfinding
	if player_visible or player_hearable: # if the player is visible
		if player_in_attack_range: # if the player is in attack range
			previous_previous_state = previous_state # set our previous previous state
			previous_state = state
			state = STATES.ATTACKING # change to the attack state
			return # exit the function
		
		var my_position = get_translation() # get the robots position
		var player_position = player.get_translation() # get the players position
		
		turn_face(player_position,rotation_speed, delta) # look at the player
		
		if !path_created: # if we can, create/update path
			update_path_timer.start() # start the timer. so we can update every x seconds our path
			create_path(player_position) # create/update path
			path_created = true # make sure that we dont immediatly create a new path
			
		if path_ind < path.size(): # if we havent reached our destination....
			var move_vec = (path[path_ind] - my_position) # get our direction from our current position to our next node.
			if move_vec.length() < min_path_distance_to_reach:
				path_ind += 1
			else:
				move_and_slide(move_vec.normalized() * move_speed, Vector3(0,1,0)) # move towards the player
				
	else: # the player is NOT visible...
		created_static_path = false # reset so we can create a new path to a new location
		previous_previous_state = previous_state # set our previous previous state
		previous_state = state
		state = STATES.LOST_PLAYER # set state to lost player, so we can move to the last known position

func lost_player(delta):
	if player_visible or player_hearable:
		previous_previous_state = previous_state # set our previous previous state
		previous_state = state
		state = STATES.ALERTED
	else: # if the player is not visible
		if previous_previous_state == STATES.FOUND_PLAYER:
			if is_in_interact_range:
				previous_previous_state = previous_state # set our previous previous state
				previous_state = state
				state = STATES.INTERACTING
				return
		var my_position = get_translation() # get the robots position
		var last_player_pos = last_known_player_pos # get the last known player position
		
		turn_face(last_player_pos, rotation_speed, delta) # look at the player's last known position
		
		if !created_static_path: # if we can, create/update path
			print("Created static Path in func lost_player()")
			create_path(last_player_pos) # create/update path
			created_static_path = true # make sure that we dont immediatly create a new path
			
		if path_ind < path.size(): # if we havent reached our destination....
			var move_vec = (path[path_ind] - my_position) # get our direction from our current position to our next node.
			if move_vec.length() < min_path_distance_to_reach:
				path_ind += 1
			else:
				move_and_slide(move_vec.normalized() * move_speed, Vector3(0,1,0)) # move towards the player
		else: # if we HAVE reached our destination...
			if is_in_interact_range:
				previous_previous_state = previous_state # set our previous previous state
				previous_state = state
				state = STATES.INTERACTING
				return
			previous_previous_state = previous_state # set our previous previous state
			previous_state = state
			state = STATES.LOOKING_AROUND # go back to looking around state

func wandering(delta):
	if player_visible or player_hearable: # if the player is visible...
		previous_previous_state = previous_state # set our previous previous state
		previous_state = state
		state = STATES.ALERTED # go back to the alerted state
	else: # if the player is NOT visible....
		if !patrolPath: # if we've NOT set a patrolPath
			print("returning in func wandering(); if !patrolPath")
			return # exit the function. so the game does not crash.
		var my_position = get_translation() # get the robots position
		
		# get the next/current pathPoint
		var target = patrol_points[patrol_index] # set our target to the current patrol index
		var targetPos = target.get_translation()
		if my_position.distance_to(targetPos) < 1: # if the distance from my position to the target is less then x.....
			patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size()) # go to the next point and wrap around, so if we reach the last point, go to the first point
			target = patrol_points[patrol_index] # set our target to the next patrol index
			created_static_path = false # create new path for the new point
			print("Reached target")
		
		turn_face(targetPos, rotation_speed, delta) # look at the target
		
		# pathfinding
		if !created_static_path: # if we can, create/update path
			print("Created static Path in func wandering()")
			create_path(targetPos) # create/update path
			created_static_path = true # make sure that we dont immediatly create a new path
			
		if path_ind < path.size(): # if we havent reached our destination....
			var move_vec = (path[path_ind] - my_position) # get our direction from our current position to our next node.
			if move_vec.length() < min_path_distance_to_reach:
				path_ind += 1
			else:
				move_and_slide(move_vec.normalized() * move_speed, Vector3(0,1,0)) # move towards the player
		else: # if we have reached our destination...
			previous_previous_state = previous_state # set our previous previous state
			previous_state = state
			state = STATES.LOOKING_AROUND

func attacking(delta):
	if player_in_attack_range: # if the player is in attack_range...
		var player_position = player.get_translation() # get the players position
		turn_face(player_position, rotation_speed, delta) # look at the player
		
		if can_make_sound:
			if !soundLibrary.get_node("RobotTerminate").playing: # check if we're already playing a sound
				soundLibrary.get_node("RobotTerminate").play() # play the sound
				
				start_sound_timer(2)
	elif player_visible or player_hearable: # if the player is NOT in attack runge, but is visible
		previous_previous_state = previous_state # set our previous previous state
		previous_state = state
		state = STATES.ALERTED # change state to alerted
	else: # if the player is NOT in attack_range and NOT visible
		previous_previous_state = previous_state # set our previous previous state
		previous_state = state
		state = STATES.LOST_PLAYER # change state to lost_player

func powering_on():
	if !powering_finished: # if our powering is NOT finished
		if can_make_sound: # if we CAN make sounds
			animPlayer.play_backwards("turning_off") # play the turning_off animation, but backwards.
			if !sound_turning_on.playing: # if we're NOT already playing a sound
				sound_turning_on.play() # play the sound
				start_sound_timer(2)
	else: # if our powering IS finished
		previous_previous_state = previous_state # set our previous previous state
		previous_state = state
		state = STATES.LOOKING_AROUND # change state back to looking around
	
func powering_off():
	if !powering_finished: # if our powering is NOT finished
		if can_make_sound: # if we CAN make sounds
			animPlayer.play("turning_off") # play the turning_off animation
			if !sound_turning_off.playing: # if we're NOT already playing a sound
				sound_turning_off.play() # play the sound
				start_sound_timer(3)

func interacting(delta): # if I want to interact with something
	if player_visible or player_hearable: # if the player is visible
		previous_previous_state = previous_state # set our previous previous state
		previous_state = state
		state = STATES.FOUND_PLAYER
		interactingTimer.stop() # stop and reset the timer
		can_interact = true # we can interact again
	else: # the player is not visible, proceed with interacting
		if interactingPosition and lookAtPosition:
			var my_position = get_translation() # get the robots position
			var walkTarget = interactingPosition.global_transform.origin # get the GLOBAL position (local position bad)
			var lookTarget = lookAtPosition.global_transform.origin # get the GLOBAL position (local position bad)
			
			turn_face(lookTarget, rotation_speed, delta) # look at the player's last known position
			
			if !created_static_path: # if we can, create/update path
				print("Created static Path in func interacting()")
				create_path(walkTarget) # create/update path
				created_static_path = true # make sure that we dont immediatly create a new path
				
			if path_ind < path.size(): # if we havent reached our destination....
				var move_vec = (path[path_ind] - my_position) # get our direction from our current position to our next node.
				if move_vec.length() < min_path_distance_to_reach:
					path_ind += 1
				else:
					move_and_slide(move_vec.normalized() * move_speed, Vector3(0,1,0)) # move towards the player
			else: # if we HAVE reached our destination...
				if can_interact:
					if !interactingObject.state:
						interactingObject.is_being_interacted(true)
					else:
						interactingTimer.start()
						can_interact = false
		else:
			print("Robot has no InteractingPosition and/or LookAtPosition")

#func interact(): # if something is interacting with me
#	if powering_finished: # if powering is finished (so we can't power on while it's still powering off)
#		powered_on = not powered_on # change the state
#		powering_finished = false # powering is not finished (it just started, duh)
#		can_make_sound = true
#		if powered_on: # if we're powered on
#			previous_previous_state = previous_state # set our previous previous state
#			previous_state = state
#			state = STATES.POWERING_ON # change state to powering_on
#		else: # else if we're NOT powered_on
#			previous_previous_state = previous_state # set our previous previous state
#			previous_state = state
#			state = STATES.POWERING_OFF # change state to powering_off

func found_player():
	if player_visible or player_hearable: # if the player is visible
		previous_previous_state = previous_state # set our previous previous state
		previous_state = state
		state = STATES.ALERTED

# timer timouts
func start_sound_timer(time):
	SoundTimer.set_wait_time(time) # set the wait time
	SoundTimer.start() # start the timer
	can_make_sound = false # don't do a loop

func _on_update_path_timeout():
	path_created = false

func _on_DEBUG_print_state_timeout():
	print("current state: " + str(STATES.keys()[state]) + " Previous State: " + str(STATES.keys()[previous_state]) + " Previous Previous State: " + str(STATES.keys()[previous_previous_state])) # print the current state

func _on_SoundCooldown_timeout():
	can_make_sound = true # temporary fix for the issue "not sending finished signal"
	powering_finished = true

func _on_InteractingTimer_timeout():
	can_interact = true
	created_static_path = false # reset so we can create a new path to a new location
	if !player_visible and !player_hearable:
		previous_previous_state = previous_state # set our previous previous state
		previous_state = state
		state = STATES.WANDERING # change the state to wander

func _on_Welt_activateRobot():
	powering_on()
