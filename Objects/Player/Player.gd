extends KinematicBody2D

const SPEED = 200;
const SLIDE_SPEED = SPEED * 2;
const SHORT_SLIDE_DISTANCE = 60;
const LONG_SLIDE_DISTANCE = 90;
const LONG_SLIDE_LENGTH = 10 / 60.0;
const BOWL_DELAY = 12 / 60.0;
const POST_BOWL_DELAY = 10 / 60.0;
onready var bowlingBallScene = load("res://Objects/BowlingBall/BowlingBall.tscn");
onready var sprite = get_node("AnimatedSprite");
var id;
var velocity;
var direction;
var bowlState;
var bowlPower;
var bowlDelay;
var sliding;
var slideLength;
var slideStartPosition;
var bowlingBall;

func set_id(id):
	self.id = id;

# Determine Axis vector, contains direction based on user input
func get_axis():
	var axis = Vector2.ZERO;
	axis.x = int(Input.is_action_pressed("ui_right_p%d" % id)) - int(Input.is_action_pressed("ui_left_p%d" % id));
	axis.y = int(Input.is_action_pressed("ui_down_p%d" % id)) - int(Input.is_action_pressed("ui_up_p%d" % id));
	return axis.normalized();

# Apply updated movement to velocity
func update_velocity(speed,direction,delta):
	velocity = direction * speed * delta;
	if (sliding):
		var collision = move_and_collide(velocity.clamped(SPEED));
		if (collision):
			var lostVelocity = collision.remainder.bounce(collision.normal);
			velocity = velocity.bounce(collision.normal);
			move_and_collide(lostVelocity); 
	else:
		velocity = move_and_slide(direction * speed);

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
 
# Update sprite based on direction
func update_sprite():
	var dir = get_axis();
	if ((dir != Vector2.ZERO) and 
	   !(sliding)):
		update_direction(dir);
	sprite.play("idle_%s" % direction["name"]);

# Slide
func update_sliding(delta):
	# Update velocity based on direction of slide
	update_velocity(SLIDE_SPEED, direction["vector"], delta);
	# Set maximum distance based on slideLength
	var distance = SHORT_SLIDE_DISTANCE;
	if (slideLength > LONG_SLIDE_LENGTH):
		distance = LONG_SLIDE_DISTANCE;
	# Stop sliding once maximum distance is reached
	if (slideStartPosition.distance_to(position) > distance):
		sliding = false;
		slideLength = 0;

# Bowl ball
func bowl_bowling_ball():
	if !(is_instance_valid(bowlingBall)):
		# bowlState set to 3, represents ball has been rowled
		bowlState = 3;
		# Instatiate BowlingBall
		bowlingBall = bowlingBallScene.instance();
		bowlingBall.position = position;
		bowlingBall.set_speed_from_power(bowlPower);
		# Reset bowlPower
		bowlPower = 0;
		# Set direction of bowlingBall
		var dir = get_axis();
		if (dir == Vector2.ZERO):
			dir = direction["vector"]
		bowlingBall.set_direction(dir);
		get_parent().add_child(bowlingBall);

# Cancels or starts sliding, and sets start position
func slide():
	sliding = !sliding;
	if (sliding):
		slideStartPosition = position;

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize Velocity Vector
	velocity = Vector2();
	sliding = false;
	# How long player holds slide button
	slideLength = 0;
	# Initialize Bowl power, how long player holds bowl button
	bowlPower = 0;
	# Delay before rolling ball
	bowlDelay = 0;
	bowlState = 0;
	# Initialize direction dictionary
	direction = {"name": "f", "vector": Vector2(Vector2.DOWN)};
	
# Called at the beginning of each physics step
func _physics_process(delta):
	# Bowling action
	if !(is_instance_valid(bowlingBall)) :
		if ((Input.is_action_pressed("ui_ok_p%d" % id))):
			bowlPower += delta;
			bowlState = 1;
		if ((Input.is_action_just_released("ui_ok_p%d" % id))):
			bowlState = 2;
	# Sliding action
	if ((Input.is_action_pressed("ui_back_p%d" % id))):
		slideLength += delta;
	if ((Input.is_action_just_released("ui_back_p%d" % id))):
		slide();
	
	# Ball Rolling after delay
	if (bowlState >= 2):
		bowlDelay += delta;
		# Skip BOWL_DELAY if bowl was charged
		if (bowlPower >= BOWL_DELAY):
			bowlDelay = BOWL_DELAY;
		# Bowl after BOWL_DELAY
		if ((bowlDelay >= BOWL_DELAY) and 
			(bowlState != 3)):
				bowl_bowling_ball();
		# Wait for POST_BOWL_DELAY to continue movement
		elif (bowlDelay > (BOWL_DELAY + POST_BOWL_DELAY)):
			bowlState = 0;
			bowlPower = 0;
	else: 
		bowlDelay = 0;
		
	# Update Movement
	update_direction(velocity);
	update_sprite();
	if (sliding):
		update_sliding(delta)
	else:
		# Moving is only allowed when not bowling
		if (bowlState == 0):
			update_velocity(SPEED, get_axis(), delta);

