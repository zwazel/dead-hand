extends Camera

func _ready():
	fov = Global.PLAYER_FOV
	far = Global.PLAYER_VIEW_DISTANCE

func _process(delta):
	if fov != Global.PLAYER_FOV:
			fov = Global.PLAYER_FOV
	
	if far != Global.PLAYER_VIEW_DISTANCE:
		far = Global.PLAYER_VIEW_DISTANCE
