extends KinematicBody

onready var doJumpTimer = $doJump
onready var animSprites = $Sprites
onready var forceShieldNode = $ForceShield
onready var cameraPointNode = get_node("/root/World/CameraPoint")
onready var realCameraNode = get_node("/root/World/InterpolatedCamera")

export var gravity : float = 9.8
export var jumpForce = -400.0
export var xVelocity = 200.0
var velocity : Vector3

func _input(_event):
	if Input.is_action_just_pressed("Jump"):
		doJumpTimer.start()

func _process(_delta):
	if is_on_floor():
		if abs(velocity.y) <= 20:
			velocity.y = 0.0
			if animSprites.animation == "Fall":
				animSprites.play("Idle")
		
		if doJumpTimer.time_left > 0.0:
			velocity.y = 0.0
			velocity.y += jumpForce
			animSprites.play("Jump")
		
		if Input.is_action_pressed("Attack") and velocity.x == 0:
			animSprites.play("Attack")
		if !Input.is_action_pressed("Attack") and animSprites.animation == "Attack":
			animSprites.play("Idle")
	else:
		if velocity.y > 0.0:
			if Input.is_action_just_released("Jump"):
				velocity.y = velocity.y / 2.0
		elif velocity.y < 0.0:
			animSprites.play("Fall")
		velocity.y += gravity
	
	if animSprites.animation != "Attack":
		#Horizontal Movement
		velocity.x = (-Input.get_action_strength("Left") + Input.get_action_strength("Right")) * xVelocity
		velocity.z = (-Input.get_action_strength("Forward") + Input.get_action_strength("Back")) * xVelocity
		#flip sprite
		if velocity.x != 0 or velocity.z != 0:
			animSprites.flip_h = (velocity.x < 0)
			if !(animSprites.animation == "Jump" or animSprites.animation == "Fall"):
				animSprites.play("Run")
		else:
			if !(animSprites.animation == "Jump" or animSprites.animation == "Fall"):
				animSprites.play("Idle")
	
	if Input.is_action_just_pressed("Shield"):
		_toogleShield()
	if Input.is_action_just_pressed("DTrigger"):
		_toogleD()
	
	move_and_slide(velocity, Vector3.UP)
	
	if realCameraNode.projection == 0:
		cameraPointNode.translation = translation + Vector3(0, 3, 8)
		cameraPointNode.translation = Vector3( \
				clamp(cameraPointNode.translation.x, -10, 10), \
				cameraPointNode.translation.y, \
				clamp(cameraPointNode.translation.z, -12, 12))
		if abs(cameraPointNode.translation.z) == 12 or abs(cameraPointNode.translation.x) == 10:
			cameraPointNode.look_at(translation, Vector3.UP)
	elif realCameraNode.projection == 1:
		cameraPointNode.translation = Vector3(translation.x, translation.y, 16)
		cameraPointNode.translation = Vector3( \
				clamp(cameraPointNode.translation.x, -9.4, 9.4), \
				clamp(cameraPointNode.translation.y, 3, 20), \
				cameraPointNode.translation.z)

func _toogleShield():
	forceShieldNode.visible = !forceShieldNode.visible

func _toogleD():
	realCameraNode.projection = 1 if realCameraNode.projection == 0 else 0
	if realCameraNode.projection == 1:
		cameraPointNode.translation = Vector3(cameraPointNode.translation.x, 3, 16)
		cameraPointNode.rotation_degrees = Vector3(0, 0, 0)
	elif realCameraNode.projection == 0:
		cameraPointNode.translation = translation + Vector3(0, 3, 8)
		cameraPointNode.rotation_degrees = Vector3(-15, 0, 0)
