extends Node2D

@onready var sprite = $carroV

var carros = [
	preload("res://assets/assets - carros/carro vermelho.png"),
	preload("res://assets/assets - carros/carro azul.png"),
	preload("res://assets/assets - carros/carro verde.png"),
	preload("res://assets/assets - carros/cfarro preto.png")
]

@export var velocidade = 165.0

var posicao_inicial_x
var tempo = 0.0
var y_inicial = 0.0

func _ready():

	# escolhe aleatoriamente
	sprite.texture = carros.pick_random()

	posicao_inicial_x = position.x
	y_inicial = position.y

func _process(delta):

	position.x -= velocidade * delta

	tempo += delta

	position.y = y_inicial + sin(tempo * 1.2) * 2

	rotation = sin(tempo * 1.2) * 0.01

	if position.x < -400:
		position.x = posicao_inicial_x
