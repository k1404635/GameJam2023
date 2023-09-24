extends CharacterBody2D

@onready var all_interactions = []

var in_interaction = false

var scroll_left_limit = 0
var scroll_right_limit = 0
var scroll_up_limit = 0
var scroll_down_limit = 0

var scroll_velocity: Vector2 = Vector2(0, 0)

const SPEED = 300.0 * 60

func _ready():
	update_interactions()

func _process(delta):
	if Input.is_action_just_pressed("interact") and not(in_interaction):
		execute_interactions()

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
	
	# Y axis Movement
	if (position.y > (scroll_up_limit * -1) + 540 and direction.y < 0) or (position.y < (scroll_down_limit) + 540 and direction.y > 0):
		velocity.y = direction.y * SPEED * delta
		scroll_velocity.y = move_toward(scroll_velocity.y, 0, SPEED * delta)
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED * delta)
		scroll_velocity.y = direction.y * SPEED * delta
	
	if not(in_interaction):
		# Actually Move
		move_and_collide(velocity * delta)
		
		# Animation
		if (direction.x > 0):
			$PlayerSprite.animation = "walk_right"
		if (direction.x < 0):
			$PlayerSprite.animation = "walk_left"

		if (direction.y > 0):
			$PlayerSprite.animation = "forward"
		if (direction.y < 0):
			$PlayerSprite.animation = "back"

		if (direction == Vector2.ZERO):
			$PlayerSprite.animation = "forward"
	
# Up POSSIBLE only if y < scroll_y_limit

# Interaction methods

func on_interaction_area_entered(area):
	all_interactions.insert(0, area)
	update_interactions()

func on_interaction_area_exited(area):
	all_interactions.erase(area)
	update_interactions()
	
func update_interactions():
	if all_interactions:
		$IndicatorLabel.text = all_interactions[0].interact_label
	else:
		$IndicatorLabel.text = ""
		
		
func execute_interactions():
	if len(all_interactions) > 0:
		in_interaction = true
		var cur_interaction = all_interactions[0]
		
		if cur_interaction.get_parent().get_parent() is NPC:
			cur_interaction.get_parent().get_parent().in_dialogue = true
		
		if (cur_interaction.dialogue_file):
			get_parent().get_node("UILayer/DialogueEngine").dialogue_finished.connect(on_interaction_finished)
			get_parent().get_node("UILayer/DialogueEngine").play_dialogue_file(cur_interaction.dialogue_file)
		else:
			var params = {
				"show_lower": cur_interaction.show_lower,
				"upper_text": cur_interaction.upper_text,
				"lower_text": cur_interaction.lower_text,
				"behavior": cur_interaction.behav
				}
			var upper = cur_interaction.upper_filepath
			var lower = cur_interaction.lower_filepath
			get_parent().get_node("UILayer/DialogueEngine").dialogue_finished.connect(on_interaction_finished)
			get_parent().get_node("UILayer/DialogueEngine").start_dialogue(params, upper, lower)

func on_interaction_finished():
	# Don't activate EVERY person's dialogue finished signal after talking to 1 thing
	get_parent().get_node("UILayer/DialogueEngine").disconnect("dialogue_finished", on_interaction_finished)
	
	# Unfreeze NPC if interaction is from NPC
	var cur_interaction_grandparent = all_interactions[0].get_parent().get_parent()
	if cur_interaction_grandparent is NPC:
		cur_interaction_grandparent.in_dialogue = false
	in_interaction = false
