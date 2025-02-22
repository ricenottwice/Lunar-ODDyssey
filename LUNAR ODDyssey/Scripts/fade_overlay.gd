extends ColorRect

func fade_out(duration = 1.0):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, duration)  # Fade to black
	await tween.finished

func fade_in(duration = 1.0):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, duration)  # Fade back to game
	await tween.finished
