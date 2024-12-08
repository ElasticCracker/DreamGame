extends TextureRect

var itemIcon;
var itemName;
var itemSlot;
var picked = false;
var basePosition= null

func _init(itemName, itemTexture, itemSlot, itemValue):
	name = itemName;
	self.itemName = itemName;
	texture = itemTexture;
	hint_tooltip = "Name: %s\n\nValue: %d" % [itemName, itemValue];
	self.itemSlot = itemSlot;
	mouse_filter = Control.MOUSE_FILTER_PASS;
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND;
#	print(rect_global_position)
	pass
	
func pickItem():
	mouse_filter = Control.MOUSE_FILTER_IGNORE;
	picked = true;
	pass
	
func putItem():
	rect_global_position = get_node("/root/Inventory_Node/Panel").rect_global_position;
	print(rect_global_position)
	mouse_filter = Control.MOUSE_FILTER_PASS;
	picked = false;
	pass