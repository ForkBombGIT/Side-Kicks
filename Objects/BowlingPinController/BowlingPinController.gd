extends Node2D

onready var bowlingPinScene = load("res://Objects/BowlingPin/BowlingPin.tscn");

var levelId;
var pinLevel = 0;
var totalPinCount = 0;
var colors = [];
var pins = {};
var pinProgression = [5];
var colorSpawnTime = {};
var spawnRanges = [ # [LevelId] 0 - x
	[ # [Placement Position Index] 0 - 3
		[ # [X1,X2],[Y]
			[200,260],[80]
		],
		[ # [X1,X2],[Y]
			[200,260],[388]
		],
		[ # [X],[Y1,Y2]
			[80],[100,228]
		],
		[ # [X],[Y1,Y2]
			[580],[100,228]
		]
	]
];
var spawnDelay = 180;

func set_level_id(id):
	levelId = id;
	
func set_colors(colors):
	self.colors = colors;

# Generates random position for pin to spawn at
func generate_pin_position():
	var placementPos = randi() % 4;
	var xPositions = spawnRanges[levelId][placementPos][0];
	var yPositions = spawnRanges[levelId][placementPos][1];
	var randomX;
	var randomY;
	if (xPositions.size() > 1): 
		randomX = randi() % xPositions[1] + xPositions[0];
	else: randomX = xPositions[0]
	if (yPositions.size() > 1):
		randomY = randi() % yPositions[1] + yPositions[0];
	else: randomY = yPositions[0]
	
	print(Vector2(randomX,randomY))
	return Vector2(randomX,randomY);

# Spawns BowlingPin for player corresponding to color
func spawn_pin(color):
	randomize()
	var pin = bowlingPinScene.instance();
	pin.set_color(color);
	pin.position = generate_pin_position();
	get_parent().add_child(pin);
	pins[color].append(pin);
	totalPinCount += 1;
	colorSpawnTime[color] = 0;
	
# Called when the node enters the scene tree for the first time.
func _ready():
	for c in colors:
		pins[c] = [];
		colorSpawnTime[c] = 0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match(levelId):
		0: # Level_0
			for c in colors:
				colorSpawnTime[c] += delta;
				if (colorSpawnTime[c] >= spawnDelay / 60.0):
					if (pins[c].size() <= pinProgression[pinLevel] - 1):
						spawn_pin(c);
	
	# Check if any pins have been hit, and removed
	# if it has, remove it from the pins list
	var currentPinCount = get_tree().get_nodes_in_group("Pin").size();
	if (totalPinCount != currentPinCount):
		for c in colors:
			for i in range(pins[c].size()):
				if !(is_instance_valid(pins[c][0])):
					pins[c].remove(0);
					totalPinCount -= 1;
				
