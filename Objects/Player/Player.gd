extends KinematicBody2D

const SPEED = 15;
const SPEED_MULTIPLIER = 1000;
var velocity;
var sprite;
var direction;
var bowlingBallScene;


# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize Velocity Vector
	velocity = Vector2();
	# Initialize direction dictionary
	direction = {"name": "f", "vector": Vector2(Vector2.DOWN)};
	# Initialize sprite
	sprite = get_node("AnimatedSprite");
	bowlingBallScene = load("res://Objects/BowlingBall/BowlingBall.tscn");

# Determine Axis vector, contains direction based on user input
func get_axis():
	var axis = Vector2.ZERO;
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"));
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"));
	return axis.normalized();

# Apply updated movement to velocity
func update_velocity(v):
	var axis = get_axis();
	velocity = axis * v;
	velocity = move_and_slide(velocity.clamped(SPEED * SPEED_MULTIPLIER));

# Update direction dictionary based on Player input
func update_direction():
	var dir = velocity.normalized();
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
	sprite.play("idle_%s" % direction["name"]);

func throw_bowling_ball():
	var bowlingBall = bowlingBallScene.instance();
	bowlingBall.position = position;
	bowlingBall.set_direction(direction["vector"]);
	get_parent().add_child(bowlingBall);

	
# Called at the beginning of each physics step
func _physics_process(delta):
	# Movement
	update_velocity(SPEED * delta * SPEED_MULTIPLIER);
	update_direction();
	update_sprite();
	
	if (Input.is_action_just_pressed("ui_accept")):
		throw_bowling_ball();

