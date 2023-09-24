extends CharacterBody2D

@onready var all_interactions = []
#@onready var interactLabel = $"Interaction Components/InteractLabel"

var scroll_left_limit = 0
var scroll_right_limit = 0
var scroll_up_limit = 0
var scroll_down_limit = 0

var scroll_velocity: Vector2 = Vector2(0, 0)

const SPEED = 300.0 * 60

func _ready():
	update_interactions()


func _physics_process(delta):
	
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# X axis Movement
	if (position.x > (scroll_left_limit * -1) + 960 and direction.x < 0) or (position.x < (scroll_right_limit) + 960 and direction.x > 0):
		velocity.x = direction.x * SPEED * delta
		scroll_velocity.x = move_toward(scroll_velocity.x, 0, SPEED * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		scroll_velocity.x = direction.x * SPEED * delta
		
	if (position.y > (scroll_up_limit * -1) + 540 and direction.y < 0) or (position.y < (scroll_down_limit) + 540 and direction.y > 0):
		velocity.y = direction.y * SPEED * delta
		scroll_velocity.y = move_toward(scroll_velocity.y, 0, SPEED * delta)
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED * delta)
		scroll_velocity.y = direction.y * SPEED * delta

	move_and_slide()
	
	if Input.is_action_just_pressed("interact"):
		execute_interactions()
		
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().call_group("Pause", "pause")
	
# Up POSSIBLE only if y < scroll_y_limit

# Interaction methods

func _on_interaction_area_area_entered(area):
	all_interactions.insert(0, area)
	update_interactions()

func _on_interaction_area_area_exited(area):
	all_interactions.erase(area)
	update_interactions()
	
func update_interactions():
#	if all_interactions:
#		interactLabel.text = all_interactions[0].interact_label
	pass
		
func execute_interactions():
	if all_interactions:
		var cur_interaction = all_interactions[0]
		var params = {
			"show_lower": cur_interaction.show_lower,
			"upper_text": cur_interaction.upper_text,
			"lower_text": cur_interaction.lower_text,
			"behavior": cur_interaction.behav
			}
		var upper = cur_interaction.upper_filepath
		var lower = cur_interaction.lower_filepath
		match cur_interaction.interact_type:
			"dialogue" : get_tree().call_group("Dialogue interactions","start_dialogue", params, upper, lower)


