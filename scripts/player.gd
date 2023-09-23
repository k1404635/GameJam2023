extends CharacterBody2D

var scroll_left_limit = 0
var scroll_right_limit = 0
var scroll_up_limit = 0
var scroll_down_limit = 0

var scroll_velocity: Vector2 = Vector2(0, 0)

const SPEED = 300.0 * 60

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
	
# Up POSSIBLE only if y < scroll_y_limit
