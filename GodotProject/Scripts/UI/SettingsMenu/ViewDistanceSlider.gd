extends HSlider

onready var lineEdit = get_node("../LineEdit")

func _ready():
	value = Global.PLAYER_VIEW_DISTANCE # set the value to the global value
	lineEdit.value = Global.PLAYER_VIEW_DISTANCE

func _on_HSlider_value_changed(value):
	get_node("../AudioStreamPlayer").play() # play audio while changing the value
	Global.PLAYER_VIEW_DISTANCE = value # set the global value
	lineEdit.value = value

func _on_LineEdit_value_changed(value):
	self.value = value
