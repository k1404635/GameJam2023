extends Control

@onready var quit_button: TextureButton = find_child("Quit")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Fade in
	$FadeIn.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property($FadeIn, "color", Color("#00000000"), 1.0)
#
	quit_button.pressed.connect(get_tree().quit)
#	var audio_tween = get_tree().create_tween()
#	audio_tween.tween_property($MenuLoop, "volume_db", 0, 1.0)
	

func _on_play_again_pressed():
	var tween = get_tree().create_tween()
	tween.tween_property($FadeIn, "color", Color("#000000ff"), 1.0)
	
#	var audio_tween = get_tree().create_tween()
#	audio_tween.tween_property($MenuLoop, "volume_db", -50, 1.0)

	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://scenes/world.tscn")

