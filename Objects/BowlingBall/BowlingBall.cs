using Godot;
using System;

public class BowlingBall : KinematicBody2D
{
	private const int Speed = 1000;
	private const int MaxBallDistance = 2000;
	private Vector2 origin;
	private Vector2 direction;
	
	public void SetDirection(Vector2 d) {
		direction = d;
	}
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		origin = Position;	
	}

  // Called every frame. 'delta' is the elapsed time since the previous frame.
  public override void _Process(float delta)
  {
	//
	Vector2 velocity = Speed * direction * delta;
	Position += Position.Normalized() * velocity; 
	// Destroy Bowling Ball if too far from creation coordinate
	if (Position.DistanceTo(origin) > MaxBallDistance) {
		QueueFree();
	}
  }
}
