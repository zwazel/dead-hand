extends Spatial

func _ready():
	Global.inMenu = false
	Global.connect("lowPerformanceToggle", self, "changeGIProbe")
	
	Global.skipTutorial = true
	$GIProbe.bake()

func changeGIProbe(state):
	$GIProbe.visible = !state
	
	if !state:
		$GIProbe.bake()
