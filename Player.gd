extends KinematicBody2D

const WALK_SPEED = 100
const WALK_MAX_SPEED = 200

const JUMP_SPEED = 200
const JUMP_DECELERATION = 1.1
const FALL_ACCELERATION = 5

const CHARGE_MODIFIER = 1.03
# Stores charge between frames
var charge = 1

const DUCK_SPEED = 100

var velocity = Vector2()

onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Horizontal movement code. First, get the player's input.
	var walk = WALK_SPEED * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	# Slow down the player if they're not trying to move.
	position.x += walk * delta
	
	# Jumping and ducking controls
	if is_on_floor():
		print(charge)
		if Input.is_action_pressed("jump"):
			charge *= CHARGE_MODIFIER
			charge = clamp(charge, 1, 4)
		if Input.is_action_just_released("jump"):
			velocity.y = -JUMP_SPEED * charge
			charge = 1
	else:
		if Input.is_action_just_pressed("duck"):
			velocity.y += DUCK_SPEED
	
	# Vertical acceleration/deceleration code. Apply gravity.
	if velocity.y < 0: # Juming
		# Start jump at full speed but slow down in the air
		velocity.y /= JUMP_DECELERATION
	velocity.y += gravity * FALL_ACCELERATION * delta
	
	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	# Wrap x position
	position.x = wrapf(position.x, 0, get_viewport_rect().size.x)
