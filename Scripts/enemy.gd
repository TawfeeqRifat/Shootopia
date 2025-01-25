extends CharacterBody2D

@onready var health_bar: ColorRect = $ColorRect

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var health: float = 100:
	set(val):
		health = val
		create_tween().tween_property(health_bar,"scale",Vector2(health/100,1),0.5)
		print(health)
		if health <= 0:
			queue_free()

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()


func _on_attack_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("attack") and not body.has_hit:
		body.has_hit = true
		health -= 2 * body.damage
		body.hit()
		
#Attack Detection---------------------------------------------------------------	

func attacked(body,dmg_per):
	body.has_hit = true
	health -= dmg_per * body.damage
	body.hit()

func _on_body_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("attack") and not body.has_hit:
		attacked(body,2)

func _on_head_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("attack") and not body.has_hit:
		attacked(body,5)


func _on_hand_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("attack") and not body.has_hit:
		attacked(body,1)


func _on_leg_detectors_body_entered(body: Node2D) -> void:
	if body.is_in_group("attack") and not body.has_hit:
		attacked(body,1)


func _on_leg_detectors_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("attack") and not body.has_hit:
		attacked(body,1)
