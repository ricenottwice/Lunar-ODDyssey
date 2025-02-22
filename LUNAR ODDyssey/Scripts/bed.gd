extends Area2D

signal sleep_triggered
signal sleep_denied  # New signal for denied sleep attempts

var time_of_day  # This will be set by the Game script


func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.name == "Jinsoul":
		if not body.is_connected("interact", Callable(self, "_on_interact")):
			body.connect("interact", Callable(self, "_on_interact"))

func _on_body_exited(body):
	if body.name == "Jinsoul":
		if body.is_connected("interact", Callable(self, "_on_interact")):
			body.disconnect("interact", Callable(self, "_on_interact"))

func _on_interact():
	var game = get_node("/root/Game")  # Adjust if Game is under a different node
	print("Current time of day:", game.time_of_day)  # Debug: Show real-time clock
	if game.time_of_day >= 20 or game.time_of_day <=6:  # Allow sleep after 8 PM
		emit_signal("sleep_triggered")
	else:
		emit_signal("sleep_denied", "You can only
		sleep at night!")
