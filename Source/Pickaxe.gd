extends Area2D

var harvest_available
var target

func _ready():
	set_physics_process(true)
	$AnimationPlayer.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
		
func _physics_process(_delta):
	if is_network_master():
		if Input.is_action_just_pressed("left_click") or Input.is_action_pressed("left_click"):
			rpc('_Animate')
	
		var overlapping_bodies = get_overlapping_bodies()
		if not overlapping_bodies:
			harvest_available=false
		for body in overlapping_bodies:
			if body.is_in_group("Stone"):
				harvest_available = true
				target = body
			return
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if harvest_available:
		target.get_harvested()
		harvest_available = false
		
sync func _Animate():
	get_node("AnimationPlayer").play("pickaxe_anim")
		
