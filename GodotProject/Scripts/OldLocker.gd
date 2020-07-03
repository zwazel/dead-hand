extends Spatial

onready var animPlayer = $AnimationPlayer
export(bool) var state = false # false = closed, true = open
export(bool) var interactable = true
var can_be_interacted_with = true

func _ready():
	if state: # if state is true, the locker is open
		animPlayer.play("open_locker")
	else: # if state is false, the locker is closed
		animPlayer.play_backwards("open_locker")
	
	if !interactable:
		for children in get_children(): # get all the children
			if children.name != "schrank": # check if the current child is not the schrank
				children.queue_free() # remove the current child
	else: # if not interactable, connect signals and stuff
		$LockerArea.connect("interact", self, "is_being_interacted")
		$schrank/LeftDoorRotationHelper/LeftDoor/StaticBodyLeftDoor.connect("interact", self, "is_being_interacted")
		$schrank/RightDoorRotationHelper/RightDoor/StaticBodyRightDoor.connect("interact", self, "is_being_interacted")
		
		$InteractingArea.connect("interact", self, "is_being_interacted")
		$InteractingArea.connect("body_exited", self, "interactingAreaBodyExited")
		$InteractingArea.connect("body_entered", self, "interactingAreaBodyEntered")

func is_being_interacted(force_open = false):
	if interactable:
		if animPlayer.is_playing():
			can_be_interacted_with = false
		else:
			can_be_interacted_with = true
		
		if !force_open:
			if !animPlayer.is_playing(): # if the animPlayer is not already playing an animation
				if state: # if the door is already open
					animPlayer.play_backwards("open_locker") # close the door
					state = false # the door is now closed
				else: # if the door is closed
					animPlayer.play("open_locker") # open the door
					state = true # the door is now open
		else: # if only opening
			if !state: # if not already open
				animPlayer.play("open_locker") # open the door
				state = true # the door is now open

func interactingAreaBodyEntered(body):
	if body.is_in_group("robots"):
		body.is_in_interact_range = true
		body.interactingObject = self
		body.interactingPosition = $LockerArea/OpeningPosition
		body.lookAtPosition = $LockerArea/LookingPosition

func interactingAreaBodyExited(body):
	if body.is_in_group("robots"):
		body.is_in_interact_range = false

func _on_StaticBodyLeftDoor_interact():
	if interactable:
		is_being_interacted()

func _on_StaticBodyRightDoor_interact():
	if interactable:
		is_being_interacted()
