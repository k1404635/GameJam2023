extends Node2D

@export var flip: bool = false
var down_point = 390

func _ready():
	if (flip):
		$Overlay.flip_h = true
		$OnLayer.flip_h = true

func on_overlay_active():
	$Overlay.self_modulate.a = 0.6

func on_overlay_inactive():
	$Overlay.self_modulate.a = 1.0
