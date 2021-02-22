extends KinematicBody2D

const MAX_BALL_DISTANCE = 2000;
const LIFE_TIME = 2;
const CHARGE_STAGE_1 = 45 / 60.0;
const CHARGE_STAGE_2 = 90 / 60.0;
const BASE_SPEED = 500;
onready var lifeTimer = get_node("LifeTimer");
var origin;
var direction;
var velocity;
var speed;

func set_speed_from_power(p):
	speed = power_to_speed(p);

# Determine speed of bowling ball based on power
func power_to_speed(p):
	if (p > CHARGE_STAGE_2):
		return BASE_SPEED * 2;
	elif (p > CHARGE_STAGE_1):
		return BASE_SPEED * 1.5;
	else:
		return BASE_SPEED; 

# Update direction of bowling ball
func set_direction(d):
	direction = d;

# Called when the node enters the scene tree for the first time.
func _ready():
	lifeTimer.set_wait_time(LIFE_TIME);
	lifeTimer.start();
	lifeTimer.connect("timeout", self, "_on_lifetimer_timeout")
	origin = position;
	velocity = speed * direction;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var collision = move_and_collide(velocity * delta); 
	if collision:
		var lostVelocity = collision.remainder.bounce(collision.normal);
		velocity = velocity.bounce(collision.normal);
		move_and_collide(lostVelocity); 
	# Destroy Bowling Ball if too far from creation coordinate
	if (position.distance_to(origin) > MAX_BALL_DISTANCE):
		queue_free();
		
func _on_lifetimer_timeout():
	queue_free();
