extends Control

export(NodePath) var fpsLabel
export(NodePath) var musicLabel
signal activateDefeatRobotHint

# Timestamps of frames rendered in the last second
var times := []

# Frames per second
var fps := 0

func _ready():
	fpsLabel = get_node(fpsLabel)
	musicLabel = get_node(musicLabel)
	
	if Global.initTutorial:
		var tut = preload("res://Scenes/UI/Tutorial/TutorialHintsScreen.tscn").instance()
		add_child(tut)
		connect("activateDefeatRobotHint", tut, "getDefeatRobotHint")
		Global.initTutorial = false

func _process(_delta: float) -> void:
	if Global.skipTutorial:
		if has_node("TutorialHintsScreen"):
			get_node("TutorialHintsScreen").queue_free()
	
	if Global.hide_hud:
		fpsLabel.visible = false
		musicLabel.visible = false
	else:
		fpsLabel.visible = true
		musicLabel.visible = true
	
		# music
		musicLabel.text = "Musik; \n" + str(BackGroundMusic.currentAudioStream.name) # \n means new line
		
		# FPS----------------------------------------------------
		var now := OS.get_ticks_msec()
	
		# Remove frames older than 1 second in the `times` array
		while times.size() > 0 and times[0] <= now - 1000:
			times.pop_front()
	
		times.append(now)
		fps = times.size()
	
		# Display FPS in the label
		fpsLabel.text = "FPS: " + str(fps)
	
	if Global.initTutorial:
		var tut = preload("res://Scenes/UI/Tutorial/TutorialHintsScreen.tscn").instance()
		add_child(tut)
		connect("activateDefeatRobotHint", tut, "getDefeatRobotHint")
		Global.initTutorial = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if has_node("TutorialHintsScreen"):
			get_node("TutorialHintsScreen").visible = !get_node("TutorialHintsScreen").visible

func _on_Welt_activateRobotTutorialHint(emitter):
	if has_node("TutorialHintsScreen"): # if we have the node
		connect("activateDefeatRobotHint", emitter, "removeActivateRobotHint")
		emit_signal("activateDefeatRobotHint") # emit the signal
