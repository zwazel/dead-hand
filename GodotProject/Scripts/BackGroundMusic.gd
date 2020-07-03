extends Node

var allAudioStreams = []
var currentAudioStream = null
export(int) var audioDifference = 10
export(int) var defaultAudioVolume = -15
export(float) var audioIncreaseSpeed = 0.2

func _ready():
	randomize() # randomize the seed
	for audioStreams in get_children(): # get every audioStream
		audioStreams.connect("finished", self, "changeMusic")
		audioStreams.volume_db = defaultAudioVolume
		allAudioStreams.append(audioStreams) # add the audiostreams to the array
	changeMusic()

func _process(delta):
	for audioStreams in get_children():
		if Global.inMenu:
			var target_volume = defaultAudioVolume
			
			if audioStreams.volume_db < target_volume:
				audioStreams.volume_db += audioIncreaseSpeed
		else:
			var target_volume = defaultAudioVolume - audioDifference
			
			if audioStreams.volume_db > target_volume:
				audioStreams.volume_db -= audioIncreaseSpeed

func changeMusic(): # change the current music
	currentAudioStream = choose(allAudioStreams) # get a random audioStream
	currentAudioStream.play() # play the chosen audiostream
	
func choose(array):
	array.shuffle() # shuffle the array
	return array.front() # return the first value in the array
