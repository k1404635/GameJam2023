class_name Interactable extends Area2D

var interact_type = "dialogue"

@export_category("World")
@export var interact_label: String = "Press E to interact"

@export_category("Dialogue Content")
@export var upper_text: Array[String] = []
@export var lower_text: Array[String] = []
@export var dialogue_file: String

@export_category("Dialogue Settings")
@export var upper_filepath: String = ""
@export var lower_filepath: String = ""
@export var show_lower: bool = false
@export_enum("back_and_forth") var behav: String = "back_and_forth"
