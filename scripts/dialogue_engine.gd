extends Control

# HOW TO USE THE DIALOGUE ENGINE
# Using the dialogue engine is simple.

# First, from the world scene, ensure DialogueEngine is instantiated (it should be already, under UILayer)
# With DialogueEngine instantiated, all you need to do is call $DialogueEngine.start_dialogue with the correct parameters.
# First, you'll need a dict, with the following properties:
# - "show_lower", a boolean for whether or not the lower dialogue option is used
# - "upper_text", a list of strings that represent the text shown for the upper dialogue
# - "lower_text", same as upper_text, except for the lower dialogue
# - "behavior", defines the behavior when lower dialogue is enabled, currently ONLY "back_and_forth" is valid

# Next, you need the path to the character portrait images from res://.
# This typically is just the folders, followed by the full filename, e.g. path/to/portrait/my_portrait.png
# If you're using the lower dialogue, you will need 2 portraits.

# Finally, call start_dialogue with your dict and 2 portrait files, and the dialogue engine should handle the rest.

# BONUS: If the text is too slow, we can adjust the speed by changing BASE_SPEED. Currently, there is no way to change
# the speed text is shown for each individual string.

# It's probably most helpful to uncomment the code under TEST CODE in _ready() to see how this works.


# Data
var behavior = "back_and_forth"
var upper_text = [""]
var lower_text = [""]
var show_lower = false

var dialogue_type = "conversation"
var dialogue_id = ""

# Properties
var active = false
var typing = false
var bypass_typing = false

var current_upper = 0
var current_lower = 0

@export var BASE_SPEED = 2

signal dialogue_finished(type, id)
signal continued_dialogue
signal item_usable
signal item_not_usable

# Called when the node enters the scene tree for the first time.
func _ready():
	# TEST CODE
	#var params = {
	#	"show_lower": true,
	#	"upper_text": ["Hi, Robert!", "...", "You stink."],
	#	"lower_text": ["Hi, Circle.", "...", "Doesn't stop you from being a circle"],
	#	"behavior": "back_and_forth"
	#}
	#await get_tree().create_timer(2).timeout
	#start_dialogue(params, "assets/characters/TEMP.png", "assets/characters/TEMP.png")
	#play_dialogue_file("dialogues/TEST2.json")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active and not(typing) and Input.is_action_just_pressed("advance_dialogue"):
		continue_dialogue()
	elif active and Input.is_action_just_pressed("advance_dialogue"):
		bypass_typing = true

func continue_dialogue():
	print("ADVANCING", current_lower, current_upper)
	continued_dialogue.emit()
	if (show_lower):
		if (behavior == "back_and_forth"):
			if (current_upper == current_lower):
				next_upper(BASE_SPEED)
			elif (current_upper - current_lower == 1):
				next_lower(BASE_SPEED)
		if (behavior == "back_and_forth_rev"):
			if (current_upper == current_lower):
				next_lower(BASE_SPEED)
			elif (current_lower - current_upper == 1):
				next_upper(BASE_SPEED)
	else:
		next_upper(BASE_SPEED)



func next_upper(speed: float = 1):
	$UpperBox/Proceed.visible = false
	$LowerBox/Proceed.visible = false
	$UpperBox/Text.text = ""
	item_not_usable.emit()
	if (current_upper < len(upper_text)):
		type_to_box(upper_text[current_upper], $UpperBox/Text, speed)
		current_upper += 1
		item_usable.emit()
	else:
		end_dialogue()

func next_lower(speed: float = 1):
	$UpperBox/Proceed.visible = false
	$LowerBox/Proceed.visible = false
	$LowerBox/Text.text = ""
	item_not_usable.emit()
	if (current_lower < len(lower_text)):
		type_to_box(lower_text[current_lower], $LowerBox/Text, speed)
		current_lower += 1
		item_usable.emit()
	else:
		end_dialogue()

func override_upper(text: String, speed: float = 1):
	$UpperBox/Proceed.visible = false
	$LowerBox/Proceed.visible = false
	$UpperBox/Text.text = ""
	type_to_box(text, $UpperBox/Text, speed)

