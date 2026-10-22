extends Control

@onready var menu_toggle: Button = $MenuToggle
@onready var menu_panel: Panel = $MenuPanel
@onready var inventory_panel: Panel = $InventoryPanel
@onready var grid_container: GridContainer = $InventoryPanel/MarginContainer/ScrollContainer/GridContainer
@onready var merchant_panel: Panel = $MerchantPanel

@export var slot_prefab: PackedScene

var toggled = false
var inv_toggled = false
var in_merchant = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Inventory Open"):
		if toggled == true:
			menu_toggle_func()
		inv_toggle()

func _on_menu_toggle_pressed() -> void:
	if !inv_toggled && !in_merchant:
		menu_toggle_func()

func menu_toggle_func():
	toggled = true if toggled == false else false
	match toggled:
		true:
			var button_tween = create_tween()
			var menu_tween = create_tween()
			menu_toggle.text = "<"
			button_tween.set_parallel().tween_property(menu_toggle, "position", Vector2(menu_toggle.position.x + 217, menu_toggle.position.y), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			menu_tween.set_parallel().tween_property(menu_panel, "position", Vector2(menu_panel.position.x + 217, menu_panel.position.y), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		
		false:
			var button_tween = create_tween()
			var menu_tween = create_tween()
			menu_toggle.text = ">"
			button_tween.set_parallel().tween_property(menu_toggle, "position", Vector2(menu_toggle.position.x - 217, menu_toggle.position.y), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			menu_tween.set_parallel().tween_property(menu_panel, "position", Vector2(menu_panel.position.x - 217, menu_panel.position.y), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func inv_toggle():
	inv_toggled = true if inv_toggled == false else false
	match inv_toggled:
		true:
			inventory_panel.visible = true
			refresh_inv()
		false:
			inventory_panel.visible = false

func refresh_inv():
	for j in grid_container.get_children():
		j.queue_free()
	
	for i in InventoryManager.fish_inv:
		var slot = slot_prefab.instantiate()
		slot.resource = i
		grid_container.add_child(slot)
		
		slot.text = i.name
		slot.get_node("WeightLabel").text = str(i.weight) + " kg"

func _on_inventory_pressed() -> void:
	if toggled:
		menu_toggle_func()
	inv_toggle()

func toggle_merchant() -> void:
	in_merchant = true if in_merchant == false else false
	match in_merchant:
		true:
			menu_toggle_func()
			var tween = create_tween()
			
			tween.set_parallel().tween_property(merchant_panel, "position", Vector2(merchant_panel.position.x, 81), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		false:
			var tween = create_tween()
			
			tween.set_parallel().tween_property(merchant_panel, "position", Vector2(merchant_panel.position.x, -546), 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)


func _on_merchant_pressed() -> void:
	toggle_merchant()

func _on_merchant_close_pressed() -> void:
	toggle_merchant()
