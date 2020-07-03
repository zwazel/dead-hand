extends Control

onready var animPlayer = $AnimationPlayer
onready var backToMainMenuButton = get_node("OptionsMenu/Menu/HBoxContainer/BackButton") # needs a better solution
onready var settingsButton = $Menu/Top/Buttons/Settings
onready var debug_switch = $Menu/Toggles/Debug
onready var player_invisible_switch = $Menu/Toggles/PlayerInvisible
onready var sun_switch = $Menu/Toggles/SunActive
onready var flashlightSwitch = $Menu/Toggles/FlashlightVisible
onready var hideHudSwitch = $Menu/Toggles/HideHUD
onready var skipTutorialSwitch = $Menu/Toggles/SkipTutorial
onready var blinkingSwitch = $Menu/Toggles/Blinking

func _ready():
	backToMainMenuButton.connect("backButtonPressed", self, "backToMainMenuPressed")
	settingsButton.connect("pressed",self, "optionsButtonPressed")
	
	yield(get_tree(), "idle_frame");
	flashlightSwitch.pressed = Global.flashlight_visible
	debug_switch.pressed = Global.debug_mode # set the state of the button depending on the global var (on/off = true/false)
	player_invisible_switch.pressed = Global.player_invisible # set the state of the button depending on the global var (on/off = true/false)
	sun_switch.pressed = Global.sun_active # set the state of the button depending on the global var (on/off = true/false)
	hideHudSwitch.pressed = Global.hide_hud
	skipTutorialSwitch.pressed = Global.skipTutorial
	blinkingSwitch.pressed = Global.blinking

func optionsButtonPressed(): # false = go to options menu, true = go back to main menu
	animPlayer.play("move_top_left")

func backToMainMenuPressed():
	animPlayer.play_backwards("move_top_left")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		unpause_game()

func unpause_game(overwriteMouseMode = 0): # pause / unpause game # if overwrite set to 1 or 2, we can say what mode the mouse must be (1 captured, 2 free)
	visible = not visible # hide / show the scene
	Global.inMenu = !Global.inMenu
	get_tree().paused = not get_tree().paused # pause the whole game (this node is set to "process" in the "pause" value, so it keeps processing)
	
	if overwriteMouseMode == 0:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE: # if the mouse mode is already set to visible....
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # set the mouse mode to invisible/captured
		else: # if the mouse mode is already invisible/captured....
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # set the mouse mode to visible
	elif overwriteMouseMode == 1:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif overwriteMouseMode == 2:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		print("Something went wrong in PauseScreen, func unpause_game")

func _on_Resume_pressed():
	unpause_game()

func change_scene(scene_to_load):
	get_tree().change_scene(scene_to_load) # change the scene

func _on_Debug_toggled(button_pressed):
	Global.debug_mode = button_pressed

func _on_SunActive_toggled(button_pressed):
	Global.sun_needs_change = true
	Global.sun_active = button_pressed

func _on_PlayerInvisible_toggled(button_pressed):
	Global.player_invisible = button_pressed

func _on_FlashlightVisible_toggled(button_pressed):
	Global.flashlight_visible = button_pressed

func _on_HideHUD_toggled(button_pressed):
	Global.hide_hud = button_pressed

func _on_SkipTutorial_toggled(button_pressed):
	Global.skipTutorial = button_pressed
	if button_pressed:
		$Menu/Toggles/SkipTutorial.disabled = true

func _on_Blinking_toggled(button_pressed):
	Global.blinking = button_pressed
