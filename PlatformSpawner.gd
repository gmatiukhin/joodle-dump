extends Node2D

const NUM_PLATFORMS = 4
const Y_SCATTER = 20
const X_SCATTER = 60

const PLATFORM_CLEAR_ZONE = 20

var rng = RandomNumberGenerator.new()
var platform_preload = preload("res://Platform.tscn")
onready var viewport = get_viewport_rect().size

func spawn_platforms():
	var platform_elevation_delta = viewport.y / NUM_PLATFORMS
	print(platform_elevation_delta)
	var prev_pos_x = 0
	for i in NUM_PLATFORMS:
		var platform_position := Vector2()
		
		var elevation_scatter = rng.randf_range(-Y_SCATTER, Y_SCATTER)
		platform_position.y = (i + 1) * platform_elevation_delta + elevation_scatter
		
		platform_position.x = viewport.x / 2 + rng.randf_range(-X_SCATTER, X_SCATTER)
		# Offset new platform so that the player can always jump from the previous		
		var x_delta = platform_position.x - prev_pos_x
		if is_equal_approx(x_delta, 0.0):
			platform_position.x += PLATFORM_CLEAR_ZONE * (1 if rng.randf() > 0.5 else -1)
		elif abs(x_delta) < PLATFORM_CLEAR_ZONE:
			platform_position.x += PLATFORM_CLEAR_ZONE * sign(x_delta)
		prev_pos_x = platform_position.x
		
		spawn_platform(platform_position)

# Spawns two platforms instead of one in order to accomodate screen wrapping 
func spawn_platform(pos: Vector2):
	var platform1 = platform_preload.instance() as StaticBody2D
	platform1.position = pos
	
	var platform2 = platform_preload.instance() as StaticBody2D
	var wrap_offset = viewport.x * (1 if pos.x < viewport.x / 2 else -1)
	platform2.position = pos + Vector2(wrap_offset, 0)
	
	print(platform1.position)
	
	add_child(platform1)
	add_child(platform2)

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	spawn_platforms()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
