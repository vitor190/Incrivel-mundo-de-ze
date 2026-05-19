extends CharacterBody2D

# Cria um sinal para avisar quando a fome mudar
signal fome_alterada(novo_valor)

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var hair_sprite: AnimatedSprite2D = $HairSprite
@onready var tool_sprite: AnimatedSprite2D = $ToolSprite
@onready var cueca: Polygon2D = $Cueca

var movement_enabled: bool = true

# Variáveis de status do jogador
var fome_atual: float = 100.0
# Mudado de 20.0 para 6.0 para a fome diminuir bem mais devagar
var taxa_fome_correndo: float = 6.0 

func _ready():
	add_to_group("player")
	GameState.dressed_changed.connect(_on_dressed_changed)
	_on_dressed_changed(GameState.is_dressed)
	# Avisa o valor inicial da fome assim que o jogo começa
	fome_alterada.emit(fome_atual)

func _on_dressed_changed(value: bool) -> void:
	if tool_sprite:
		tool_sprite.visible = value
	if cueca:
		cueca.visible = not value

func _process(delta: float) -> void:
	if not movement_enabled:
		player_sprite.play("Idle")
		hair_sprite.play("Idle")
		tool_sprite.play("Idle")
		return
	var moving = Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_D)
	
	if moving:
		# Só corre se o Shift estiver pressionado E se ele ainda tiver fome
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
	if not movement_enabled:
		velocity = Vector2.ZERO
		return
	var speed = 50.0
	var is_running = false

	# Só ganha velocidade de corrida se segurar Shift E tiver fome
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
	
	# Lógica de gastar energia (Fome)
	if is_running and velocity != Vector2.ZERO:
		fome_atual -= taxa_fome_correndo * delta
		fome_atual = clamp(fome_atual, 0.0, 100.0) # Garante que não fique menor que 0

		# Dispara o sinal para atualizar a interface
		fome_alterada.emit(fome_atual)


# Stubs para os signal connections herdados de campus.tscn — body_entered de
# PortaC/PortaD chama esses métodos no player. A lógica de transição vive em
# porta_c.gd / porta_d.gd, então aqui é só no-op.
func _on_porta_body_entered(_body: Node2D) -> void:
	pass

func _on_porta_d_body_entered(_body: Node2D) -> void:
	pass
