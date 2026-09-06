extends ProgressBar

@export var player_path: NodePath = "/root/Game/CharacterBody2D"
@export var start_y: float = 134.933
@export var goal_y: float = -12857.067
@export var end_button_path: NodePath  # we'll assign this in the Inspector

@onready var player: Node2D = get_node(player_path)
@onready var end_button: Button = get_node(end_button_path)

func _process(_delta):
	var current_y = player.global_position.y
	var total_distance = start_y - goal_y
	var distance_covered = start_y - current_y
	var percent = clamp(distance_covered / total_distance, 0.0, 1.0) * 100.0
	value = percent

	if percent >= 100.0:
		end_button.visible = true
	
	if percent < 100:
		end_button.visible = false
