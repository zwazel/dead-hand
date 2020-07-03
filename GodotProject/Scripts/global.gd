extends Node

var GLOBAL_MOUSE_SENSITIVITY = 0.05
var PLAYER_FOV = 70
var PLAYER_VIEW_DISTANCE = 500

var sun_active = false
var sun_needs_change = false
var debug_mode = false
var player_invisible = false
var flashlight_visible = true
var cutscene_finished = false
var hide_hud = false
var skipTutorial = false
var blinking = true

signal lowPerformanceToggle
var lowPerformance = false

var inMenu = true
var getNewHint = false
var playerCanOpenCapsule = false
var playerCanMove = false
var realPlayerCanInteract = false
var playerTookFlashlight = false
var playerCanOpenbigDoor = false
var initTutorial = false
var playerOpenedBigDoor = false

enum PLAYER_SOUND_MODES {
	STANDING,
	CROUCHING,
	WALKING,
	SPRINTING,
}
var player_sound_mode = PLAYER_SOUND_MODES.STANDING
var previous_player_sound_mode

signal activate_sun

func _ready():
	emit_signal("activate_sun", sun_active) # de/activate sun
	
	if OS.has_feature("standalone"):
		print("Running an exported build.")
	else:
		print("Running from the editor.")

func _process(delta):
	if sun_needs_change:
		emit_signal("activate_sun", sun_active) # deactivate sun
		sun_needs_change = false
	
	if skipTutorial:
		playerCanMove = true
		playerCanOpenCapsule = true
		playerCanOpenbigDoor = true
		realPlayerCanInteract = true

func lowPerformanceToggled(state):
	emit_signal("lowPerformanceToggle", state)
