extends ProgressBar

@export var player_path: NodePath = "/root/Game/CharacterBody2D"
@export var start_y: float = 700.0   # the player's Y position at the very start (bottom)
@export var goal_y: float = -2000.0  # the player's Y position at the top of the climb

@onready var player: Node2D = get_node(player_path)

func _process(_delta):
	var current_y = player.global_position.y
	# Since climbing = moving up = decreasing Y in Godot's coordinate system
	var total_distance = start_y - goal_y
	var distance_covered = start_y - current_y
	var percent = clamp(distance_covered / total_distance, 0.0, 1.0) * 100.0
	value = percent
