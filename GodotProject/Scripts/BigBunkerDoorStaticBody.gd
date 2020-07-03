extends StaticBody

signal interact

func interact():
	if Global.playerCanOpenbigDoor:
		emit_signal("interact")
		Global.playerOpenedBigDoor = true
