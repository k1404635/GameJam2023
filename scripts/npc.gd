class_name NPC extends Path2D

@export_category("Dialogue")
@export var dialogue_file: String

@export_category("Travel Behavior")
@export var pause_points: Array[float]

# Travel speed: progress per second
@export var travel_speed = 0.01

# Pause Duration: How long at each pause
@export var pause_duration = 10

var in_dialogue = false

var paused = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$NPCFollow/Interactable.dialogue_file = dialogue_file


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not(in_dialogue):
		travel(delta)


func travel(delta):
	if (paused == 0):
		$NPCFollow.progress_ratio += travel_speed * delta
		
		for p in pause_points:
			if (abs($NPCFollow.progress_ratio - p) <= 0.001):
				paused = pause_duration
				var tween = get_tree().create_tween()
				tween.tween_property($NPCFollow, "progress_ratio", $NPCFollow.progress_ratio + 0.002, 0.2)
		
		if ($NPCFollow.progress_ratio >= 1):
			$NPCFollow.progress_ratio = 0
	else:
		paused -= delta
		if (paused < 0):
			paused = 0



func randomize_position():
	$NPCFollow.progress = randf()


func entered_dialogue():
	in_dialogue = true

func exited_dialogue():
	in_dialogue = false
