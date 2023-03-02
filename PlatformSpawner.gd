extends Node2D

export (int) var num_platforms = 3
export (int) var y_scatter = 30
export (int) var x_scatter = 30
# space at the top of the screen where no platform can spawn
export (int) var dead_zone = 50

var rng = RandomNumberGenerator.new()
var platform_preload = preload("res://Platform.tscn")
onready var viewport = get_viewport_rect().size

func spawn_three_platforms():
	var platform_elevation_delta = (viewport.y- dead_zone) / num_platforms
	print(platform_elevation_delta)
	for i in num_platforms:
		var platform = platform_preload.instance() as StaticBody2D
		var elevation_scatter = rng.randf_range(-y_scatter, y_scatter)
		platform.position.y = dead_zone + i * platform_elevation_delta + elevation_scatter
		platform.position.x = viewport.x / 2 + rng.randf_range(-x_scatter, x_scatter)
		print(platform.position)
		add_child(platform)

# Called when the node enters the scene tree for the first time.
func _ready():
	print(viewport)
	rng.randomize()
	spawn_three_platforms()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
