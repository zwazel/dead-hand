extends Control

onready var animPlayer = $AnimationPlayer
onready var backToMainMenuButton = get_node("OptionsMenu/Menu/HBoxContainer/BackButton")

var scene_path_to_load

func _ready():
	backToMainMenuButton.connect("backButtonPressed", self, "backToMainMenuPressed")
	
	$Menu/CenterRow/Buttons/NewGameButton.grab_focus() # set the focus to the button
	# by doing this we can use the keyboard to select the scene. by pressing enter you "press the button"
	for button in $Menu/CenterRow/Buttons.get_children(): # get all the buttons
		if button.name != "OptionsButton" and button.name != "ExitGameButton":
			button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load]) # we are connecting the button with the "pressed" signal. Every button has this signal.
		elif button.name == "OptionsButton":
			button.connect("pressed", self, "optionsButtonPressed")
		else:
			pass
	
	Global.inMenu = true
	Global.cutscene_finished = false

func _on_Button_pressed(scene_to_load): # if the button is pressed...
	scene_path_to_load = scene_to_load # save the scene we have to load
	$FadeIn.show() # make the node visible
	$FadeIn.fade_in() # call the function

func optionsButtonPressed(): # false = go to options menu, true = go back to main menu
	animPlayer.play("move_top_left")

func backToMainMenuPressed():
	animPlayer.play_backwards("move_top_left")

func _on_FadeIn_fade_finished(): # if the "fadeIn" animation is finished....
	get_tree().change_scene(scene_path_to_load) # change the scene
