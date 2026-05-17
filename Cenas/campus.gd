extends Node2D

@onready var spawn_point = $carros/SpawnPoint

var carro_scene = preload("res://carro.tscn")

func _on_timer_timeout():

	var carro = carro_scene.instantiate()

	# posição inicial
	carro.position = spawn_point.position

	# velocidade aleatória
	carro.velocidade = randf_range(200, 500)

	# muda altura aleatoriamente
	carro.position.y += randi_range(-40, 40)

	add_child(carro)
