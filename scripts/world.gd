extends Node2D

@export var PLAYER_VELOCITY = 10

const SCREEN_WIDTH = 1920
const SCREEN_HEIGHT = 1080

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()


func _process(delta):
	# Handles Scrolling
	if ($Player.scroll_velocity != Vector2.ZERO):
		$Scroll.position -= $Player.scroll_velocity * delta
		if $Scroll.position.y > 0:
			$Scroll.position.y = 0
			$Player.scroll_up_limit = 540
		elif $Scroll.position.y < -3240:
			$Scroll.position.y = -3240
			$Player.scroll_down_limit = 540
		else:
			$Player.scroll_up_limit = 540/2
			$Player.scroll_down_limit = 540/2
		
		if $Scroll.position.x > 0:
			$Scroll.position.x = 0
			$Player.scroll_left_limit = 960
		elif $Scroll.position.x < -1920:
			$Scroll.position.x = -1920
			$Player.scroll_right_limit = 960
		else:
			$Player.scroll_left_limit = 960/2
			$Player.scroll_right_limit = 960/2


func reset():
	$Scroll.position = Vector2(-960, -2700)
	$Player.position = Vector2(960, 540)
	
	$Player.scroll_left_limit = 960/2
	$Player.scroll_right_limit = 960/2
	$Player.scroll_up_limit = 540/2
	$Player.scroll_down_limit = 540/2
	
	#await get_tree().create_timer(2).timeout
	#$UILayer/IncidentTimer.go()


func _on_incident_timer_time_up():
	var tween = get_tree().create_tween()
	tween.tween_property($UILayer/Bleak, "color", Color("#171d29a0"), 2.0)
