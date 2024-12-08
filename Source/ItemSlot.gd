extends TextureRect

var slotIndex;
var item = null;

func _init(slotIndex):
	self.slotIndex = slotIndex;
	name = "ItemSlot_%d" % slotIndex
	texture = preload("res://GUI_STUFF/Images/GuiBase.png");
	mouse_filter = Control.MOUSE_FILTER_PASS;
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND;
	pass
	
func setItem(newItem):
	var addedItem=add_child(newItem)
	item = newItem;
	item.itemSlot = self;
	print(item.rect_global_position)
	item.rect_global_position=rect_global_position
	print(item.rect_global_position)
	pass;
	
func setItemPickup(newItem):
	var addedItem=add_child(newItem)
	item = newItem;
	item.itemSlot = self;
	pass;
	
func pickItem():
	item.pickItem();
	remove_child(item);
	get_parent().get_parent().add_child(item);
	item = null;

func putItem(newItem):
	item = newItem;
	item.itemSlot = self;
	item.putItem();
	get_parent().get_parent().remove_child(item);
	add_child(item);
	pass;
