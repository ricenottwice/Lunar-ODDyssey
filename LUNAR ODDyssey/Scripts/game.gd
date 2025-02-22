extends Node

@onready var world: Node = $World
@onready var clock_label: Label = $UI/Panel/ClockLabel
@onready var day_night_timer: Timer = $DayNightTimer
@onready var fade_overlay: ColorRect = $UI/FadeOverlay
@onready var tip_label: Label = $UI/TipLabel  # Reference to the tip label
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var game: Node2D = $"."
@onready var menu: Control = game.get_node("UI/Menu")  # Get Menu inside UI
@onready var day_label: Label = $UI/Panel/DayLabel

var game_progress = 1  # Starts at 1, increases as events happen
var day_count: int = 1  # Start from Day 1
var time_of_day: int = 9
var hour_length: float = 30.0  # Length of one in-game hour in real seconds
var songs = [
	preload("res://LUNAR ODDyssey/Assets/Audio/Music/HaSeul_Plastic_Candy_Instrumental.mp3"),
	preload("res://LUNAR ODDyssey/Assets/Audio/Music/Let_Me_In_-_LOONA_Haseul_Clean_Instrumental.mp3")
]
var current_song_index = 0  # Keeps track of which song is playing
var days_without_sleep = 0
var jinsoul  # Reference to Jinsoul





func _ready():
	day_night_timer.connect("timeout", Callable(self, "_on_day_night_timer_timeout"))
	if clock_label == null:
		print("ClockLabel not found!")
	else:
		print("ClockLabel successfully found!")
	var bed = $Bed # Adjust the path if needed
	bed.time_of_day = time_of_day  # Pass the current time to the bed
	# Pick a random song to start
	current_song_index = randi() % songs.size()
	play_song(current_song_index)  # Play a random song on start
	music_player.connect("finished", Callable(self, "_on_music_finished"))  # Detect when a song ends
	jinsoul = get_node("/root/Game/Jinsoul")  # Get Jinsoul node
	check_fatigue()  # Check initial status





func play_song(index):
	"""Plays a song based on the given index."""
	if index >= 0 and index < songs.size():
		music_player.stream = songs[index]
		music_player.play()

func _on_music_finished():
	"""Switches to the next song randomly when the current one ends."""
	var next_index = randi() % songs.size()  # Pick a new random song
	# Ensure it doesn't repeat the same song twice
	while next_index == current_song_index:
		next_index = randi() % songs.size()
	current_song_index = next_index  # Update the current song index
	play_song(current_song_index)

func _on_day_night_timer_timeout():
	if menu.visible:
		return
	time_of_day += 1
	if time_of_day >= 24:
		time_of_day = 0  # Reset day cycle
		day_count += 1  # A new day begins
		_update_day()
	_update_world_brightness()
	_update_clock()

func _update_day():
	"""Called when the in-game time resets (new day starts)"""
	days_without_sleep += 1  # Increase exhaustion level
	check_fatigue()  # Apply effects
	print("New day started! Days without sleep:", days_without_sleep)
	day_label.text = "Day: " + str(day_count)

func _update_clock():
	var hour = time_of_day % 24
	var formatted_hour = str(hour).pad_zeros(2)
	clock_label.text = "Day & Night: " + formatted_hour


func _update_world_brightness():
	var max_brightness = Color(1, 1, 1, 1)  # Full brightness
	var min_brightness = Color(0.5, 0.5, 0.7, 1)  # Slightly lighter nighttime
	# Brightness peaks between 10 AM and 4 PM
	if time_of_day >= 10 and time_of_day <= 16:
		world.modulate = max_brightness
	# Gradually brighten from 6 AM to 10 AM
	elif time_of_day >= 6 and time_of_day < 10:
		var progress = float(time_of_day - 6) / 4.0  # Progress from 0 to 1
		world.modulate = min_brightness.lerp(max_brightness, progress)
	# Gradually darken from 4 PM to 8 PM
	elif time_of_day > 16 and time_of_day <= 20:
		var progress = float(time_of_day - 16) / 4.0  # Progress from 0 to 1
		world.modulate = max_brightness.lerp(min_brightness, progress)
	# Nighttime from 8 PM to 6 AM with max darkness between 11 PM and 4 AM
	elif time_of_day > 20 and time_of_day < 23:
		var progress = float(time_of_day - 20) / 3.0  # Gradually darkening
		world.modulate = min_brightness.lerp(Color(0.4, 0.4, 0.6, 1), progress)
	elif time_of_day >= 23 or time_of_day < 4:
		world.modulate = Color(0.4, 0.4, 0.6, 1)  # Max darkness
	elif time_of_day >= 4 and time_of_day < 6:
		var progress = float(time_of_day - 4) / 2.0  # Gradually brightening before dawn
		world.modulate = Color(0.4, 0.4, 0.6, 1).lerp(min_brightness, progress)


func check_fatigue():
	"""Update Jinsoul's condition based on sleep deprivation"""
	if days_without_sleep == 0:
		jinsoul.speed = 150
	if days_without_sleep == 1:
		_show_tip("You are tired")
		jinsoul.speed *= 0.9  # Reduce speed slightly
	elif days_without_sleep == 2:
		_show_tip("You are VERY tired")
		jinsoul.speed *= 0.8  # Larger movement penalty
	elif days_without_sleep >= 3:
		_show_tip("YOU NEED SLEEP!")
		jinsoul.speed *= 0.65  # Major movement penalty
	# Optional: Add screen effects like shaking or dimming


func _on_bed_sleep_triggered() -> void:
	days_without_sleep = 0  # Reset exhaustion
	check_fatigue()
	await fade_overlay.fade_out(1.5)  # Call fade_out from the FadeOverlay script
	time_of_day = 8  # Set time to 8 AM
	_update_world_brightness()
	_update_clock()
	await fade_overlay.fade_in(1.5)  # Call fade_in from the FadeOverlay script
	"""Jinsoul sleeps, resetting exhaustion"""
	_show_tip("You awaken
	feeling refreshed")



func _on_bed_sleep_denied(message):
	_show_tip(message)


func _show_tip(message, duration = 3.0):
	tip_label.text = message
	tip_label.visible = true  # Make sure the label is visible
	tip_label.modulate.a = 1  # Ensure it's fully opaque before showing
	# Wait for the message to display for the duration
	await get_tree().create_timer(duration).timeout
	# Fade out the label
	var tween = create_tween()
	tween.tween_property(tip_label, "modulate:a", 0, 0.5)  # Fade out over 0.5 seconds
	await tween.finished
	# Hide the label after fading out
	tip_label.visible = false
