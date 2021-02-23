extends KinematicBody2D

# How long the ball will exist for, in seconds
const LIFE_TIME = 2;
# Length of charge states, in seconds
const CHARGE_STAGES = [30,60,90];
# Timer controling life of ball
onready var lifeTimer = get_node("LifeTimer");
# Ball state variables
var origin;
var direction;
var velocity;
var speed;

# Determine speed of bowling ball based on power
func set_speed_from_power(p,speeds):
	speed = -1;
	for i in range(CHARGE_STAGES.size() - 1,0,-1):
		if (p > CHARGE_STAGES[i] / 60.0):
			speed = speeds[i + 1];
			break;
	if (speed == -1):
		speed = speeds[0]		

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
		
func _on_lifetimer_timeout():
	queue_free();
