extends KinematicBody2D

# How long the ball will exist for, in seconds
const LIFE_TIME = 2;
# How long before expiration the ball will start to flicker
const FLICKER_TIME = 30 / 60.0;
# Delay between flickers
const FLICKER_DELAY = 1 / 60.0;
# Timer controling life of ball
onready var lifeTimer = get_node("LifeTimer");
# Ball state variables
var direction;
var velocity;
var speed;
var chargeState;
var playerId;
var flickerTimer;
var alpha;

# Set charge state that was applied on ball
func set_charge_state(state):
	chargeState = state;

# Set parent player
func set_player_id(id):
	playerId = id;

# Set movement speed, set from Player
func set_speed(s):
	speed = s;

# Update direction of bowling ball
func set_direction(d):
	direction = d;

# Flicker sprite when the ball is going to expire in 30 or less frames	
func flicker():
	if (flickerTimer > FLICKER_DELAY):
		if (alpha == 1):
			alpha = 0;
		else:
			alpha = 1;
		flickerTimer = 0;
		$"Sprite".modulate.a = alpha;

# Called when the node enters the scene tree for the first time.
func _ready():
	lifeTimer.set_wait_time(LIFE_TIME);
	lifeTimer.start();
	lifeTimer.connect("timeout", self, "_on_lifetimer_timeout")
	flickerTimer = 0;
	velocity = speed * direction;
	alpha = 1;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If ball has less life than flicker time, start flickering
	if (lifeTimer.get_time_left() <= FLICKER_TIME):
		flickerTimer += delta;
		flicker();
	
	# Capture velocity before collision
	var velocity_before_collision = velocity;
	move_and_slide(velocity);
	# If there is a collision, bounce
	var slide_count = get_slide_count();
	if slide_count:
		var collision = get_slide_collision(slide_count - 1);
		var lostVelocity = collision.remainder.bounce(collision.normal);
		velocity = velocity_before_collision.bounce(collision.normal);
		move_and_slide(lostVelocity);
		
func _on_lifetimer_timeout():
	queue_free();

# Bounce off Player if it's they're not of the same id
func _on_Area2D_body_entered(body):
	if (body.is_in_group("Player")):
		if (body.id != playerId):
			body.bowling_ball_collision();
			var body_position = body.position;
			var direction = (body_position - position).normalized();
			velocity = -direction * speed;
