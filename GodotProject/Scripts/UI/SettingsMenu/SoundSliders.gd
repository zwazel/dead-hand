extends HSlider

var parent_name
onready var lineEdit = get_node("../LineEdit")

func _ready():
	parent_name = get_node("../").name # get the name of the parent so we can set the right audio bus
	value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(get_node("../").name)) # set the value of the slider to the current value of the bus
	lineEdit.value = value

func _on_HSlider_value_changed(value): # when the value changes
	get_node("../AudioStreamPlayer").play() # get the audioplayer and play the audio
	lineEdit.value = value
	if value > min_value: # if the value is bigger than the minimum
		if AudioServer.is_bus_mute(AudioServer.get_bus_index(get_node("../").name)): # if the audio bus IS muted
			AudioServer.set_bus_mute(AudioServer.get_bus_index(get_node("../").name),false) # unmute the audio bus
		AudioServer.set_bus_volume_db((AudioServer.get_bus_index(get_node("../").name)), value) # set the volume of the bus
	else: # if the value is NOT bigger than the minimum
		AudioServer.set_bus_mute(AudioServer.get_bus_index(get_node("../").name),true) # mute the audio bus

func _on_LineEdit_value_changed(value):
	self.value = value
	
