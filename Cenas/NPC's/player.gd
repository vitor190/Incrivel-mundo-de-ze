extends CharacterBody2D

# Esta linha cria um checkbox no Inspetor do Godot
@export var pode_interagir: bool = true 

@onready var sprite: AnimatedSprite2D = $PlayerSprite
@onready var area_interacao: Area2D = $AreaInteracao

var jogador_por_perto: bool = false
var jogador_node: Node2D = null

func _ready() -> void:
	sprite.play("idle_frente") 
	area_interacao.body_entered.connect(_on_area_interacao_body_entered)
	area_interacao.body_exited.connect(_on_area_interacao_body_exited)

func _process(_delta: float) -> void:
	if jogador_por_perto and jogador_node != null:
		var vetor_distancia = jogador_node.global_position - global_position
		
		if abs(vetor_distancia.x) > abs(vetor_distancia.y):
			sprite.play("idle")
			if vetor_distancia.x < 0:
				sprite.flip_h = true  
			else:
				sprite.flip_h = false 
		else:
			if vetor_distancia.y < 0:
				sprite.play("idle_costa") 
			else:
				sprite.play("idle_frente") 
	
	# AGORA CHECAMOS A VARIÁVEL: Só inicia o diálogo se "pode_interagir" for true
	if pode_interagir and jogador_por_perto and Input.is_key_pressed(KEY_E):
		iniciar_dialogo()

func _on_area_interacao_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"): 
		jogador_por_perto = true
		jogador_node = body

func _on_area_interacao_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		jogador_por_perto = false
		jogador_node = null
		sprite.play("idle_frente")
		sprite.flip_h = false

func iniciar_dialogo() -> void:
	print("E aí, Zé! A aula no Bloco C já vai começar.")
