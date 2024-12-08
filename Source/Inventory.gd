extends GridContainer;
const ItemClass = preload("res://Source/Item.gd");
const ItemSlotClass = preload("res://Source/ItemSlot.gd");
const DroppedItemScene= preload ("res://Source/Equipment/DroppedItem.tscn")
const slotTexture = preload("res://GUI_STUFF/Images/GuiBase.png");
const itemImages = [
	preload("res://Images/Sprites/Spear.png"),
	preload("res://Images/Sprites/Pickaxe.png"),
	preload("res://Images/Sprites/Grenade.png"),
	preload("res://Images/Sprites/Hatchet.png")
];

const itemDictionary = {
	0: {
		"itemName": "Spear",
		"itemValue": 1,
		"itemIcon": itemImages[0]
	},
	1: {
		"itemName": "Pickaxe",
		"itemValue": 2,
		"itemIcon": itemImages[1]
	},
	2: {
		"itemName": "Grenade",
		"itemValue": 3,
		"itemIcon": itemImages[2]
	},
	3: {
		"itemName": "Hatchet",
		"itemValue": 3,
		"itemIcon": itemImages[3]
	},
};

var slotList = Array();
var itemList = Array();
var player = null
var holdingItem = null;

func _ready():
		var playerID= get_tree().get_network_unique_id()
		player = get_node("/root/Main/players/"+ str(playerID))
		for item in itemDictionary:
			var itemName = itemDictionary[item].itemName;
			var itemIcon = itemDictionary[item].itemIcon;
			var itemValue = itemDictionary[item].itemValue;
			itemList.append(ItemClass.new(itemName, itemIcon, null, itemValue));

		for i in range(5):
			var slot = ItemSlotClass.new(i);
			slotList.append(slot);
			add_child(slot);

	#	print ("Setting Items in Inventory")
		slotList[0].setItem(itemList[0]);
		slotList[1].setItem(itemList[1]);
		slotList[2].setItem(itemList[2]);
	


func _process(delta):
	if holdingItem != null && holdingItem.picked:
		holdingItem.rect_global_position =  get_global_mouse_position()

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_Q and holdingItem != null:
			var drop = DroppedItemScene.instance()
			var dPosition= player.position
			drop.dropped(holdingItem.texture,holdingItem.itemName, dPosition)
			rpc('_Network_dropItem',drop,dPosition,holdingItem.texture,holdingItem.itemName)
			get_parent().remove_child(holdingItem);
			holdingItem=null
			
	pass
		

sync func _Network_dropItem(droppedItem,droppedItemPosition,droppedItemTexture,droppedItemName):
#			print(get_tree().get_root().print_tree_pretty())
			get_tree().get_root().add_child(droppedItem);
			droppedItem.dropped(droppedItemTexture,droppedItemName, droppedItemPosition)
#			print(print_tree_pretty())

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		var clickedSlot;
		for slot in slotList:
			var slotMousePos = slot.get_local_mouse_position();
			var slotTexture = slot.texture;
			var isClicked = slotMousePos.x >= 0 && slotMousePos.x <= slotTexture.get_width() && slotMousePos.y >= 0 && slotMousePos.y <= slotTexture.get_height();
			if isClicked:
				clickedSlot = slot;
		
		if holdingItem == null and clickedSlot == null:
			return;
		
		if clickedSlot == null:
			return;
		if holdingItem != null and clickedSlot == null:
			pass
			
		if holdingItem != null and clickedSlot != null:
			if clickedSlot.item != null:
				var tempItem = clickedSlot.item;
				var oldSlot = slotList[slotList.find(holdingItem.itemSlot)];
				clickedSlot.pickItem();
				clickedSlot.putItem(holdingItem);
				holdingItem = null;
				oldSlot.putItem(tempItem);
			else:
				clickedSlot.putItem(holdingItem);
				holdingItem = null;
		elif clickedSlot.item != null:
			holdingItem = clickedSlot.item;
			print(holdingItem)
			clickedSlot.pickItem();
			holdingItem.rect_global_position = get_global_mouse_position()#Vector2(event.position.x, event.position.y);
	pass

func pickup_item(picked_up_item_name):
#	print("Picked up item =" + picked_up_item_name)d
	if holdingItem==null:
#		print(itemDictionary)
		for i in itemDictionary:
			if picked_up_item_name == (itemDictionary[i].itemName):
				var counter=0
				for slot in slotList:
					if slot.item==null:
						slot.setItem(itemList[i])
						break
					counter += 1

				break
				
#			if itemName == picked_up_item_name:
#				print("yep")
				