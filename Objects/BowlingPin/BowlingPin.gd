extends KinematicBody2D

# How long the pin will exist for, in seconds, after colliding
const LIFE_TIME = 0.75;
# Timer controling life of ball
onready var lifeTimer = get_node("LifeTimer");
var velocity;
var hasCollided;
var color;

func set_color(color):
	self.color = color;

func set_velocity(velocity):
	self.velocity = velocity;

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2();
	hasCollided = false;

func _physics_process(delta):
	# Start life timer if pin has been hit
	if (velocity != Vector2.ZERO) and !(hasCollided):
		hasCollided = true;
		lifeTimer.set_wait_time(LIFE_TIME);
		lifeTimer.start();
		lifeTimer.connect("timeout", self, "_on_lifetimer_timeout")
		
	var velocity_before_collision = velocity;
	
	velocity = move_and_slide(velocity); 
	
	# Pin movement, and collisions
	var slide_count = get_slide_count();
	if slide_count:
		var collision = get_slide_collision(slide_count - 1);
		var collider = collision.collider;
		#Pin to pin collision
		if (collider.is_in_group("Pin")):
			if !(collider.hasCollided):
				var pin_position = collider.position;
				var direction = (pin_position - position).normalized();
				collider.set_velocity(direction * velocity_before_collision.length() * 0.9);
		velocity = velocity_before_collision.bounce(collision.normal);

func _on_Area2D_body_entered(body):
	# Bowling Ball Collisions
	if (body.is_in_group("Ball")):
		var body_position = body.position;
		var direction = (body_position - position).normalized();
		velocity = -direction * body.velocity.length() * (body.chargeState * 0.2);

func _on_lifetimer_timeout():
	queue_free();
