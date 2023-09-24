extends Path2D

@export_category("Dialogue")
@export var dialogue_id: String

@export_category("Travel Behavior")
@export var pause_points: Array[float]

# Travel speed: progress per second
@export var travel_speed = 0.01

# Pause Duration: How long at each pause
@export var pause_duration = 10

var paused = 0

signal start_dialogue(scene)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	travel(delta)


func travel(delta):
	if (paused == 0):
		$NPCFollow.progress_ratio += travel_speed * delta
		
		for p in pause_points:
			if ($NPCFollow.progress_ratio - p <= 0.005):
				paused = pause_duration
		
		if ($NPCFollow.progress_ratio >= 1):
			$NPCFollow.progress_ratio = 0
	else:
		paused -= delta
		if (paused < 0):
			paused = 0



func randomize_position():
	$NPCFollow.progress = randf()



func _on_dialogue_trigger_body_entered(body):
	print(body.
	if (body):
		start_dialogue.emit(dialogue_id)
