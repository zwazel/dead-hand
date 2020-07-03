extends Area

signal interact

func _ready():
	add_to_group("hiding_places") # add to a group. used for the robot to find it and interact with it.

func interact():
	emit_signal("interact")
