extends Node

onready var playerScene = load("res://Objects/Player/Player.tscn");
onready var bowlingPinControllerScene = load("res://Objects/BowlingPinController/BowlingPinController.tscn");

var players = [];

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_1 = playerScene.instance();
	player_1.set_id(1);
	player_1.set_color("red");
	player_1.position = Vector2(155,192);
	
	#var player_2 = playerScene.instance();
	#player_2.set_id(2);
	#player_2.set_color("blue");
	#player_2.position = Vector2(255,192);
	
	players.append(player_1);
	#players.append(player_2);
	
	var playerColors = [];
	for p in players:
		add_child(p);
		playerColors.append(p.color);
	
	var bowlingPinController = bowlingPinControllerScene.instance();
	bowlingPinController.set_colors(playerColors);
	bowlingPinController.set_level_id(0);
	
	add_child(bowlingPinController);


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
