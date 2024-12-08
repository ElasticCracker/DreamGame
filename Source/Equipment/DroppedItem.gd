extends Area2D


var itemName = ""
var itemValue = 0 
var canBePickedUp = false #Prevents the item from being instantly picked up (set on timer)

func dropped(inpTexture,inpName, location):
#	rpc('droppedNetwork',inpTexture, inpName, location)
	pass
sync func droppedNetwork(inpTexture,inpName, location):
	$Sprite.texture = inpTexture
	itemName= inpName
	position=location
	
sync func pickedUp():
	queue_free()
	
func _on_DroppedItem_body_entered(body):
	if canBePickedUp ==true:
		if body.has_method("walked_in_range_of_dropped_item"):
			body.walked_in_range_of_dropped_item(itemName)
			rpc("pickedUp")
			


func _on_Timer_timeout():
	canBePickedUp = true # Replace with function body.
