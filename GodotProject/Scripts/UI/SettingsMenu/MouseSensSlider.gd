extends HSlider

onready var lineEdit = get_node("../LineEdit")

func _ready():
	value = Global.GLOBAL_MOUSE_SENSITIVITY # set the value to the fov
	lineEdit.value = Global.GLOBAL_MOUSE_SENSITIVITY * 10

func _on_HSlider_value_changed(value):
	get_node("../AudioStreamPlayer").play() # play audio while changing the value
	Global.GLOBAL_MOUSE_SENSITIVITY = value # set the global value
	lineEdit.value = value * 10

func _on_LineEdit_value_changed(value):
	self.value = value / 10
#	Global.GLOBAL_MOUSE_SENSITIVITY = value / 10
