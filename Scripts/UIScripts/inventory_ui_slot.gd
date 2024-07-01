extends Panel

# Declare some variables
@onready var item_display: Sprite2D = $CenterContainer/Panel/ItemDisplay

# Update the image in the item
func update(item: InvItm) -> void:
	if !item:
		item_display.visible = false
	else:
		item_display.visible = true
		item_display.texture = item.texture
