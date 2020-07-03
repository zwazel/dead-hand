extends HSlider

onready var lineEdit = get_node("../LineEdit")

func _ready():
	value = Global.PLAYER_FOV # set the value to the fov
	lineEdit.value = Global.PLAYER_FOV

func _on_HSlider_value_changed(value):
	get_node("../AudioStreamPlayer").play()
	Global.PLAYER_FOV = value
	lineEdit.value = value

func _on_LineEdit_value_changed(value):
	self.value = value
#	Global.PLAYER_FOV = value
