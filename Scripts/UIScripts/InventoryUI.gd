extends Control

# Declare some variables
@onready var inv: Inv = preload("res://Inventory/items/player_inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	update_slots()
	close()

# Update the number of slots
func update_slots():
	for i in range(min(inv.items.size(), slots.size())):
		slots[i].update(inv.items[i])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Handle the press of the inventory key
	if Input.is_action_just_pressed("toggleInventory"):
		if is_open:
			close()
		else:
			open()

# Handle the opening
func open() -> void:
	visible = true
	is_open = true

# Handle the close 
func close() -> void:
	visible = false
	is_open = false
