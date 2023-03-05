extends CharacterBody2D

const WALK_SPEED = 100

const JUMP_SPEED = 200
const JUMP_DECELERATION = 1.1
const FALL_ACCELERATION = 5

const CHARGE_MODIFIER = 1.03
# Stores charge between frames
var charge = 1

var velocity = Vector2()

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var viewport := get_viewport_rect().size

signal first_jump
var is_first_jump_emited := false

signal new_platform(platform_index)
signal death

var ignore_input := false

func _physics_process(delta):
	# Horizontal movement code
	var walk = WALK_SPEED * (Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
	# Change position.x directly for precise controls
	position.x += walk * delta
	# Wrap screen border 
	position.x = wrapf(position.x, 0, viewport.x)
	
	# Jumping controls
	if is_on_floor() and not ignore_input:
		if Input.is_action_pressed("jump"):
			charge *= CHARGE_MODIFIER
			charge = clamp(charge, 1, 4)
		if Input.is_action_just_released("jump"):
			velocity.y = -JUMP_SPEED * charge
			charge = 1
			if not is_first_jump_emited:
				emit_signal("first_jump")
	else:
		charge = 1 # Reset charge if falling
	
	# Vertical acceleration/deceleration code. Apply gravity.
	if velocity.y < 0: # Juming
		# Start jump at full speed but slow down in the air
		velocity.y /= JUMP_DECELERATION
	velocity.y += gravity * FALL_ACCELERATION * delta
	
	# Move based on the velocity and snap to the ground.
	set_velocity(velocity)
	# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `Vector2.DOWN`
	set_up_direction(Vector2.UP)
	move_and_slide()
	velocity = velocity
	
	# Process collisions with platforms
	var collision = get_last_slide_collision()
	if collision != null and is_on_floor():
		emit_signal("new_platform", int(collision.collider.name))
	
	if position.y > viewport.y + Globals.GRACE_MARGIN:
		emit_signal("death")
		self.queue_free()


func _on_HUD_ignore_input(val):
	ignore_input = val
