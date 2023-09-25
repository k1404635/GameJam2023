extends Control

@onready var GLOBAL = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	if (GLOBAL.worst_end):
		$WorstImage.visible = true
		$FailImage.visible = false
		$Audio.play()

	var tween = get_tree().create_tween()
	tween.tween_property($Fade, "color", Color(0, 0, 0, 0), 5)
	
	await get_tree().create_timer(5).timeout


func _on_play_again_button_pressed():
	GLOBAL.reset()
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
