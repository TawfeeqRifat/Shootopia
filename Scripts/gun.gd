extends RigidBody2D

@onready var pick_up_prompt: Polygon2D = $PickUpPrompt
@onready var collision: CollisionPolygon2D = $CollisionPolygon2D
@onready var bullet_position: Node2D = $BulletPosition
@onready var fire_effect: CPUParticles2D = $fireEffect
@onready var detector_collision: CollisionPolygon2D = $detecter/detectorCollision

#SFX 
@onready var shoot_sfx: AudioStreamPlayer2D = $ShootSFX
@onready var empty_gun: AudioStreamPlayer2D = $EmptyGun
@onready var reload_gun: AudioStreamPlayer2D = $ReloadGun

@export var equipped = false
@export var BULLET_SPEED: float = 900
@export var recoil_val: float = 10
@export var reloadTime: float = 1
@onready var reload_timer: Timer = $reloadTimer
@onready var shooting_timer: Timer = $shootingTimer

@onready var gun_sprite: Node2D = $Gun_Sprite

# for tracking total number of bullets in the bullet and the curent available bullets
@onready var total_bullets: int = 6
var cur_available_bullets: int

var state = "idle"
#idle, shooting, reloading
func _ready() -> void:
	reload_timer.wait_time = reloadTime
	cur_available_bullets = total_bullets
func equip():
	print("gun -- equiping")
	equipped = true
	pick_up_prompt.visible = false
	collision.disabled = true

func shoot(dir,gunAngle) -> bool:
	if equipped and state == "idle":
		if cur_available_bullets > 0:
			state = "shooting"
			shoot_sfx.play()
			shooting_timer.start()
			var b = Global.BULLET.instantiate()
			b.rotation_degrees = gunAngle * dir
			b.scale.x =  1 * dir #inverting the bullet for left side view
			get_parent().add_child(b)
			b.global_position = bullet_position.global_position
			b.apply_central_impulse(Vector2(BULLET_SPEED * bullet_position.get_global_transform()[0][0],BULLET_SPEED * bullet_position.get_global_transform()[0][1]))
			fire_effect.emitting = true
			
			#recoil
			print(get_viewport().get_mouse_position())
			Input.warp_mouse(get_viewport().get_mouse_position() + Vector2(0,-recoil_val))
			print(get_viewport().get_mouse_position())
			#removing the used bullet
			cur_available_bullets -= 1
			return true
		else:
			print("Reload")
			empty_gun.play()
	return false

func _on_shooting_timer_timeout() -> void:
	state = "idle"

func reload() -> bool:
	if cur_available_bullets < total_bullets and state == "idle":
		print("reloading")
		state = "reloading"
		reload_gun.play()
		reload_timer.start()
		create_tween().tween_property(gun_sprite,"rotation_degrees",720,reloadTime)
		gun_sprite.rotation_degrees = 0
		await create_tween().tween_property(gun_sprite,"position",Vector2(0 ,gun_sprite.position.y - 100),reloadTime/2).finished
		await create_tween().tween_property(gun_sprite,"position",Vector2(0 ,gun_sprite.position.y),reloadTime * 1 / 8).finished
		create_tween().tween_property(gun_sprite,"position",Vector2(0,gun_sprite.position.y + 100),reloadTime * 3 / 8)
		return true
	
	print("Bullets full")
	return false
	
func throw(dir):
	equipped = false
	#pick_up_prompt.visible = true
	#apply_central_impulse(Vector2(900 * bullet_position.get_global_transform()[0][0] * dir, -1000 * bullet_position.get_global_transform()[0][1]))
	apply_impulse(Vector2(600 * dir,-600))
	collision.disabled = false
	detector_collision.disabled = false
	collision.disabled = false
	
	print(detector_collision.disabled)
#functionality for gun hit
func _on_detecter_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not detector_collision.disabled:
		body.health -= 20
		detector_collision.disabled = true
	elif body.is_in_group("ground") or body.name == "StaticBody2D":
		detector_collision.disabled = true
func _on_reload_timer_timeout() -> void:
	cur_available_bullets = total_bullets
	state = "idle"
