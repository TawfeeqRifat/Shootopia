extends RigidBody2D

@onready var bullet_spread: CPUParticles2D = $bulletSpread
@onready var hit_timer: Timer = $hitTimer
@onready var bullet_drawing: Polygon2D = $Polygon2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var detecter: Area2D = $detecter

var has_hit = false # for enemy object to know if the bullet has already been hit
@export var damage = 10
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("ground") or body.name == "StaticBody2D":
		hit()
	elif body.is_in_group("enemy"):
		#body.health -= 20
		#hit()
		pass
	elif not body.is_in_group("player") and not body.is_in_group("attack"):
		hit()

func hit():
	bullet_spread.emitting = true
	bullet_drawing.visible = false
	collision_polygon_2d.disabled = true
	detecter.monitoring = false
	hit_timer.start(1)
	
func _on_hit_timer_timeout() -> void:
	queue_free()


func _on_lifetime_timeout() -> void:
	hit()
