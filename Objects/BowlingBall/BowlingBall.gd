extends KinematicBody2D

const SPEED = 500;
const MAX_BALL_DISTANCE = 2000;
var origin;
var direction;
var velocity;

func set_direction(d):
	direction = d;

# Called when the node enters the scene tree for the first time.
func _ready():
	origin = position;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = SPEED * direction * delta;
	velocity = move_and_collide(velocity); 
	# Destroy Bowling Ball if too far from creation coordinate
	if (position.distance_to(origin) > MAX_BALL_DISTANCE):
		queue_free();
