extends KinematicBody2D

const SPEED = 500;
const MAX_BALL_DISTANCE = 2000;
const LIFE_TIME = 2.5;
var origin;
var direction;
var velocity;
var creationTime;

# Update direction of bowling ball
func set_direction(d):
	direction = d;

# Called when the node enters the scene tree for the first time.
func _ready():
	origin = position;
	velocity = SPEED * direction;
	creationTime = OS.get_ticks_msec();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var collision = move_and_collide(velocity * delta); 
	if collision:			
		var lostVelocity = collision.remainder.bounce(collision.normal);
		velocity = velocity.bounce(collision.normal);
		move_and_collide(lostVelocity); 
	# Destroy Bowling Ball if too far from creation coordinate
	if ((position.distance_to(origin) > MAX_BALL_DISTANCE) or
		((OS.get_ticks_msec() - creationTime) / 1000 > LIFE_TIME)):
		queue_free();