func override_lower(text: String, speed: float = 1):
	$UpperBox/Proceed.visible = false
	$LowerBox/Proceed.visible = false
	$LowerBox/Text.text = ""
	type_to_box(text, $LowerBox/Text, speed)

func type_to_box(text: String, label: RichTextLabel, speed: float = 1.0):
	typing = true
	var partial: String = ""
	
	var type_time_base = 0.1
	
	for ch in range(len(text)):
		partial += text[ch]
		label.text = partial
		await get_tree().create_timer(0.1 / speed).timeout
		if (bypass_typing):
			label.text = text
			break
	
	bypass_typing = false
	typing = false
	
	label.get_parent().get_node("Proceed").visible = true
	$DialogueBoxAnimation.play("proceed")


# Params is a dict, with the following content:
# params {
# 	show_lower: bool
# 	upper_text: list<text>
# 	lower_text: list<text>
# 	behavior: "back_and_forth"
# }
func start_dialogue(params, upper_filepath: String = "", lower_filepath: String = ""):
	show_lower = params["show_lower"]
	upper_text = params["upper_text"]
	
	var upper_texture = load("res://" + upper_filepath)
	$UpperBox/Portrait.texture = upper_texture
	
	current_upper = 0
	current_lower = 0
	
	if (show_lower):
		$LowerBox.visible = true
		behavior = params["behavior"]
		lower_text = params["lower_text"]
		
		var lower_texture = load("res://" + lower_filepath)
		$LowerBox/Portrait.texture = lower_texture
		
		current_lower = 0
		
		$DialogueBoxAnimation.play("upper_and_lower_in")
	else:
		$LowerBox.visible = false
		
		$DialogueBoxAnimation.play("upper_in")
	
	if ("type" in params):
		dialogue_type = params["type"]
	
	if ("id" in params):
		dialogue_id = params["id"]
	
	# Automatically begin 1st text
	await get_tree().create_timer(0.85).timeout
	
	continue_dialogue()
	active = true

func end_dialogue():
	print("Finishing Up This Dialogue")
	
	active = false
	if (show_lower):
		$DialogueBoxAnimation.play("upper_and_lower_out")
	else:
		$DialogueBoxAnimation.play("upper_out")
		
	$UpperBox/Text.text = ""
	$LowerBox/Text.text = ""
	
	await get_tree().create_timer(1).timeout
	
	current_upper = 0
	current_lower = 0
	
	dialogue_finished.emit(dialogue_type, dialogue_id)
	



func play_dialogue_file(filename: String):
	print("Loading Dialogue from res://%s" % filename)
	var dialogue_file = FileAccess.open("res://" + filename, FileAccess.READ)
	var json = JSON.new()
	var dialogue_data_err = json.parse(dialogue_file.get_as_text())
	
	if dialogue_data_err == OK:
		var dialogue_data = json.data
		if typeof(dialogue_data["upper"]) != TYPE_ARRAY:
			assert("You need a list of upper dialogue at the minimum for this to work.")
		if typeof(dialogue_data["portraits"]["upper"]) != TYPE_STRING:
			assert("An upper portrait is needed.")
		
		var params = {}
		
		params["upper_text"] = dialogue_data["upper"]
		var upper_portrait = dialogue_data["portraits"]["upper"]
		var lower_portrait = ""
		
		params["show_lower"] = false
		if ("lower" in dialogue_data):
			params["show_lower"] = true
			params["lower_text"] = dialogue_data["lower"]
			lower_portrait = dialogue_data["portraits"]["lower"]
		
		params["behavior"] = "back_and_forth"
		if ("settings" in dialogue_data):
			if ("behavior" in dialogue_data["settings"]):
				params["behavior"] = dialogue_data["settings"]["behavior"]
			if ("type" in dialogue_data["settings"]):
				params["type"] = dialogue_data["settings"]["type"]
			if ("id" in dialogue_data["settings"]):
				params["id"] = dialogue_data["settings"]["id"]
		
		start_dialogue(params, upper_portrait, lower_portrait)
		
	else:
		assert("Oh no, this dialogue file is invalid!")
