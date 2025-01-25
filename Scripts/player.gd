extends CharacterBody2D

@onready var head: Node2D = $head
@onready var gun_position: Node2D = $head/GunPosition
@onready var health_indicator: Label = $PlayerUI/HealthIndicator
@onready var health_bar: ColorRect = $PlayerUI/HealthBar
@onready var character_animation: AnimatedSprite2D = $CharacterAnimation

var animation_state = "idle" #idle, jumpaaaaa
@export var SPEED = 500.0
@export var BackWalkSPEED = 300.0
@export var JUMP_VELOCITY = -500.0

@export var health: float = 100:
	set(val):
		if val >= 0:
			health = val
			health_indicator.text = str(health)
			create_tween().tween_property(health_bar,"scale",Vector2(health/100,1),0.5)

var direction = 1
var curDir = 1 #indicated cur direction
var curRotateDegrees

func _ready() -> void:
	health = 100
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		animation_state = "idle"
	#rotating the head
	curRotateDegrees = curDir * get_angle_to(get_global_mouse_position()) * 180 / PI
	if -80 < curRotateDegrees and curRotateDegrees < 80:
		head.rotation_degrees = curRotateDegrees
	elif curRotateDegrees > 100:
		changedir(-direction)
	elif -100 > curRotateDegrees:
		changedir(-direction)
	#jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		animation_state = "jump"
		character_animation.animation = "jump"
		velocity.y = JUMP_VELOCITY
		
	#movement
	direction = Input.get_axis("left","right")
	if direction:
		if direction == curDir: 
			if animation_state == "idle" : character_animation.animation = "run"
			velocity.x = direction * SPEED
		else:
			#to make back walk slower
			if animation_state == "idle" : character_animation.animation = "walk"
			velocity.x = direction * BackWalkSPEED
	else:
		if animation_state == "idle" : character_animation.animation = "idle"
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func changedir(dir):
	if dir != curDir:
		scale.x = - scale.x
		curDir = - curDir

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("equip") and gunAvailable:
		if CurGun != null:
			gunDrop()
		gunPickUp()
	
	if event.is_action_pressed("shoot") and gunEquipped:
		if CurGun.shoot(curDir,curRotateDegrees):
			#Ui work
			bullet_syms[cur_bullet_index].visible = false
			print(cur_bullet_index,"shot")
			cur_bullet_index -= 1
			
	if event.is_action_pressed("reload") and gunEquipped:
		if await CurGun.reload():
			#UI work
			for syms in bullet_syms:
				syms.visible = true
			cur_bullet_index = CurGun.total_bullets - 1
	
	if event.is_action_pressed("throw") and gunEquipped:
		print("throwing")
		gunDrop()
		
		
#for gun mechanics  --------------------------------------------------------------------------------

# -- pick up --

@onready var gun_remote_transform_position: RemoteTransform2D = $head/GunPosition/GunRemoteTransformPosition
var curAvailableGun
var gunAvailable: bool = false
var gunEquipped : bool = false
var CurGun = null

func _on_pick_up_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("gun"):
		if body.equipped == false:
			print("gun in sight")
			body.pick_up_prompt.visible = true
			curAvailableGun = body
			gunAvailable = true


func _on_pick_up_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("gun"):
		print("gun not in sight")
		body.pick_up_prompt.visible = false
		gunAvailable = false
		curAvailableGun = null
		
@onready var bullet_ui: Node2D = $PlayerUI/BulletUI
@onready var bullet_symbol: Polygon2D = $PlayerUI/bulletSymbol
var bullet_syms = []
var cur_bullet_index = 0# for removing and adding the ui bullets
func gunPickUp():
	print("equipped")
	gun_remote_transform_position.remote_path = curAvailableGun.get_path()
	gunEquipped = true
	CurGun = curAvailableGun
	CurGun.equip()
	curAvailableGun = null
	bullet_ui.visible = true
	var dist = 20
	#bullet_syms.append(bullet_symbol)
	for i in range(0,CurGun.total_bullets):
		var sym = bullet_symbol.duplicate()
		sym.visible = false if i >= CurGun.cur_available_bullets else true
		sym.position.x = bullet_symbol.position.x + dist
		dist += 20
		bullet_ui.add_child(sym)
		bullet_syms.append(sym)
	cur_bullet_index = CurGun.cur_available_bullets - 1
		
@onready var proxy_gun: Node2D = $head/GunPosition/proxyGun

	
func gunDrop():
	CurGun.throw(curDir)
	for n in bullet_ui.get_children():
		n.queue_free()
	bullet_syms.clear()
	gunEquipped = false
	CurGun = null
	gun_remote_transform_position.remote_path = proxy_gun.get_path()
#---------------------------------------------------------------------------------------------------


func _on_timer_timeout() -> void:
	health -= 5
