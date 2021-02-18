extends KinematicBody2D

const SPEED = 200;
const SLIDE_SPEED = SPEED * 2;
const SHORT_SLIDE_DISTANCE = 100;
const THROW_DELAY = 8;
const POST_THROW_DELAY = 4;
var velocity;
var sprite;
var direction;
var throwing;
var throwDelay;
var sliding;
var slideStartPosition;
var bowlingBallScene;

# Determine Axis vector, contains direction based on user input
func get_axis():
	var axis = Vector2.ZERO;
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"));
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"));
	return axis.normalized();

# Apply updated movement to velocity
func update_velocity(speed,direction,delta):
	velocity = direction * speed * delta;
	var collision = move_and_collide(velocity.clamped(SPEED));
	if (collision):
		if (sliding):
			var lostVelocity = collision.remainder.bounce(collision.normal);
			velocity = velocity.bounce(collision.normal);
			move_and_collide(lostVelocity); 

# Update direction dictionary based on Player input
func update_direction(v):
	var dir = v.normalized();
	# Dot Product of two vectors being near 1 essentially means the two
	# vectors are pointing in the same direction
	if (dir.dot((Vector2.RIGHT + Vector2.DOWN).normalized()) > 0.99):
		direction = {"name": "fr", "vector": dir};
	elif (dir.dot((Vector2.RIGHT + Vector2.UP).normalized()) > 0.99):
		direction = {"name": "br", "vector": dir};
	elif (dir.dot((Vector2.LEFT + Vector2.DOWN).normalized()) > 0.99):
		direction = {"name": "fl", "vector": dir};
	elif (dir.dot((Vector2.LEFT + Vector2.UP).normalized()) > 0.99):
		direction = {"name": "bl", "vector": dir};
	elif (dir.dot(Vector2.LEFT) > 0.99):
		direction = {"name": "l", "vector": dir};
	elif (dir.dot(Vector2.RIGHT) > 0.99):
		direction = {"name": "r", "vector": dir};
	elif (dir.dot(Vector2.UP) > 0.99):
		direction = {"name": "b", "vector": dir};
	elif (dir.dot(Vector2.DOWN) > 0.99):
		direction = {"name": "f", "vector": dir};
 
func update_sprite():
	var dir = get_axis();
	if ((dir != Vector2.ZERO) and 
	   !(sliding)):
		update_direction(dir);
	sprite.play("idle_%s" % direction["name"]);
	
func update_sliding(delta):
	update_velocity(SLIDE_SPEED, direction["vector"], delta);
	if (slideStartPosition.distance_to(position) > SHORT_SLIDE_DISTANCE):
		sliding = false;
		

func throw_bowling_ball():
	var bowlingBall = bowlingBallScene.instance();
	bowlingBall.position = position;
	var dir = get_axis();
	if (dir == Vector2.ZERO):
		dir = direction["vector"]
	bowlingBall.set_direction(dir);
	get_parent().add_child(bowlingBall);

func slide():
	sliding = !sliding;
	if (sliding):
		slideStartPosition = position;

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize Velocity Vector
	velocity = Vector2();
	sliding = false;
	# Delay before rolling ball
	throwDelay = 0;
	# Initialize direction dictionary
	direction = {"name": "f", "vector": Vector2(Vector2.DOWN)};
	# Initialize sprite
	sprite = get_node("AnimatedSprite");
	bowlingBallScene = load("res://Objects/BowlingBall/BowlingBall.tscn");
	
# Called at the beginning of each physics step
func _physics_process(delta):
	# User input
	if (Input.is_action_just_pressed("ui_accept")):
		throwing = !throwing;
	if (Input.is_action_just_pressed("ui_cancel")):
		slide();
		
	# Rolling after delay
	if (throwing):
		throwDelay += 1;
		if (throwDelay == THROW_DELAY):
			throw_bowling_ball();
		elif (throwDelay > THROW_DELAY + POST_THROW_DELAY):
			throwing = false;
	else: 
		throwDelay = 0;
	
	# Movement
	update_direction(velocity);
	update_sprite();
	if (sliding):
		update_sliding(delta)
	else:
		if !(throwing):
			update_velocity(SPEED, get_axis(), delta);

