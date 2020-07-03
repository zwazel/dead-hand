extends KinematicBody

onready var animPlayer = $AnimationPlayer
onready var sound_turning_on = $SFX/RobotPowerOn
onready var attackRayCasts = $HeadAnchor/AttackRayCasts
onready var attackSound = $SFX/RobotTerminate
onready var moveSound = $SFX/RobotMoving
onready var soundTurningOff = $SFX/RobotPowerOff

export(int) var moveSpeed = 5
export(int) var rotation_speed = 3
export(float) var gravity = -50
var playerInAttackRange = false
var player = null
var state
var velocity = Vector3()
var active = false
var destroyed = false

enum STATES {
	STATE_ATTACK,
	STATE_WALK,
	STATE_ELECTROCUTE,
}

func _ready():
	randomize()
	add_to_group("robots") # add the robot to the group robots

func set_player(p):
	player = p # set the player

func _process(delta):
	match state:
		STATES.STATE_ATTACK:
			if !attackSound.playing:
				attackSound.play()
			checkAttackRange()
			
			if !playerInAttackRange:
				state = STATES.STATE_WALK
		
		STATES.STATE_WALK:
			walk(delta)
		
		STATES.STATE_ELECTROCUTE:
			moveSound.stop()
			powering_off()

func walk(delta):
	if player:
		checkAttackRange()
		
		if playerInAttackRange:
			state = STATES.STATE_ATTACK
			return
		
		if !moveSound.playing:
			moveSound.play()
		var vec_to_player = translation.direction_to(player.translation) #Get a vector pointing to the player
		vec_to_player.y += gravity * delta
		vec_to_player = move_and_slide(vec_to_player * moveSpeed); #Move along the vector
		
		var player_position = player.get_translation() # get the players position
		
		turn_face(player_position,rotation_speed, delta) # look at the player
	else:
		print("WARNING: No player set in " + str(name))

func checkAttackRange():
	attackRayCasts.look_at(player.global_transform.origin,Vector3(0,1,0))
	
	for raycast in attackRayCasts.get_children(): # get every raycast
		if raycast.is_colliding(): # check every raycast if they are colliding
			var coll = raycast.get_collider() # save our collider in a temp variable
			if coll == player: # check if the collider is our player
				playerInAttackRange = true # player is in attack_range
				return # exit the whole function so we dont check the other raycasts
	playerInAttackRange = false # if none of the raycast has hit the player, set it to false

func checkVision():
	pass

# choose a random thing from an array
func choose(array): # take an array
	array.shuffle() # shuffle the array
	return array.front() # return the first value in the array

func turn_face(target, rotationSpeed, delta):
	var global_pos = global_transform.origin
	var wtransform = global_transform.looking_at(Vector3(target.x,global_pos.y,target.z),Vector3(0,1,0))
	var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), rotationSpeed*delta)

	global_transform = Transform(Basis(wrotation), global_transform.origin)

func powering_off():
	if !destroyed:
		animPlayer.play("turning_off") # play the turning_off animation
		soundTurningOff.play() # play the sound
		destroyed = true

func powering_on():
	animPlayer.play_backwards("turning_off") # play the turning_off animation, but backwards.
	sound_turning_on.play() # play the sound

func _on_Welt_activateRobot():
	powering_on()

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"turning_off":
			if state != STATES.STATE_ELECTROCUTE:
				state = STATES.STATE_WALK
				active = true

func electrocute():
	state = STATES.STATE_ELECTROCUTE
