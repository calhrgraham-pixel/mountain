extends CharacterBody2D

@export var max_drag_distance: float = 150.0
@export var launch_power: float = 6.0
@export var trajectory_points: int = 30
@onready var line_2d: Line2D = get_node("/root/Game/TrajectoryLayer/Line2D")

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dragging: bool = false
var drag_start_pos: Vector2 = Vector2.ZERO
var ground_friction: float = 2000.0  # Much higher — was 25, way too weak to ever stop sliding
var stop_threshold: float = 5.0      # Snap to 0 below this speed so it doesn't creep forever

func _physics_process(delta: float) -> void:
	if not is_on_floor() and not is_dragging:
		velocity.y += gravity * delta

	# Only allow starting a drag (jump/launch) when grounded
	if Input.is_action_just_pressed("click") and is_on_floor():
		is_dragging = true
		drag_start_pos = get_global_mouse_position()
		line_2d.clear_points()

	if is_dragging:
		var current_mouse_pos: Vector2 = get_global_mouse_position()
		var pull_vector: Vector2 = current_mouse_pos - drag_start_pos

		if pull_vector.length() > max_drag_distance:
			pull_vector = pull_vector.normalized() * max_drag_distance

		var launch_velocity: Vector2 = -pull_vector * launch_power
		update_trajectory_preview(launch_velocity)

		if Input.is_action_just_released("click"):
			is_dragging = false
			line_2d.clear_points()
			velocity = launch_velocity

	# Ground friction — only when grounded and not currently aiming
	if is_on_floor() and not is_dragging:
		if abs(velocity.x) < stop_threshold:
			velocity.x = 0.0
		else:
			velocity.x = move_toward(velocity.x, 0.0, ground_friction * delta)

	move_and_slide()

func update_trajectory_preview(launch_velocity: Vector2) -> void:
	line_2d.clear_points()
	var sim_pos: Vector2 = global_position
	var sim_velocity: Vector2 = launch_velocity
	var sim_delta: float = 0.05
	var canvas_transform = get_viewport().get_canvas_transform()

	for i in range(trajectory_points):
		line_2d.add_point(canvas_transform * sim_pos)
		sim_velocity.y += gravity * sim_delta
		sim_pos += sim_velocity * sim_delta
