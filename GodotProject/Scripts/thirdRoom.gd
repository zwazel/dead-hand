extends Spatial

func _ready():
	Global.connect("lowPerformanceToggle", self, "changeGIProbe")
	$GIProbe.bake()

func changeGIProbe(state):
	$GIProbe.visible = !state
	
	if !state:
		print("BAKE")
		$GIProbe.bake()
