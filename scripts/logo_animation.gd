extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	play_animation()
	
	await $Animation.animation_finished
	await get_tree().create_timer(1).timeout
	
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func play_animation():
	$Animation.play("jar_up")
	$Animation.queue("text_in")
	$Animation.queue("fade_to_black")
