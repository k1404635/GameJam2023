extends ColorRect

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var play_button: Button = find_child("ResumeButton")
@onready var quit_button: Button = find_child("QuitButton")

func _ready() -> void:
	play_button.pressed.connect(unpause)
	quit_button.pressed.connect(back_to_menu)

func back_to_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
func unpause():
	play_button.disabled = true
	quit_button.disabled = true
	animator.play("Unpause")
	get_tree().paused = false
	
func pause():
	play_button.disabled = false
	quit_button.disabled = false
	animator.play("Pause")
	get_tree().paused = true
