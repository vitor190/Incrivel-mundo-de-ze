extends CharacterBody2D

signal fome_alterada(novo_valor)

@onready var player_sprite: AnimatedSprite2D = get_node_or_null("PlayerSprite")
@onready var hair_sprite: AnimatedSprite2D = get_node_or_null("HairSprite")
@onready var tool_sprite: AnimatedSprite2D = get_node_or_null("ToolSprite")

var movement_enabled: bool = true

var fome_atual: float = 100.0
var xp_atual: int = 0

var taxa_fome_correndo: float = 6.0


func _ready() -> void:
	add_to_group("player")

	fome_atual = Global.fome
	xp_atual = Global.xp

	var cena_atual: String = get_tree().current_scene.scene_file_path
	var posicao_salva: Vector2 = Global.pegar_posicao(cena_atual)

	if posicao_salva != Vector2.ZERO:
		global_position = posicao_salva

	if tool_sprite:
		tool_sprite.visible = true

	call_deferred("_emitir_fome_inicial")


func _emitir_fome_inicial() -> void:
	fome_alterada.emit(fome_atual)


func _process(_delta: float) -> void:
	if not movement_enabled:
		_play_all("Idle")
		return

	var moving: bool = (
		Input.is_key_pressed(KEY_W)
		or Input.is_key_pressed(KEY_A)
		or Input.is_key_pressed(KEY_S)
		or Input.is_key_pressed(KEY_D)
	)

	if moving:
		if Input.is_key_pressed(KEY_SHIFT) and fome_atual > 0.0:
			_play_all("Run")
		else:
			_play_walk()
	else:
		_play_all("Idle")

	if Input.is_key_pressed(KEY_A):
		_flip_all(true)

	if Input.is_key_pressed(KEY_D):
		_flip_all(false)


func _physics_process(delta: float) -> void:
	if not movement_enabled:
		velocity = Vector2.ZERO
		return

	var speed: float = 50.0
	var is_running: bool = false

	if Input.is_key_pressed(KEY_SHIFT) and fome_atual > 0.0:
		speed = 80.0
		is_running = true

	var direction: Vector2 = Vector2.ZERO

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

		Global.fome = fome_atual
		fome_alterada.emit(fome_atual)


func salvar_progresso(posicao_customizada: Vector2) -> void:
	var cena_atual: String = get_tree().current_scene.scene_file_path

	Global.salvar_estado(
		cena_atual,
		posicao_customizada,
		fome_atual,
		xp_atual
	)


func adicionar_xp(valor: int) -> void:
	xp_atual += valor
	Global.xp = xp_atual


func _play_all(anim_name: String) -> void:
	_play_sprite_animation(player_sprite, anim_name)
	_play_sprite_animation(hair_sprite, anim_name)
	_play_sprite_animation(tool_sprite, anim_name)


func _play_walk() -> void:
	_play_sprite_animation(player_sprite, "Walk")
	_play_sprite_animation(hair_sprite, "Walk")
	_play_sprite_animation(tool_sprite, "Walk")


func _play_sprite_animation(sprite: AnimatedSprite2D, anim_name: String) -> void:
	if not sprite:
		return

	if not sprite.sprite_frames:
		return

	if not sprite.sprite_frames.has_animation(anim_name):
		return

	sprite.play(anim_name)


func _flip_all(value: bool) -> void:
	if player_sprite:
		player_sprite.flip_h = value

	if hair_sprite:
		hair_sprite.flip_h = value

	if tool_sprite:
		tool_sprite.flip_h = value
