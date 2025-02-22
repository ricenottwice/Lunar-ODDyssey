extends CharacterBody2D  

@onready var game = get_parent()  # Get the parent node (Game) directly
@onready var cutscene_ui: CanvasLayer = game.get_node("UI/CutsceneUI")  # Get Cutscene UI safely
@onready var movement_timer: Timer = $ChoerryMovementTimer

var has_spoken_to_choerry = false  # Tracks whether Jinsoul has talked to Lippie before
var speed = 95  # Movement speed
var idle_position = Vector2(400, -320)  # Lippie's starting position
var waypoints = [Vector2(400, -320), Vector2(625, -320), Vector2(535, -250)]  # Preset movement spots
var moving = false  # Track if Lippie is currently moving
var current_target = Vector2.ZERO  # Current movement target


signal interact_triggered  # Signal to trigger interaction

func _ready():
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))
	$Area2D.connect("body_exited", Callable(self, "_on_body_exited"))
	# Start movement timer to trigger movement randomly
	movement_timer.wait_time = randf_range(0, 3)  # Random interval (5-10 seconds)
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
	movement_timer.wait_time = randf_range(0, 3)  # Random interval
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
	var cherry_count = jinsoul.inventory.count("cherry")  # Count apples in inventory
	if jinsoul and jinsoul.is_connected("interact", Callable(self, "_on_interact")):
		jinsoul.disconnect("interact", Callable(self, "_on_interact"))
	if game.game_progress == 1 and has_spoken_to_choerry == false:
		_start_first_time_dialogue()
		has_spoken_to_choerry = true
	elif game.game_progress == 2 and has_spoken_to_choerry == false:
		_start_progress_2_dialogue()
		has_spoken_to_choerry = true
	elif game.game_progress == 2 and has_spoken_to_choerry == true:
		if cherry_count >= 15:
			if jinsoul.remove_from_inventory("cherry", 15):  # Call Jinsoul's function!
				await _has_cherries_dialogue()
		else:
			_has_no_cherries_dialogue()
	else:
		_start_repeat_dialogue()

	




func _start_first_time_dialogue():
	cutscene_ui.start_cutscene([
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Neutral 1.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Choerry/Choerry/Surprise.png",
			"text": "Choerry:
			JINSOUL!! IT'S SO GOOD TO SEE YOU!!"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Mouth Open 2.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Choerry/Choerry/Default.png",
			"text": "Jinsoul:
			You too Choerry!"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Neutral 2.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Choerry/Choerry/Curious.png",
			"text": "Choerry:
			What have you been up to recently?"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Embarassed.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Choerry/Choerry/Default.png",
			"text": "Jinsoul:
			Oh, you know, just swimming around Middle Earth
			The usual!"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Face Palm.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Choerry/Choerry/Default.png",
			"text": "Choerry:
			Oh yea, that reminds me"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Neutral 1.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Choerry/Choerry/Curious.png",
			"text": "Jinsoul:
			Hm?"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Mouth Open 2.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Choerry/Choerry/Surprise.png",
			"text": "Choerry:
			I'll be going to Earth soon!"
		}
	])

func _start_repeat_dialogue():
	var repeat_dialogues = [
		[
			{
				"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Smile.png",
				"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Choerry/Choerry/Surprise.png",
				"text": "Choerry:
				JINSOUUUUUUL!!"
			},
			{
				"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Mouth Open 2.png",
				"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Choerry/Choerry/Surprise.png",
				"text": "Jinsoul:
				CHOERRYYYYYYY!!"
			}
		],
		[
			{
				"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Laugh.png",
				"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Laugh.png",
				"text": "Choerry:
				Did you hear about the fishie that tried to swim across the road?"
			},
			{
				"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Neutral 1.png",
				"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Lippie/Smart.png",
				"text": ". . ."
			},
			{
				"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Mouth Closed 2.png",
				"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Choerry/Choerry Shrug.png",
				"text": "Choerry:
				Me neither"
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
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Choerry/Choerry/Default.png",
			"text": "Choerry:
			Hey Jinsoul you didn't happen to find any cherries lying around did you?"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Mouth Open 2.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Choerry/Choerry/Default.png",
			"text": "Choerry:
			I need 15 of them to be able to use my odd eye powers to teleport to earth"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Neutral 2.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Choerry/Choerry/Regret.png",
			"text": "Choerry:
			I really hope I can find some soon... I miss earth"
		}
	])

func _has_cherries_dialogue():
	await cutscene_ui.start_cutscene([
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Embarassed.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Choerry/Choerry/Curious.png",
			"text": "Choerry:
			So did you collect enough cherries?"
		},
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Embarassed.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Choerry/Choerry/Surprise.png",
			"text": "Jinsoul:
			You bet I did!"
		}
	])
	await get_tree().create_timer(6.0).timeout  # ✅ Waits 2 seconds before continuing
	self.visible = false
	$CollisionShape2D.disabled = true   # Disable collision when invisible
	$Area2D.monitoring = false          # Disable interaction area


func _has_no_cherries_dialogue():
	cutscene_ui.start_cutscene([
		{
			"left_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Jinsoul/Embarassed.png",
			"right_portrait": "res://LUNAR ODDyssey/Assets/Sprites/Big_Sprites/Choerry/Choerry/Regret.png",
			"text": "Choerry:
			Jinsoul if you could get me 5 cherries that would be so awesome, thanks!"
		}
	])
