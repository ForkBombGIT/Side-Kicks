using Godot;
using System;

public class Player : KinematicBody2D
{
	private const int Speed = 15;
	private const int SpeedMultiplier = 1000;
	private AnimatedSprite sprite;
	private Vector2 velocity;
	private Tuple<String,Vector2> direction;
	private PackedScene bowlingBallScene;
	
		// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		// Initialize Velocity Vector
		velocity = new Vector2();
		//Initialize direction tuple
		direction = new Tuple<String,Vector2>("f",Vector2.Down);
		//Initialize sprite
		sprite = GetNode<AnimatedSprite>("AnimatedSprite");
		bowlingBallScene = GD.Load<PackedScene>("res://Objects/BowlingBall/BowlingBall.tscn");
	}
	
	// Determine Axis vector, contains direction based on user input
	public Vector2 GetAxis() {
		Vector2 axis = Vector2.Zero;
		axis.x = Convert.ToInt32(Input.IsActionPressed("ui_right")) - Convert.ToInt32(Input.IsActionPressed("ui_left"));
		axis.y = Convert.ToInt32(Input.IsActionPressed("ui_down")) - Convert.ToInt32(Input.IsActionPressed("ui_up"));
		return axis.Normalized();
	}
	
	// Apply updated movement to velocity
	public void UpdateVelocity(float v) {
		Vector2 axis = GetAxis();
		velocity = axis * v;
		velocity = MoveAndSlide(velocity.Clamped(Speed * SpeedMultiplier));
	}
	
	public void UpdateDirection() {
		var dir = velocity.Normalized();
		// Dot Product of two vectors being near 1 essentially means the two
		// vectors are pointing in the same direction
		if (dir.Dot((Vector2.Right + Vector2.Down).Normalized()) > 0.99) {
			direction = Tuple.Create("fr",dir);
		} else if (dir.Dot((Vector2.Right + Vector2.Up).Normalized()) > 0.99) {
			direction = Tuple.Create("br",dir);
		} else if (dir.Dot((Vector2.Left + Vector2.Down).Normalized()) > 0.99) {
			direction = Tuple.Create("fl",dir);
		} else if (dir.Dot((Vector2.Left + Vector2.Up).Normalized()) > 0.99) {
			direction = Tuple.Create("bl",dir);
		} else if (dir.Dot(Vector2.Left) > 0.99) {
			direction = Tuple.Create("l",dir);
		} else if (dir.Dot(Vector2.Right) > 0.99) {
			direction = Tuple.Create("r",dir);
		} else if (dir.Dot(Vector2.Up) > 0.99) {
			direction = Tuple.Create("b",dir);
		} else if (dir.Dot(Vector2.Down) > 0.99) {
			direction = Tuple.Create("f",dir);
		} 
	}
	
	public void UpdateSprite() {
		sprite.Play($"idle_{direction.Item1}");
	}
	
	public void ThrowBowlingBall() {
		BowlingBall bowlingBall = (BowlingBall) bowlingBallScene.Instance();
		bowlingBall.Position = Position;
		bowlingBall.SetDirection(direction.Item2);
		GetParent().AddChild(bowlingBall);
	}
	
	// Called at the beginning of each physics step
	public override void _PhysicsProcess(float delta) {
		// Movement
		UpdateVelocity(Speed * delta * SpeedMultiplier);
		UpdateDirection();
		UpdateSprite();
		
		if (Input.IsActionJustPressed("ui_accept"))
		{
			ThrowBowlingBall();
		}
	}
}
