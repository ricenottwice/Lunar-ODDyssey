extends CanvasLayer

@onready var apple_count_label: Label = $Panel/AppleCountLabel
@onready var cherry_count_label: Label = $Panel/CherryCountLabel
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var menu: Control = %Menu
@onready var resume_button: Button = $Menu/MarginContainer/VBoxContainer/ResumeGame
@onready var fullscreen_toggle: CheckBox = $Menu/MarginContainer/VBoxContainer/CheckBox
@onready var quit_button: Button = $Menu/MarginContainer/VBoxContainer/QuitGame
@onready var menu_button: Button = $Panel/MenuButton
@onready var help_button: Button = $Menu/MarginContainer/VBoxContainer/HelpButton
@onready var help_popup: PopupMenu = $Menu/MarginContainer/VBoxContainer/HelpPopup
@onready var margin_container: MarginContainer = $Menu/MarginContainer


var apple_count = 0
var cherry_count = 0

func _ready():
	var jinsoul = get_node("/root/Game/Jinsoul")  # Adjust if needed
	if jinsoul:
		jinsoul.connect("apple_collected", Callable(self, "_on_jinsoul_apple_collected"))
		jinsoul.connect("cherry_collected", Callable(self, "_on_jinsoul_cherry_collected"))
		jinsoul.connect("apple_removed", Callable(self, "_on_jinsoul_apple_removed"))
		jinsoul.connect("cherry_removed", Callable(self, "_on_jinsoul_cherry_removed"))
	else:
		print("Error: Jinsoul node not found in UI script!")
	
	# Set the game to start in fullscreen mode
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	menu.visible = false  # Hide the menu initially
	# Connect buttons to their respective functions
	resume_button.connect("pressed", Callable(self, "_on_resume_pressed"))
	quit_button.connect("pressed", Callable(self, "_on_quit_pressed"))
	menu_button.connect("pressed", Callable(self, "_on_menu_button_pressed"))
	fullscreen_toggle.connect("toggled", Callable(self, "_on_fullscreen_toggled"))
	help_button.connect("pressed", Callable(self, "_on_help_pressed"))
		# Connect the resized signal to adjust margins dynamically
	get_window().connect("size_changed", Callable(self, "_on_window_resized"))
	adjust_margins()  # Set initial margins based on current window size


func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Press ESC to open/close menu
		menu.visible = !menu.visible

# Inventory Updates
func _on_jinsoul_apple_collected():
	apple_count += 1
	apple_count_label.text = "Apples: " + str(apple_count)

func _on_jinsoul_cherry_collected():
	cherry_count += 1
	cherry_count_label.text = "Cherries: " + str(cherry_count)

func _on_jinsoul_apple_removed():
	apple_count -= 1
	apple_count_label.text = "Apples: " + str(apple_count)

func _on_jinsoul_cherry_removed():
	cherry_count -= 1
	cherry_count_label.text = "Cherries: " + str(cherry_count)




# Volume Controls
func _on_music_slidee_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < .05)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < .05)

# Menu Functions
func _on_menu_button_pressed():
	""" Opens the menu when clicking the menu button """
	menu.visible = true

func _on_resume_pressed():
	""" Closes the menu """
	menu.visible = false

func _on_help_pressed():
	if help_popup.visible:
		help_popup.hide()
	else:
		help_popup.show()


func _on_quit_pressed():
	""" Quits the game """
	get_tree().quit()

func _on_fullscreen_toggled(button_pressed):
	""" Toggles between fullscreen and windowed mode """
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)







func _on_window_resized():
	adjust_margins()

func adjust_margins():
	var screen_size = get_window().size  # Get current window size

	# Set margin values dynamically based on screen width
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		margin_container.add_theme_constant_override("margin_left", 720)  # 10% of screen width
		margin_container.add_theme_constant_override("margin_right", 720)
		margin_container.add_theme_constant_override("margin_top", 0)
		margin_container.add_theme_constant_override("margin_bottom", 0)
	else:
		# Default values for windowed mode
		margin_container.add_theme_constant_override("margin_left", 360)
		margin_container.add_theme_constant_override("margin_right", 360)
		margin_container.add_theme_constant_override("margin_top", 0)
		margin_container.add_theme_constant_override("margin_bottom", 0)
