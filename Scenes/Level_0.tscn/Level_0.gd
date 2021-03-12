extends Node

onready var playerScene = load("res://Objects/Player/Player.tscn");
onready var bowlingPinControllerScene = load("res://Objects/BowlingPinController/BowlingPinController.tscn");

var players = [];

# Called when the node enters the scene tree for the first time.
func _ready():
	var player = playerScene.instance();
	player.set_id(0);
	player.set_color("red");
	player.position = Vector2(155,192);
	
	players.append(player);
	
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
