extends Area2D

@onready var bird_sound: AudioStreamPlayer2D = $BirdSound

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.name == "Jinsoul":  # Check if Jinsoul entered the area
		if not bird_sound.playing:  # Only play if not already playing
			bird_sound.play()

func _on_body_exited(body):
	if body.name == "Jinsoul":  # Check if Jinsoul left the area
		bird_sound.stop()
