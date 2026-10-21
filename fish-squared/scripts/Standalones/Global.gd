extends Node

var can_spawn_button = true;
var shake_meter = 0;
var catch_meter = 25;
var reeling = "";

var rarities = {
	"Uncommon": 5,
	"Rare": 10,
	"Epic": 50,
	"Legendary": 250,
	"Mythic": 1000,
	"Secret": 5000
};

func determine_rarity() -> String:
	for i in rarities.keys():
		if randi_range(1, rarities[i]) == rarities[i]:
			return i;
	return "Common";

func _process(_delta):
	clamp(catch_meter, 0, 100);
