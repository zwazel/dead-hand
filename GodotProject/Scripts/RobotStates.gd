extends StateMachine

func _ready():
	add_state("Wandering")
	add_state("Akerted")
	add_state("Attacking")
	add_state("LookingAround")
	add_state("LostPlayer")
	add_state("PoweringOn")
	add_state("PoweringOff")
	add_state("Interacting")
	add_state("FoundPlayer")
	call_deferred("set_state", states.PoweringOn)

func _state_logic(delta):
	pass

func _get_transition(delta):
	return null

func _enter_state(new_state, old_state):
	pass

func _exit_state(old_state, new_state):
	pass
