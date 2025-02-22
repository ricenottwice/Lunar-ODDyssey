extends CanvasLayer

@onready var portrait_left: TextureRect = $PortraitLeft
@onready var portrait_right: TextureRect = $PortraitRight
@onready var dialogue_text: Label = $DialogueBox/DialogueText
@onready var day_night_timer: Timer = get_node("/root/Game/DayNightTimer")

var cutscene_active = false
var dialogue = []
var current_line = 0
var typewriter_speed = 0.03  
var text_fully_displayed = false  # Track if full text is on screen

func start_cutscene(dialogue_data):
	"""Begin a cutscene and pause game time."""
	cutscene_active = true
	dialogue = dialogue_data
	current_line = 0
	visible = true

	# Pause the game time timer
	if day_night_timer:
		day_night_timer.paused = true

	_show_next_line()

func _show_next_line():
	"""Display the next line of dialogue with typewriter effect."""
	if current_line >= len(dialogue):
		end_cutscene()
		return

	var line_data = dialogue[current_line]

	# Set portraits and expressions
	portrait_left.texture = load(line_data["left_portrait"])
	portrait_right.texture = load(line_data["right_portrait"])

	# Start typewriter effect for dialogue text
	await _start_typewriter_effect(line_data["text"])

	# Wait for X press before progressing
	await _wait_for_x_press()

	# Move to the next line **after** waiting
	current_line += 1  
	_show_next_line()

func _start_typewriter_effect(full_text: String):
	"""Typewriter effect that ensures full text appears before moving forward"""
	dialogue_text.text = ""  # Clear previous text
	text_fully_displayed = false  # Reset flag

	for i in range(full_text.length()):
		dialogue_text.text += full_text[i]  # Add one letter at a time
		await get_tree().create_timer(typewriter_speed).timeout

	text_fully_displayed = true  # Mark text as fully displayed

func _wait_for_x_press():
	"""Prevents skipping, only moves forward after full text appears"""
	while true:
		if text_fully_displayed and Input.is_action_just_pressed("interact"):
			break
		await get_tree().process_frame  # Keep checking for X press

func end_cutscene():
	"""End the cutscene and resume game time."""
	cutscene_active = false
	visible = false
	# Resume the game time timer
	if day_night_timer:
		day_night_timer.paused = false
