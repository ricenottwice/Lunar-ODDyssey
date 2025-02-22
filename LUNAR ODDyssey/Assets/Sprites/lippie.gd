extends CharacterBody2D  

@onready var game = get_parent()  # Get the parent node (Game) directly
@onready var cutscene_ui: CanvasLayer = game.get_node("UI/CutsceneUI")  # Get Cutscene UI safely
@onready var movement_timer: Timer = $MovementTimer  # Timer for movement

var has_spoken_to_lippie = false  # Tracks whether Jinsoul has talked to Lippie before
var speed = 30  # Movement speed
var idle_position = Vector2(690, 265)  # Lippie's starting position
var waypoints = [Vector2(690, 265), Vector2(380, 244), Vector2(490, 630), Vector2(580, 750), Vector2(250, 100), Vector2(660, 0)]  # Preset movement spots
var moving = false  # Track if Lippie is currently moving
var current_target = Vector2.ZERO  # Current movement target


signal interact_triggered  # Signal to trigger interaction

func _ready():
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))
	$Area2D.connect("body_exited", Callable(self, "_on_body_exited"))
	# Start movement timer to trigger movement randomly
	movement_timer.wait_time = randf_range(10, 30)  # Random interval (5-10 seconds)
	movement_timer.start()
	movement_timer.connect("timeout", Callable(self, "_on_movement_timer_timeout"))



func _physics_process(delta):
	if moving:
		var direction = (current_target - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		# If Lippie is close to target, stop moving
		if global_position.distance_to(current_target) < 5:
			moving = false
			velocity = Vector2.ZERO
			movement_timer.start()  # Restart the timer for next movement

func _on_movement_timer_timeout():
	# If a cutscene is active, Lippie shouldn't move
	if cutscene_ui.cutscene_active:
		movement_timer.start()
		return
	# Choose a random waypoint for Lippie to walk to
	current_target = waypoints[randi() % waypoints.size()]
	moving = true
	# Restart timer so she stays there for a while before moving again
	movement_timer.wait_time = randf_range(10, 30)  # Random interval
	movement_timer.start()



func _on_body_entered(body):
	if body.name == "Jinsoul":
		# Stop interaction if a cutscene is already playing
		if cutscene_ui.cutscene_active:
			return  
		# Connect Jinsoul’s interact function if not already connected
		if not body.is_connected("interact", Callable(self, "_on_interact")):
			body.connect("interact", Callable(self, "_on_interact"))

func _on_body_exited(body):
	if body.name == "Jinsoul":
		# Disconnect Jinsoul’s interact function when leaving
		if body.is_connected("interact", Callable(self, "_on_interact")):
			body.disconnect("interact", Callable(self, "_on_interact"))

func _on_interact():
	# Prevent interaction if a cutscene is already running
	if cutscene_ui.cutscene_active:
		return  
	var jinsoul = get_node("/root/Game/Jinsoul")  # Adjust if needed
	if jinsoul and jinsoul.is_connected("interact", Callable(self, "_on_interact")):
		jinsoul.disconnect("interact", Callable(self, "_on_interact"))
	if game.game_progress == 1:
		_start_first_time_dialogue()
	elif game.game_progress == 2:
		_start_progress_2_dialogue()
	else:
		_start_repeat_dialogue()

func _start_first_time_dialogue():
	cutscene_ui.start_cutscene([
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Neutral 1.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Neutral.png",
			"text": "Kim Lip:
			Oh! Hey Jinsoul! You've been wandering around a lot lately, huh?"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Mouth Open 2.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Smart.png",
			"text": "Jinsoul:
			Yeah, I just... there's a lot to take in, you know?"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Neutral 2.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Laugh.png",
			"text": "Kim Lip:
			I get it! You’ve got that explorer spirit!"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Embarassed.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Smart.png",
			"text": "Kim Lip:
			Oh! Did you hear about Choerry? She's actually planning to go to Earth!"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Face Palm.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Neutral.png",
			"text": "Jinsoul:
			I can’t believe it either. She always had that wild streak, though..."
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Neutral 1.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Laugh.png",
			"text": "Kim Lip:
			Either way, I think it’s kinda exciting! What do you think?"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Mouth Open 2.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Smart.png",
			"text": "Kim Lip:
			Maybe we'll all go on an adventure someday..."
		}
	])

func _start_repeat_dialogue():
	var repeat_dialogues = [
		[
			{
				"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Smile.png",
				"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Laugh.png",
				"text": "Kim Lip:
				Hey Jinsoul! Back for another chat?"
			},
			{
				"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Mouth Open 2.png",
				"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Smart.png",
				"text": "Kim Lip:
				You always seem to be up to something interesting."
			},
			{
				"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Neutral 2.png",
				"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Neutral.png",
				"text": "Kim Lip:
				I’ll be here if you ever need a chat!"
			}
		],
		[
			{
				"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Laugh.png",
				"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Laugh.png",
				"text": "Kim Lip:
				Did you hear? Choerry found a secret path near the cliffs!"
			},
			{
				"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Neutral 1.png",
				"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Smart.png",
				"text": "Kim Lip:
				I don’t know where it leads, but I bet there’s something interesting there."
			},
			{
				"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Mouth Closed 2.png",
				"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Neutral.png",
				"text": "Kim Lip:
				Maybe you should check it out sometime?"
			}
		]
	]
	# Choose a random repeat dialogue set
	var chosen_dialogue = repeat_dialogues[randi() % repeat_dialogues.size()]
	cutscene_ui.start_cutscene(chosen_dialogue)



func _start_progress_2_dialogue():
	cutscene_ui.start_cutscene([
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Neutral 1.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Neutral.png",
			"text": "Jinsoul
			Hi Lippie, you didn't happen to see any strange man walking around at night did you?"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Mouth Open 2.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Smart.png",
			"text": "Kim Lip:
			A strange man? I have no idea what you could be talking about!"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Neutral 2.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Laugh.png",
			"text": "Kim Lip:
			I did however see Choerry earlier though"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Embarassed.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Smart.png",
			"text": "Kim Lip:
			She said she needed cherries for her odd eye powers to work"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Face Palm.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Neutral.png",
			"text": "Jinsoul:
			Cherries? Where would anyone find those?"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Neutral 1.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Laugh.png",
			"text": "Kim Lip:
			You don't think that strange person you saw earlier would know, would you?"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Mouth Open 2.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Smart.png",
			"text": "Jinsoul:
			I'm not so sure he was a person"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Mouth Open 2.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Smart.png",
			"text": "Jinsoul:
			When did these vases get here by the way? They look so ugly I want to go up and break them"
		}
	])
