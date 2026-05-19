extends CharacterBody2D

@export var pode_interagir: bool = true 

@onready var sprite: AnimatedSprite2D = $PlayerSprite
@onready var area_interacao: Area2D = $AreaInteracao

var jogador_por_perto: bool = false
var jogador_node: Node2D = null

func _ready() -> void:
	sprite.animation = "Idle_frente" 
	area_interacao.body_entered.connect(_on_area_interacao_body_entered)
	area_interacao.body_exited.connect(_on_area_interacao_body_exited)

func _process(_delta: float) -> void:
	if jogador_por_perto and jogador_node != null:
		var vetor_distancia = jogador_node.global_position - global_position
		
		if abs(vetor_distancia.x) > abs(vetor_distancia.y):
			sprite.play("Idle")
			if vetor_distancia.x < 0:
				sprite.flip_h = true  
			else:
				sprite.flip_h = false 
				
			print("DEBUG: Eixo Maior é X (Lado). Tentando tocar: 'Idle'")
		else:
			if vetor_distancia.y < 0:
				sprite.play("Idle_costa") 
				print("DEBUG: Eixo Maior é Y (Cima). Tentando tocar: 'Idle_costa'")
			else:
				sprite.play("Idle_frente") 
				print("DEBUG: Eixo Maior é Y (Baixo). Tentando tocar: 'Idle_frente'")
	
	if pode_interagir and jogador_por_perto and Input.is_key_pressed(KEY_E):
		iniciar_dialogo()
	
	if pode_interagir and jogador_por_perto and Input.is_key_pressed(KEY_E):
		iniciar_dialogo()

func _on_area_interacao_body_entered(body: Node2D) -> void:
	# Esse print vai gritar o nome de QUALQUER coisa que encostar na área
	print("🚨 RADAR DETECTOU: ", body.name) 
	
	if body.is_in_group("player"): 
		print("✅ É O ZÉ! PODE OLHAR!")
		jogador_por_perto = true
		jogador_node = body

func _on_area_interacao_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		jogador_por_perto = false
		jogador_node = null
		
		# Força a voltar para frente ao sair
		sprite.animation = "Idle_frente"
		sprite.flip_h = false

func iniciar_dialogo() -> void:
	print("E aí, Zé! A aula no Bloco C já vai começar.")
