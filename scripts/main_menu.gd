extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	# Fade in
	$FadeInRect.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property($FadeInRect, "color", Color("#00000000"), 1.0)
	
	var audio_tween = get_tree().create_tween()
	audio_tween.tween_property($MenuLoop, "volume_db", 0, 1.0)


func _on_play_pressed():
	var tween = get_tree().create_tween()
	tween.tween_property($FadeInRect, "color", Color("#000000ff"), 1.0)
	
	var audio_tween = get_tree().create_tween()
	audio_tween.tween_property($MenuLoop, "volume_db", -50, 1.0)
	
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_texture_button_pressed():
	get_tree().quit()
