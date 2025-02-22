extends StaticBody2D

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func break_apart():
	audio_player.play()
	await audio_player.finished
	print("The vase is breaking!")
	_drop_default_fruit()
	queue_free()  # Remove the vase from the scene

func _drop_default_fruit():
	var fruit_scene = preload("res://LUNAR ODDyssey/Scenes/fruit.tscn")  # Load the default fruit scene
	var fruit_instance = fruit_scene.instantiate()
	get_parent().add_child(fruit_instance)
	fruit_instance.global_position = global_position
	print("Dropped default fruit!")
