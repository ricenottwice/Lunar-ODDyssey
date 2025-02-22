extends Area2D
@onready var anim_sprite = $AnimatedSprite2D
var collected_fruit = ""  # To store the type of collected fruit

func _ready():
	print("Default fruit spawned!")
	_set_random_animation()
	await get_tree().create_timer(1.0).timeout  # Wait for 1 second before enabling collection
	connect("body_entered", Callable(self, "_on_body_entered"))

func _set_random_animation():
	var animations = ["apple", "cherry"]  # Add more animations if needed
	collected_fruit = animations[randi() % animations.size()]  # Store the random animation name
	anim_sprite.play(collected_fruit)
	print("Playing animation:", collected_fruit)

func _on_body_entered(body):
	if body.name == "Jinsoul":
		print("Fruit collected:", collected_fruit)
		body.add_to_inventory(collected_fruit)  # Add the collected fruit to Jinsoul's inventory
		queue_free()
