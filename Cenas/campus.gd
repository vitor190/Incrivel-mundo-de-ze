## campus.gd

extends Node2D

@onready var spawn_point = $carros/SpawnPoint
var carro_scene = preload("res://Cenas/Carro.tscn")

func _ready():
	GerenciadorMissoes.set_cena("campus")
	GerenciadorMissoes.concluir_sub_missao("quarto_acorde", "quarto_mini1")
	GerenciadorMissoes.concluir_sub_missao("quarto_acorde", "quarto_mini2")
	GerenciadorMissoes.concluir_missao("quarto_acorde")
	GerenciadorMissoes.concluir_missao("quarto_sair")
	print("Missões ativas: ", GerenciadorMissoes.get_missoes_ativas())

func _on_timer_timeout():
	var carro = carro_scene.instantiate()
	carro.position = spawn_point.position
	carro.velocidade = randf_range(200, 500)
	carro.position.y += randi_range(-40, 40)
	add_child(carro)
