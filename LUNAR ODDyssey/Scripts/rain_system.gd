extends Node2D

@onready var rain_particles = $RainParticles  # GPUParticles2D for rain effect
@onready var rain_sound = $RainSound  # AudioStreamPlayer2D for rain sound
@onready var game = null  # Will be assigned in _ready()
@onready var jinsoul = get_node("/root/Game/Jinsoul")  # Adjust if needed
@onready var fade_duration = 1.0  # Time in seconds for the fade effect

var is_raining = false
var rain_duration = 0  # How long rain will last (in game hours)
var is_indoors = false  # Track if Jinsoul is indoors

func _ready():
	await get_tree().process_frame  # Ensure the game is loaded
	game = get_node("/root/Game")  # Get game node safely
	if game == null:
		print("Error: Game node not found!")

	rain_particles.emitting = false  # Ensure rain doesn't start at the beginning
	rain_sound.stop()  # Ensure no sound starts
	rain_sound.volume_db = -40  # Start fully muted to prevent instant loud sound
	start_rain_timer()

func _process(delta):
	# Ensure the rain follows Jinsoul while it's raining
	if is_raining and jinsoul:
		global_position = jinsoul.global_position + Vector2(0, -200)

func get_time():
	""" Retrieves the current time from the game """
	if game and "time_of_day" in game:
		return game.time_of_day
	else:
		print("Warning: Game time not found, defaulting to 9")
		return 9  # Default fallback

func start_rain_timer():
	""" Waits for the correct in-game hour before starting rain """
	while true:
		await get_tree().create_timer(game.hour_length).timeout  # Wait for an in-game hour
		if should_rain_now():
			start_rain()
			break  # Stop waiting once it starts raining

func should_rain_now() -> bool:
	""" Determines if rain should start based on time_of_day """
	var time_of_day = get_time()
	if randi_range(0, 12) == 0:  # 10% chance to start raining
		print("Rain started at in-game hour:", time_of_day)
		return true
	else:
		print("No rain at this hour:", time_of_day)
		return false

func start_rain():
	""" Starts the rain effect and syncs it with in-game time """
	is_raining = true
	rain_duration = randi_range(1, 5)  # Rain lasts 1-5 in-game hours
	rain_particles.emitting = true
	# ✅ If already indoors, don't play sound and hide rain
	if is_indoors:
		rain_particles.visible = false
		print("Rain started while indoors: Hiding particles, NOT playing sound")
	else:
		rain_particles.visible = true
		rain_sound.play()  # ✅ Start playing if outside
		fade_audio(true)  # ✅ Fade in if outside
	# Track when the rain should stop
	var stop_time = (get_time() + rain_duration) % 24  # Wrap around 24-hour cycle
	print("Rain started at", get_time(), "and will stop at", stop_time, "in-game hours.")
	# Keep checking until it's time to stop raining
	while is_raining:
		await get_tree().create_timer(game.hour_length).timeout  # Wait for an in-game hour
		if get_time() == stop_time:  # Stop when rain duration is over
			stop_rain()
			break

func stop_rain():
	""" Stops the rain effect """
	is_raining = false
	rain_particles.emitting = false
	fade_audio(false)  # ✅ Fade out before stopping

	await get_tree().create_timer(fade_duration).timeout  # ✅ Wait for fade-out before stopping sound
	rain_sound.stop()  # ✅ Stop sound completely
	start_rain_timer()  # Schedule the next rain event

# 🚪 Handle Jinsoul Entering & Exiting Indoors 🚪

func _on_indoor_area_body_entered(body: Node2D) -> void:
	if body.name == "Jinsoul":
		is_indoors = true
		print("Jinsoul entered indoors, fading out rain particles and sound")
		fade_rain(false)  # ✅ Fade out particles
		if is_raining:
			fade_audio(false)  # ✅ Fade out sound only if it’s raining

func _on_indoor_area_body_exited(body: Node2D) -> void:
	if body.name == "Jinsoul":
		is_indoors = false
		print("Jinsoul left indoors, fading in rain particles and sound")
		fade_rain(true)  # ✅ Fade in particles
		if is_raining:
			rain_sound.play()  # ✅ Ensure sound starts again if rain is active
			fade_audio(true)  # ✅ Fade in sound if raining
			rain_particles.visible = true
# 🌫️ Smoothly Fade In & Out Particles 🌫️

func fade_rain(fade_in: bool):
	var tween = get_tree().create_tween()
	if fade_in:
		tween.tween_property(rain_particles, "modulate:a", 1.0, fade_duration)  # Fade in
	else:
		tween.tween_property(rain_particles, "modulate:a", 0.0, fade_duration)  # Fade out

# 🔊 Smoothly Fade In & Out Sound 🔊

func fade_audio(fade_in: bool):
	var tween = get_tree().create_tween()
	if fade_in:
		print("Fading in rain sound")
		rain_sound.volume_db = -40  # Start from muted
		tween.tween_property(rain_sound, "volume_db", 0, fade_duration)  # ✅ Gradually increase to normal volume
	else:
		print("Fading out rain sound")
		tween.tween_property(rain_sound, "volume_db", -40, fade_duration)  # ✅ Gradually fade out
