## dados_missoes.gd
extends Node

var missoes = {

	# QUARTO
	"quarto_acorde": {
		"texto": "Acorde e prepare-se",
		"concluida": false,
		"sub_missoes": [
			{"id": "quarto_mini1", "texto": "Desligue o despertador", "concluida": false},
			{"id": "quarto_mini2", "texto": "Vista-se", "concluida": false},
		]
	},
	"quarto_sair": {
		"texto": "Vá para a UNIFOR",
		"concluida": false,
		"sub_missoes": []
	},

	# CAMPUS
	"unifor_bloco_c": {
		"texto": "Vá para o Bloco C",
		"concluida": false,
		"sub_missoes": [
			{"id": "bloco_c_mini1", "texto": "Responda o quiz de CG", "concluida": false, "falhou": false},
			{"id": "bloco_c_mini2", "texto": "Misture a cor RGB correta", "concluida": false, "falhou": false},
		]
	},
	"unifor_bloco_d": {
		"texto": "Vá para o Bloco D",
		"concluida": false,
		"sub_missoes": [
			{"id": "bloco_d_mini1", "texto": "Corrija o código", "concluida": false, "falhou": false},
			{"id": "bloco_d_mini2", "texto": "Resolva a lógica", "concluida": false, "falhou": false},
		]
	},
	"unifor_onibus": {
		"texto": "Vá ao ponto de ônibus",
		"concluida": false,
		"sub_missoes": []
	},

	# BANCO
	"banco_task1": {
		"texto": "Comece o expediente",
		"concluida": false,
		"sub_missoes": [
			{"id": "banco_mini1", "texto": "Verifique o CPF do cliente", "concluida": false, "falhou": false},
			{"id": "banco_mini2", "texto": "Verifique o CPF do cliente", "concluida": false, "falhou": false},
		]
	},
	"banco_sair": {
		"texto": "Volte para casa",
		"concluida": false,
		"sub_missoes": []
	},

	# QUARTO (NOITE)
	"quarto_dormir": {
		"texto": "Vá dormir",
		"concluida": false,
		"sub_missoes": [
			{"id": "quarto_dormir_mini1", "texto": "Conte os carneirinhos", "concluida": false, "falhou": false},
		]
	},
}

var missoes_por_cena = {
	"quarto":  ["quarto_acorde", "quarto_sair"],
	"campus":  ["unifor_bloco_c", "unifor_bloco_d", "unifor_onibus"],
	"bloco_c": ["unifor_bloco_c", "unifor_bloco_d"],
	"bloco_d": ["unifor_bloco_c", "unifor_bloco_d"],
	"banco":   ["banco_task1", "banco_sair"],
	"quarto_noite": ["quarto_dormir"],
}
