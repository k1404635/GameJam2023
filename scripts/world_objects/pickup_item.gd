class_name PickupItem extends Node2D

signal picked_up(id)

@export_category("Appearance")
@export var sprite: Texture2D

@export_category("Behavior")
@export var pickup_quip: String
@export var pickup_name: String


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.texture = sprite
	
	# Prepare Dialogue
	$Interactable.id = pickup_name
	var upper_text: Array[String] = [pickup_quip]
	$Interactable.upper_text = upper_text
	$Interactable.upper_filepath = "assets/characters/player_portrait.png"

func init_with_vals(isprite, ipickup_quip, ipickup_name):
	sprite = isprite
	pickup_quip = ipickup_quip
	pickup_name = ipickup_name

func on_dialogue_finished(type, id):
	if (type == "item_pickup"):
		if (id == pickup_name):
			picked_up.emit(id)
			queue_free()
