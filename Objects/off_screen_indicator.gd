extends Control

var player: Node2D
var camera: Camera2D
var arrow: TextureRect

var margin := 40.0

func _ready():
	player = get_node("/root/Game/CharacterBody2D")
	camera = get_node("/root/Game/Firefly/Camera2D")
	arrow = find_child("Arrow", true, false)
	if arrow:
		arrow.pivot_offset = arrow.size / 2
	if arrow == null:
		push_error("Arrow node not found! Check the scene tree structure.")

func _process(_delta):
	if arrow == null:
		return

	var screen_size = get_viewport_rect().size
	var cam_pos = camera.get_screen_center_position()
	var zoom = camera.zoom

	var world_offset = player.global_position - cam_pos
	var screen_offset = world_offset / zoom
	var player_screen_pos = screen_offset + screen_size / 2

	var is_offscreen = (
		player_screen_pos.x < 0 or player_screen_pos.x > screen_size.x or
		player_screen_pos.y < 0 or player_screen_pos.y > screen_size.y
	)

	arrow.visible = is_offscreen

	if is_offscreen:
		var center = screen_size / 2
		var direction = (player_screen_pos - center).normalized()

		var half_w = screen_size.x / 2 - margin
		var half_h = screen_size.y / 2 - margin

		var dist_x = INF if direction.x == 0 else abs(half_w / direction.x)
		var dist_y = INF if direction.y == 0 else abs(half_h / direction.y)
		var dist = min(dist_x, dist_y)

		var edge_point = center + direction * dist

		arrow.position = edge_point - arrow.size / 2
		arrow.rotation = direction.angle()
