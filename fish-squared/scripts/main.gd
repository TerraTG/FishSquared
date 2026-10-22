extends Node2D

#Resources
@export_category("Resources")
@export var mainList: FishListList;

#Imported Nodes
@onready var shake_button: Button = $CastButton;
@onready var spawn_box: Control = $SpawnBox;
@onready var buttons: Node = $Buttons;

#Prefabs
@export_category("Prefabs")
@export var button_prefab: PackedScene;
@export var reeling_minigame_prefab: PackedScene;

#State Machine Variables
enum FishingState {IDLE, CASTING, REELING, CAUGHT, FAILED};
var currentState;

#Resource Variables
var selected_rarity = Global.determine_rarity();
var rarityList = null;
var fish = null;

#Misc
var cast = false;
var cutscene = false;

func _ready() -> void:
	shake_button.visible = true;
	currentState = FishingState.IDLE;

func _process(_delta: float) -> void:
	match currentState:
		FishingState.IDLE:
			shake_button.visible = true;
			if cast == true:
				cast = false;
				pick_a_fish();
				shake_button.visible = false;
				currentState = FishingState.CASTING;
		FishingState.CASTING:
			if Global.can_spawn_button:
				spawn_a_button();
			if Global.shake_meter >= fish.shake_amount:
				for i in buttons.get_children():
					i.queue_free();
				
				Global.can_spawn_button = true;
				currentState = FishingState.REELING;
		FishingState.REELING:
			if Global.can_spawn_button:
				var b = reeling_minigame_prefab.instantiate();
				b.get_child(0).resistance = fish.resistance;
				b.get_child(0).speed = fish.speed;
				b.get_child(0).min_move = fish.move_min;
				b.get_child(0).max_move = fish.move_max;
				add_child(b);
				Global.can_spawn_button = false;
			if Global.reeling != "":
				match Global.reeling:
					"Win":
						currentState = FishingState.CAUGHT;
					"Lose":
						currentState = FishingState.FAILED;
		FishingState.CAUGHT:
			if !cutscene:
				cutscene = true
				var new_fish = fish.duplicate()
				calculate_fish_values(new_fish)
				Global.catch_meter = 25;
				Global.shake_meter = 0;
				Global.can_spawn_button = true;
				Global.reeling = "";
				await get_tree().create_timer(1).timeout
				cutscene = false
				currentState = FishingState.IDLE;
		FishingState.FAILED:
			if !cutscene:
				cutscene = true
				Global.catch_meter = 25;
				Global.shake_meter = 0;
				Global.can_spawn_button = true;
				Global.reeling = "";
				await get_tree().create_timer(1).timeout
				cutscene = false
				currentState = FishingState.IDLE;
			

func spawn_a_button():
	Global.can_spawn_button = false;
	
	var pos_x = randf_range(spawn_box.position.x, spawn_box.position.x + spawn_box.size.x);
	var pos_y = randf_range(spawn_box.position.y, spawn_box.position.y + spawn_box.size.y);
	
	var b = button_prefab.instantiate();
	b.position = Vector2(pos_x, pos_y);
	buttons.add_child(b);

func _on_button_pressed() -> void:
	cast = true;

func pick_a_fish():
	selected_rarity = Global.determine_rarity();
	rarityList = mainList.list[selected_rarity];
	fish = rarityList.list[randi_range(0, rarityList.list.size() - 1)];

func get_weight(val: float) -> float:
	return snapped(val, 0.01)

func calculate_fish_values(new_fish: FishResource):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	new_fish.weight = get_weight(rng.randf_range(new_fish.min_weight, new_fish.max_weight))
	new_fish.value = ceil(new_fish.value_per_kg * new_fish.weight);
	InventoryManager.add_fish(new_fish)
