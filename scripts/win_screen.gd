extends Control

@onready var GLOBAL = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property($ColorRect, "color", Color(0, 0, 0, 0), 2)
	await get_tree().create_timer(2).timeout
	
	$DialogueEngine.play_dialogue_file("dialogues/win_1.json")
	await $DialogueEngine.dialogue_finished
	$DialogueEngine.play_dialogue_file("dialogues/win_2.json")
	await $DialogueEngine.dialogue_finished
	
	$PlayAgainButton.visible = true
	$QuitButton.visible = true
	$Credits.visible = true


func _on_play_again_button_pressed():
	GLOBAL.reset()
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
