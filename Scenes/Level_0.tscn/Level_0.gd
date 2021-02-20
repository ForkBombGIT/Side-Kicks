extends Node

onready var playerScene = load("res://Objects/Player/Player.tscn");

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_0 = playerScene.instance();
	player_0.set_id(0);
	player_0.position = Vector2(155,192);
	
	var player_1 = playerScene.instance();
	player_1.set_id(1);
	player_1.position = Vector2(192,192);
	
	var player_2 = playerScene.instance();
	player_2.set_id(2);
	player_2.position = Vector2(100,155);
	
	add_child(player_0);
	add_child(player_1);
	add_child(player_2);


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
