extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	play_animation()

func play_animation():
	$Animation.play("jar_up")
	$Animation.queue("text_in")
	$Animation.queue("fade_to_black")
