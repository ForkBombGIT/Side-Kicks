extends Node2D

onready var bowlingPinScene = load("res://Objects/BowlingPin/BowlingPin.tscn");

var levelId;
var pinLevel = 0;
var totalPinCount = 0;
var colors = [];
var pins = {};
var pinProgression = [100];
var spawnDelay = 60;
var colorSpawnTime = {};
var spawnRanges = [ # [LevelId] 0 - x
	[ # [Placement Position Index] 0 - 3
		[ # [X1,X2 - X1],[Y]
			[210,236],[64]
		],
		[ # [X1,X2 - X1],[Y]
			[210,236],[398]
		],
		[ # [X],[Y1,Y2 - Y1]
			[70],[120,236]
		],
		[ # [X],[Y1,Y2 - Y1]
			[590],[120,236]
		]
	]
];

func set_level_id(id):
	levelId = id;
	
func set_colors(colors):
	self.colors = colors;

# Generates random position for pin to spawn at
func generate_pin_position(generationAttempt):
	if generationAttempt > 5: 
		return Vector2(-1,-1)
	var placementPos = randi() % spawnRanges[levelId].size();
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
	
	for node in get_tree().get_nodes_in_group("Pin"):
		if node.position.distance_to(Vector2(randomX,randomY)) < 20:
			return generate_pin_position(generationAttempt + 1);
	return Vector2(randomX,randomY);

# Spawns BowlingPin for player corresponding to color
func spawn_pin(color):
	randomize()
	var pin = bowlingPinScene.instance();
	pin.set_color(color);
	pin.position = generate_pin_position(0);
	colorSpawnTime[color] = 0;
	if (pin.position == Vector2(-1,-1)):
		pin.queue_free();
		return;
	get_parent().add_child(pin);
	pins[color].append(pin);
	totalPinCount += 1;
	
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
						colorSpawnTime[c] = 0;
	
	# Check if any pins have been hit, and removed
	# if it has, remove it from the pins list
	var currentPinCount = get_tree().get_nodes_in_group("Pin").size();
	if (totalPinCount != currentPinCount):
		for color in colors:
			var temp = []
			for pin in pins[color]:
				if (is_instance_valid(pin)):
					temp.append(pin);
				else: 
					totalPinCount -= 1;
			pins[color] = temp;
