extends Node2D

@export var PLAYER_VELOCITY = 10

const SCREEN_WIDTH = 1920
const SCREEN_HEIGHT = 1080

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.scroll_left_limit = 960/2
	$Player.scroll_right_limit = 960/2
	$Player.scroll_up_limit = 540/2
	$Player.scroll_down_limit = 540/2
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
