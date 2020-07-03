extends Spatial

onready var timer = $Timer # our timer
onready var lightOn = $LightOn # everything for when the light is turned on
onready var lightOff = $LightOff # everything for when the light is turned off

export(String, "On", "Off", "Flickering", "Random") var mode # the different modes for the light
export(float) var minFlickerDuration = 0.01 # our minimum flicker duration
export(float) var maxFlickerDuration = 2 # our maximum flicker duration

var lightState # our current state (on or off)

func _ready():
	randomize() # randomize so we get everytime a different random number
	match mode: # match mode
		"Random":
			randomMode()
		
		"On": # if mode is "on"
			turnOn()
		
		"Off": # if mode is "off"
			turnOff()
		
		"Flickering": # if mode is "flickering"
			initFlickering()

func randomMode():
	mode = choose(["On", "Off", "Flickering"])
	
	match mode:
		"On": # if mode is "on"
			turnOn()
		
		"Off": # if mode is "off"
			turnOff()
		
		"Flickering": # if mode is "flickering"
			initFlickering()

func _process(delta):
	if lightState:
		$StayingOn.stream_paused = false # play the stayingOn sound (unpause it)
	else:
		$StayingOn.stream_paused = true # don't the stayingOn sound (pause it)

func initFlickering():
	lightState = choose([true, false]) # choose a state
	timer.wait_time = rand_range(minFlickerDuration, maxFlickerDuration) # set the wait time of the timer with a random number between our min and max duration
	timer.start() # start the timer

func turnOn():
	lightState = true # set state to on
	lightOn.visible = true # make everything visible that should be visible in on
	lightOff.visible = false # make everything invisible that should be invisible in off

func turnOff():
	lightState = false # set state to off
	lightOn.visible = false # make everything invisible that should be invisible in on
	lightOff.visible = true # make everything visible that should be visible in off

func _on_Timer_timeout(): # if the timer reaches 0
	$TurningOnOff.play() # play the turningOnOff sound
	
	lightState = !lightState # change the state (state = NOT state || true = NOT true(false))
	
	if lightState: # if the state is on
		turnOn()
	else: # if our lightstate is off
		turnOff()
	
	timer.wait_time = rand_range(minFlickerDuration, maxFlickerDuration) # set the waittime to a random amount
	timer.start() # start the timer

func choose(array): # take an array
	array.shuffle() # shuffle the array
	return array.front() # return the first value in the array
