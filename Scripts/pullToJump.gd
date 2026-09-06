extends CharacterBody2D

@export var max_drag_distance: float = 150.0
@export var launch_power: float = 6.0
@export var trajectory_points: int = 30 # How long the dotted path is


@onready var line_2d: Line2D = $Line2D # Ensure you have a Line2D node

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dragging: bool = false
var drag_start_pos: Vector2 = Vector2.ZERO
var ground_friction: float = 25.0 # Higher number = faster stop / less sliding
func _physics_process(delta: float) -> void:
	# Apply standard platformer gravity
	if not is_on_floor() and not is_dragging:
		velocity.y += gravity * delta

	# Detect mouse down anywhere to start aiming
	if Input.is_action_just_pressed("click"):
		is_dragging = true
		drag_start_pos = get_global_mouse_position()
		line_2d.clear_points()

	if is_dragging:
		var current_mouse_pos: Vector2 = get_global_mouse_position()
		var pull_vector: Vector2 = current_mouse_pos - drag_start_pos
		
		if pull_vector.length() > max_drag_distance:
			pull_vector = pull_vector.normalized() * max_drag_distance
			
		var launch_velocity: Vector2 = -pull_vector * launch_power
		
		# Draw the predicted gravity arc path
		update_trajectory_preview(launch_velocity)
		
		# Execute Launch on Release
		if Input.is_action_just_released("click"):
			is_dragging = false
			line_2d.clear_points()
			velocity = launch_velocity
			
			# 3. Apply heavy friction immediately when touching the floor
		if is_on_floor() and not is_dragging:
			# Linearly interpolates velocity.x to 0 based on ground_friction rate
			velocity.x = move_toward(velocity.x, 0.0, ground_friction * delta)


	move_and_slide()

# Math simulation to map out exactly where physics will pull the player
func update_trajectory_preview(launch_velocity: Vector2) -> void:
	line_2d.clear_points()
	var sim_pos: Vector2 = Vector2.ZERO # Start at player local position
	var sim_velocity: Vector2 = launch_velocity
	var sim_delta: float = 0.05 # Time step between line dots
	
	for i in range(trajectory_points):
		line_2d.add_point(sim_pos)
		sim_velocity.y += gravity * sim_delta
		sim_pos += sim_velocity * sim_delta
