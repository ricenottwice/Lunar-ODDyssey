extends CharacterBody2D

@export var speed: float = 150
@onready var game = get_parent()  # Get the parent node (Game) directly
@onready var anim_sprite = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer
@onready var punch_hitbox = $PunchHitbox
@onready var cutscene_ui: CanvasLayer = game.get_node("UI/CutsceneUI")  # Get Cutscene UI safely
@onready var menu: Control = game.get_node("UI/Menu")  # Get Menu inside UI
@onready var punch_audio: AudioStreamPlayer = $PunchAudio


signal interact  # Signal to trigger sleep when interacting with bed
signal apple_collected  # Signal to notify when an apple is collected
signal cherry_collected
signal apple_removed
signal cherry_removed

var is_punching: bool = false
var can_break_objects: bool = false  # Control when objects can be broken
var facing_direction: String = "down"
var inventory = []  # Inventory to store collected items


func _ready():
	punch_hitbox.monitoring = true  # Keep the punch hitbox always active
	punch_hitbox.connect("body_entered", Callable(self, "_on_PunchHitbox_body_entered"))

func _process(delta):
	if Input.is_action_just_pressed("interact"):  # Make sure 'interact' is mapped to 'E'
		emit_signal("interact")


func remove_from_inventory(item: String, amount: int) -> bool:
	var removed_count = 0
	# Loop through inventory **backwards** (to prevent index errors)
	for i in range(inventory.size() - 1, -1, -1):
		if inventory[i] == item:
			inventory.remove_at(i)  # Remove the item
			removed_count += 1
			# Update UI based on item removed
			if item == "apple":
				emit_signal("apple_removed")  # Recalculate apple count
			elif item == "cherry":
				emit_signal("cherry_removed")  # Recalculate cherry count
			if removed_count >= amount:
				print("Removed", removed_count, item + "(s) from inventory.")
				return true  # Successfully removed
	print("Not enough", item + "s", "in inventory to remove", amount)
	return false



var punch_sounds = [
	preload("res://LUNAR ODDyssey/Assets/Audio/SFX/swoosh-sound-effect-for-fight-scenes-or-transitions-1-149889.mp3"),
	preload("res://LUNAR ODDyssey/Assets/Audio/SFX/swoosh-sound-effect-for-fight-scenes-or-transitions-2-149890.mp3"),
	preload("res://LUNAR ODDyssey/Assets/Audio/SFX/swoosh-sound-effect-for-fight-scenes-or-transitions-3-149888.mp3"),
	preload("res://LUNAR ODDyssey/Assets/Audio/SFX/swoosh-sound-effect-for-fight-scenes-or-transitions-4-149887.mp3")
]

func play_punch_sound():
	"""Plays a random punch sound."""
	var random_index = randi() % punch_sounds.size()
	punch_audio.stream = punch_sounds[random_index]
	punch_audio.play()

func _physics_process(delta: float) -> void:
	if cutscene_ui.cutscene_active or menu.visible:
		velocity = Vector2.ZERO
		move_and_slide()
		return  # Stop further movement processing
	if Input.is_action_just_pressed("punch") and not is_punching:
		_start_punch()
		return  # Skip movement while punching
	if not is_punching:
		_handle_movement(delta)

func _handle_movement(delta: float) -> void:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	velocity = input_vector * speed
	move_and_slide()

	_handle_animation(input_vector)

func _handle_animation(input_vector: Vector2) -> void:
	if input_vector == Vector2.ZERO:
		anim_sprite.play("idle_" + facing_direction)
	else:
		if abs(input_vector.x) > abs(input_vector.y):
			if input_vector.x > 0:
				anim_sprite.play("walk_right")
				facing_direction = "right"
			else:
				anim_sprite.play("walk_left")
				facing_direction = "left"
		else:
			if input_vector.y > 0:
				anim_sprite.play("walk_down")
				facing_direction = "down"
			else:
				anim_sprite.play("walk_up")
				facing_direction = "up"

func _start_punch() -> void:
	is_punching = true
	can_break_objects = true  # Allow breaking objects during punch
	# Play the punch animation on AnimatedSprite2D based on direction
	anim_sprite.play("punch_" + facing_direction)
	# Play the single punch animation in AnimationPlayer for timing
	anim_player.play("punch")
	# Disconnect first to avoid multiple connections (prevents freeze)
	if anim_player.is_connected("animation_finished", Callable(self, "_on_punch_finished")):
		anim_player.disconnect("animation_finished", Callable(self, "_on_punch_finished"))
	# Connect the animation finished signal
	anim_player.connect("animation_finished", Callable(self, "_on_punch_finished"))
	play_punch_sound()


func _on_punch_finished(anim_name: String) -> void:
	if anim_name == "punch":
		is_punching = false
		can_break_objects = false  # Stop breaking objects after punch ends
		anim_sprite.play("idle_" + facing_direction)

		# Disconnect the signal after punch finishes to avoid repeated calls
		anim_player.disconnect("animation_finished", Callable(self, "_on_punch_finished"))

# Detect punches hitting objects
func _on_PunchHitbox_body_entered(body: Node) -> void:
	print("Punch hit:", body.name)  # Check if we hit anything at all
	if can_break_objects:
		print("Breaking is enabled, checking if it's destructible...")
		if body.is_in_group("destructibles"):
			print("Punch hit a destructible object! Breaking it!")
			body.break_apart()
		else:
			print("Punch hit something, but it's NOT in the destructibles group.")
	else:
		print("Punch hit something, but breaking is DISABLED.")


func enable_breaking():
	can_break_objects = true
	print("Breaking enabled!")
	# Temporarily disable and re-enable the hitbox to refresh overlaps
	punch_hitbox.monitoring = false
	punch_hitbox.monitoring = true


# Add collected fruit to inventory
func add_to_inventory(item: String) -> void:
	inventory.append(item)
	print("Added to inventory:", item)
	print("Current inventory:", inventory)
	
	if item == "apple":
		emit_signal("apple_collected")  # Emit signal when apple is collected
		print("Signal emitted for apple_collected!")
	
	if item == "cherry":
		emit_signal("cherry_collected")  # Emit signal when apple is collected
		print("Signal emitted for cherry_collected!")
