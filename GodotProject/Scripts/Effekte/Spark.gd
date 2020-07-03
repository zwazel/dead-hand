extends Spatial

onready var particleSystem = $Particles
onready var sparkAudio = $AudioStreamPlayer3D
onready var sparkTimer = $SparkTimer

export(bool) var autoStart = true
export(bool) var randomWaitTime = true
export(float) var waitTime = 2
export(float) var minWaitTime = 2
export(float) var maxWaitTime = 5

func _ready():
	randomize()
	if autoStart: # if autostart is true
		if randomWaitTime: # if random waittime is true
			sparkTimer.set_wait_time(rand_range(minWaitTime,maxWaitTime)) # set the wait time to a random amount
		else: # if the random waittime is false
			sparkTimer.set_wait_time(waitTime) # set the waittime to waittime
		sparkTimer.start() # start the timer

func start_spark(): # spark effect
	particleSystem.amount = round(rand_range(3,12)) # random amount of particles
	particleSystem.set_emitting(true) # emit particles (because it's set to oneshot, it only emits once)
	sparkAudio.play() # play the audio

func _on_Timer_timeout(): # if the timer reaches 0
	start_spark() # start the spark effect
