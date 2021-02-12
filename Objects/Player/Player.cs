using Godot;
using System;

public class Player : KinematicBody2D
{
	private const int MaxSpeed = 25;
	private const int Acceleration = 2500;
	private Vector2 velocity;
	
	// Determine Axis vector, contains direction based on user input
	public Vector2 GetAxis() {
		Vector2 axis = Vector2.Zero;
		axis.x = Convert.ToInt32(Input.IsActionPressed("ui_right")) - Convert.ToInt32(Input.IsActionPressed("ui_left"));
		axis.y = Convert.ToInt32(Input.IsActionPressed("ui_down")) - Convert.ToInt32(Input.IsActionPressed("ui_up"));
		return axis.Normalized();
	}
	
	// Apply friction on moving entity
	public void ApplyFriction(float friction) {
		if (velocity.Length() > friction) {
			velocity -= velocity.Normalized() * friction;
		} else velocity = Vector2.Zero;
	}
	
	// Apply updated movement to velocity
	public void ApplyMovement(Vector2 movement) {
		velocity += movement;
		velocity.Clamped(MaxSpeed);
	}
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		// Initialize Velocity Vector
		velocity = new Vector2();
	}
	// Called at the beginning of each physics step
	public override void _PhysicsProcess(float delta) {
		Vector2 axis = GetAxis();
		if (axis != Vector2.Zero) {
			ApplyMovement(axis * Acceleration * delta);
		} else ApplyFriction(Acceleration * delta);
		velocity = MoveAndSlide(velocity);
	}
}
