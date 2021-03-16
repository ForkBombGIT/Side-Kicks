extends KinematicBody2D

# How long the ball will exist for, in seconds
const LIFE_TIME = 2;
# Timer controling life of ball
onready var lifeTimer = get_node("LifeTimer");
# Ball state variables
var direction;
var velocity;
var speed;
var chargeState;
var playerId;

func set_charge_state(state):
	chargeState = state;

func set_player_id(id):
	playerId = id;

func set_speed(s):
	speed = s;

# Update direction of bowling ball
func set_direction(d):
	direction = d;

# Called when the node enters the scene tree for the first time.
func _ready():
	lifeTimer.set_wait_time(LIFE_TIME);
	lifeTimer.start();
	lifeTimer.connect("timeout", self, "_on_lifetimer_timeout")
	velocity = speed * direction;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity_before_collision = velocity;
	
	move_and_slide(velocity);
	var slide_count = get_slide_count();
	if slide_count:
		var collision = get_slide_collision(slide_count - 1);
		var lostVelocity = collision.remainder.bounce(collision.normal);
		velocity = velocity_before_collision.bounce(collision.normal);
		move_and_slide(lostVelocity);
		
func _on_lifetimer_timeout():
	queue_free();

func _on_Area2D_body_entered(body):
	if (body.is_in_group("Player")):
		if (body.id != playerId):
			body.bowling_ball_collision();
			var body_position = body.position;
			var direction = (body_position - position).normalized();
			velocity = -direction * speed;
