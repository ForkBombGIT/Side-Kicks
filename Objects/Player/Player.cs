using Godot;
using System;

public class Player : KinematicBody2D
{
	private const int MaxSpeed = 24;
	private const int SpeedMultiplier = 1000;
	private Vector2 velocity;
	
	// Determine Axis vector, contains direction based on user input
	public Vector2 GetAxis() {
		Vector2 axis = Vector2.Zero;
		axis.x = Convert.ToInt32(Input.IsActionPressed("ui_right")) - Convert.ToInt32(Input.IsActionPressed("ui_left"));
		axis.y = Convert.ToInt32(Input.IsActionPressed("ui_down")) - Convert.ToInt32(Input.IsActionPressed("ui_up"));
		return axis.Normalized();
	}
	
	// Apply updated movement to velocity
	public void ApplyMovement(float movement) {
		Vector2 axis = GetAxis();
		velocity = axis * movement;
		velocity = MoveAndSlide(velocity.Clamped(MaxSpeed * SpeedMultiplier));
	}
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		// Initialize Velocity Vector
		velocity = new Vector2();
	}
	// Called at the beginning of each physics step
	public override void _PhysicsProcess(float delta) {
		ApplyMovement(MaxSpeed * delta * SpeedMultiplier);
	}
}
