extends CheckButton

func _ready():
	pressed = Global.lowPerformance

func _on_LowPerformanceMode_toggled(button_pressed):
	Global.lowPerformanceToggled(button_pressed)
