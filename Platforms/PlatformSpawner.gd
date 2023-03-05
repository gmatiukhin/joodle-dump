extends Node2D

var rng = RandomNumberGenerator.new()
var platform_preload = preload("res://Platforms/Platform.tscn")
@onready var viewport := get_viewport_rect().size

const Y_SCATTER = 20
const X_SCATTER = 60

const PLATFORM_CLEAR_ZONE = 20 # Space to leave free for jumps
const PLATFORM_MOVEMENT_SPEED = 40

@onready var last_platform_y := 0.0
@onready var last_platform_x := 0.0

const NUM_PLATFORMS_PER_SCREEN = 5
@onready var platform_elevation_delta = viewport.y / NUM_PLATFORMS_PER_SCREEN

var are_platforms_moving := false

var platform_index := 0

# Generates new platform above the screen
func generate_platform():
	if last_platform_y > 0:
		var platform_position := Vector2()
		
		# Place new platform on semi-random position above the top most previous platform
		var elevation_scatter = rng.randf_range(-Y_SCATTER, Y_SCATTER)
		platform_position.y = last_platform_y - (platform_elevation_delta + elevation_scatter)
		
		platform_position.x = viewport.x / 2 + rng.randf_range(-X_SCATTER, X_SCATTER)
		# Offset new platform to the side so that the player can always jump from the previous
		var x_delta = platform_position.x - last_platform_x
		if is_equal_approx(x_delta, 0.0):
			# If a platform was generated perfectly above a previous, move it to random side
			platform_position.x += PLATFORM_CLEAR_ZONE * (1 if rng.randf() > 0.5 else -1)
		elif abs(x_delta) < PLATFORM_CLEAR_ZONE:
			# If a platform does not provide a big enough gap for jumping, enlage that gap
			platform_position.x += PLATFORM_CLEAR_ZONE * sign(x_delta)
		
		spawn_platform(platform_position)

func spawn_platform(pos: Vector2, duplicate := true):
	var platform1 = platform_preload.instantiate() as StaticBody2D
	platform1.position = pos
	platform1.name = str(platform_index)
	
	last_platform_x = pos.x
	last_platform_y = pos.y
	
	add_child(platform1, true)
	
	# Spawn a second platform to the side, so that wrapping is be possible
	if duplicate:
		var platform2 = platform_preload.instantiate() as StaticBody2D
		var wrap_offset = viewport.x * (1 if pos.x < viewport.x / 2 else -1)
		platform2.position = pos + Vector2(wrap_offset, 0)
		# Add `_` to differentiate this copy from the main platform
		platform2.name = "_" + str(platform_index)
		
		add_child(platform2, true)
	platform_index += 1

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	spawn_platform(Vector2(viewport.x / 2, viewport.y), false)

# Removes platforms below the viewport
func remove_platforms_below():
	var children = get_children()
	for child in children:
		var platform = child as StaticBody2D
		if platform.position.y > viewport.y + Globals.GRACE_MARGIN:
			child.queue_free()

# Moves platforms down with constant speed
func move_platforms(speed: float):
	var children = get_children()
	for child in children:
		child.position.y += speed
	last_platform_y = children[-1].position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	generate_platform()
	if are_platforms_moving:
		move_platforms(PLATFORM_MOVEMENT_SPEED * delta)
		remove_platforms_below()

# Connect with player's signal
# Only start moving platforms down after player jumped once
func _on_Player_first_jump():
	are_platforms_moving = true
