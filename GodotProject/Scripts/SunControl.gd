extends Light

func _ready():
	Global.connect("activate_sun", self, "change_sun_state")
	
func change_sun_state(state):
	visible = state
