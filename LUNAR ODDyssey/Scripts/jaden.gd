extends CharacterBody2D  # Or Area2D if Jaden doesn’t need movement

@onready var game = get_parent()  # Get the parent node (Game) directly
@onready var cutscene_ui: CanvasLayer = game.get_node("UI/CutsceneUI")  # Reference to Cutscene UI
@onready var choerry: CharacterBody2D = $"../Choerry"

signal interact_triggered  # Signal to trigger interaction


func _process(delta):
	# Jaden is only visible between 12 AM - 3 AM
	if game.time_of_day >= 0 and game.time_of_day < 3:
		self.visible = true
		$CollisionShape2D.disabled = false  # Enable collision when visible
		$Area2D.monitoring = true           # Enable interaction area
	else:
		self.visible = false
		$CollisionShape2D.disabled = true   # Disable collision when invisible
		$Area2D.monitoring = false          # Disable interaction area
	# Change Jaden's position based on day_count
	if game.day_count == 2:
		position = Vector2(3500, 290)  # Example position 1
	elif game.day_count == 3:
		position = Vector2(535, -800)  # Example position 2
	elif game.day_count == 5:
		position = Vector2(4418, -625)  # Example position 3
	elif game.day_count == 7:
		position = Vector2(2060, 1700)  # Example position 3
	elif game.day_count == 8:
		position = Vector2(3500, 290)  # Example position 3
	else:
		position = Vector2(750, 850)  # Default position




func _ready():
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Jinsoul":
		print("Jinsoul is near Jaden!")  # Debug message
		if not body.is_connected("interact", Callable(self, "_on_interact")):
			body.connect("interact", Callable(self, "_on_interact"))

func _on_body_exited(body):
	if body.name == "Jinsoul":
		if body.is_connected("interact", Callable(self, "_on_interact")):
			body.disconnect("interact", Callable(self, "_on_interact"))

func _on_interact():
	var jinsoul = get_node("/root/Game/Jinsoul")  # Adjust if needed
	if jinsoul and jinsoul.is_connected("interact", Callable(self, "_on_interact")):
		jinsoul.disconnect("interact", Callable(self, "_on_interact"))
	# Choose the correct dialogue based on game progress
	if game.game_progress == 1:
		_start_first_time_jaden_dialogue()
		game.game_progress = 2  # Move story forward after first interaction
		choerry.has_spoken_to_choerry = false
	else:
		_start_repeat_jaden_dialogue()

# First time dialogue - moves game to progress 2
func _start_first_time_jaden_dialogue():
	cutscene_ui.start_cutscene([
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Neutral 1.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jaden/Serious.png",
			"text": "Miss Jinsoul... You have ventured far. Perhaps too far."
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Sad.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jaden/Neutral.png",
			"text": "Curious, isn’t it? How the stars align... or rather... are aligned."
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Mouth Open 2.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jaden/Neutral.png",
			"text": "What do you mean by that?"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Neutral 1.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jaden/Neutral.png",
			"text": "You’ll see. In time."
		}
	])

# Repeat dialogue after first meeting
func _start_repeat_jaden_dialogue():
	cutscene_ui.start_cutscene([
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Mouth Closed 2.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jaden/Neutral.png",
			"text": "Do you understand now, Jinsoul?"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Face Palm.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jaden/Neutral.png",
			"text": "What you do here... every word, every step... ripples outward."
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Sad.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jaden/Serious.png",
			"text": "You are special, yes... but not exempt from the rules of the game."
		}
	])
