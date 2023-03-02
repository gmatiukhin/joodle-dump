extends KinematicBody2D

export var g = 100
export var jump_speed = 200
export var duck_speed = 100
export var movement_speed = 100

var charge = 0
export var charge_speed = 1



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var velocity = Vector2.ZERO
	velocity.y += g
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			charge += charge_speed
		if Input.is_action_just_released("jump"):
			velocity.y -= jump_speed * charge
			charge = 0
	if Input.is_action_just_pressed("duck"):
		velocity.y += duck_speed
	if Input.is_action_pressed("move_left"):
		velocity.x -= movement_speed
	if Input.is_action_pressed("move_right"):
		velocity.x += movement_speed
	
	move_and_slide(velocity, Vector2.UP)
