extends Spatial

onready var doorOpener = $Level/AnimationPlayer
onready var leaveCapsule = $LeaveCapsule
onready var cutscenePlayer = $CutscenePlayer
export(String, "Open", "Closed") var doorState = "Closed"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # capture the mouse
	Global.connect("lowPerformanceToggle", self, "changeGIProbe")
	$GIProbe.bake()

func changeGIProbe(state):
	$GIProbe.visible = !state
	
	if !state:
		$GIProbe.bake()

func _on_StaticBody_interact():
	if !doorOpener.is_playing(): # if we're not already playing a animation
		match doorState: # match doorState
			"Open": # if doorState is Open
				doorOpener.play_backwards("KapselRaumDoorOpening") # Close the door (play animation)
				doorState = "Closed" # set doorState to closed
			
			"Closed": # if doorstate is closed
				doorOpener.play("KapselRaumDoorOpening") # open the door (play animation)
				doorState = "Open" # set doorstate to open

func _on_Kapsel_capsuleIsOpen():
	leaveCapsule.play("LeaveCapsule") # play the animation to leave the capsule

func _on_LeaveCapsule_animation_finished(anim_name):
	match anim_name:
		"LeaveCapsule":
			var cutscenePlayerPos = $CutscenePlayer.global_transform.origin # get the position of the cutscene player
			var cutscenePlayerRot = $CutscenePlayer/HeadPos/Head.rotation_degrees.x # get the rotation of the head of the cutscene Player
			
			Global.cutscene_finished = true # cutscene is finished
			$CutscenePlayer.queue_free() # remove the cutscene player
			
			var player = preload("res://Scenes/Player.tscn") # preload the real player
			player = player.instance() # instanciate the player
			get_tree().get_root().get_node("Welt").add_child(player) # make the player a child of the scene
			player.global_transform.origin = cutscenePlayerPos # set the position of the player to the position of the cutscenePlayer
			player.find_node("Head").rotation_degrees.x = cutscenePlayerRot*-1 # set the head looking rotation of the player
			player.rotation_degrees.y = 180 # set the player looking rotation
