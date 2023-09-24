extends Control

@export var TIME_LIMIT = 300

var time_elapsed = 0

signal time_up


func go():
	print("Showing Timer")
	$TimerBase/Label.text = seconds_left_to_time(TIME_LIMIT)
	$TimerAnimation.play("timer_in")
	$MainTimer.start()


func seconds_left_to_time(time_left: int):
	var minutes = time_left / 60
	var seconds = time_left % 60
	
	return "%02d:%02d" % [minutes, seconds]


func _on_main_timer_timeout():
	time_elapsed += 1
	
	var time_left = TIME_LIMIT - time_elapsed
	$TimerBase/Label.text = seconds_left_to_time(time_left)

	# Fade Text to red when 1 minute left
	if (time_left == 60):
		var tween = get_tree().create_tween()
		tween.tween_property($TimerBase/Label.label_settings, "font_color", Color("#f7597b"), 1.0)
	
	# Show icons when 10 seconds left
	if (time_left == 10):
		var tween = get_tree().create_tween()
		tween.tween_property($TimerBase/Label.label_settings, "font_color", Color("#9c2230"), 1.0)
		$TimerAnimation.play("danger")
	
	# Next Second
	if (time_left > 0):
		$MainTimer.start()
	else:
		$TimerAnimation.play("timer_out")
		time_up.emit()
