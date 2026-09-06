extends Control

var player: Node2D
var camera: Camera2D
var arrow: TextureRect

var margin := 40.0

func _ready():
	player = get_node("/root/Game/CharacterBody2D")
	camera = get_node("/root/Game/Firefly/Camera2D")
	arrow = find_child("Arrow", true, false)
	if arrow == null:
		push_error("Arrow node not found! Check the scene tree structure.")

func _process(_delta):
	if arrow == null:
		return

	var screen_size = get_viewport_rect().size
	var cam_pos = camera.get_screen_center_position()
	var player_screen_pos = player.global_position - cam_pos + screen_size / 2

	var is_offscreen = (
		player_screen_pos.x < 0 or player_screen_pos.x > screen_size.x or
		player_screen_pos.y < 0 or player_screen_pos.y > screen_size.y
	)

	visible = is_offscreen

	if is_offscreen:
		var center = screen_size / 2
		var direction = (player_screen_pos - center).normalized()

		var clamped = center + direction * (min(screen_size.x, screen_size.y) / 2 - margin)
		clamped.x = clamp(clamped.x, margin, screen_size.x - margin)
		clamped.y = clamp(clamped.y, margin, screen_size.y - margin)

		position = clamped - size / 2
		arrow.rotation = direction.angle() + PI / 2
