## campus.gd

extends Node2D

@onready var spawn_point = $carros/SpawnPoint
var carro_scene = preload("res://Cenas/Carro.tscn")

func _ready():
	GerenciadorMissoes.set_cena("campus")

func _on_timer_timeout():
	var carro = carro_scene.instantiate()
	carro.position = spawn_point.position
	carro.velocidade = randf_range(200, 500)
	carro.position.y += randi_range(-40, 40)
	add_child(carro)
