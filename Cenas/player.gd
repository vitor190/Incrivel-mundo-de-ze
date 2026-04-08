extends CharacterBody2D

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var hair_sprite: AnimatedSprite2D = $HairSprite
@onready var tool_sprite: AnimatedSprite2D = $ToolSprite

func _process(delta: float) -> void:
	var moving = Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_D)
	
	if moving:
		if Input.is_key_pressed(KEY_SHIFT):
			player_sprite.play("Run")
			hair_sprite.play("Run")
			tool_sprite.play("Run")
		else:
			player_sprite.play("Walk")
			hair_sprite.play("Walk")
			tool_sprite.play("walk")
	else:
		player_sprite.play("Idle")
		hair_sprite.play("Idle")
		tool_sprite.play("Idle")

	if Input.is_key_pressed(KEY_A):
		player_sprite.flip_h = true
		hair_sprite.flip_h = true
		tool_sprite.flip_h = true
		
	if Input.is_key_pressed(KEY_D):
		player_sprite.flip_h = false
		hair_sprite.flip_h = false
		tool_sprite.flip_h = false
		
func _physics_process(delta: float) -> void:
	var speed = 70.0 
	if Input.is_key_pressed(KEY_SHIFT):
		speed = 130.0
	
	var direction = Vector2.ZERO
	
	if Input.is_key_pressed(KEY_W):
		direction.y -= 0.8
	if Input.is_key_pressed(KEY_S):
		direction.y += 0.8
	if Input.is_key_pressed(KEY_A):
		direction.x -= 0.8
	if Input.is_key_pressed(KEY_D):
		direction.x += 0.8
		
	velocity = direction.normalized() * speed
	move_and_slide()
