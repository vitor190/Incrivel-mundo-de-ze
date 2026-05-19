class_name PlayerScript
extends CharacterBody2D

signal fome_alterada(novo_valor)

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var hair_sprite: AnimatedSprite2D = $HairSprite
@onready var tool_sprite: AnimatedSprite2D = $ToolSprite

var fome_atual: float = 100.0
var taxa_fome_correndo: float = 6.0
static var travado := false

func _ready():
	add_to_group("player")
	fome_alterada.emit(fome_atual)

func _process(delta: float) -> void:
	if travado:
		player_sprite.play("Idle")
		hair_sprite.play("Idle")
		tool_sprite.play("Idle")
		return

	var moving = Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_D)
	
	if moving:
		if Input.is_key_pressed(KEY_SHIFT) and fome_atual > 0.0:
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
	if travado:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var speed = 50.0
	var is_running = false
	
	if Input.is_key_pressed(KEY_SHIFT) and fome_atual > 0.0:
		speed = 80.0
		is_running = true
	
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
	
	if is_running and velocity != Vector2.ZERO:
		fome_atual -= taxa_fome_correndo * delta
		fome_atual = clamp(fome_atual, 0.0, 100.0)
		fome_alterada.emit(fome_atual)
