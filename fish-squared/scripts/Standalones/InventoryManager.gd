extends Node
signal inventory_updated

var fish_inv: Array[FishResource] = []

func add_fish(fish: FishResource) -> void:
	fish_inv.append(fish)
	inventory_updated.emit()
