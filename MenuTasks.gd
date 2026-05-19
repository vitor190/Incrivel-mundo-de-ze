# Script: MenuTasks.gd
extends Control

@onready var lista_tarefas = $ScrollContainer/ListaTarefas

# O seu dicionário de missões (guardado localmente na mesma cena)
var tasks: Dictionary = {
	"ir_bloco_c": {
		"texto": "Entre no Bloco C para assistir a aula",
		"concluida": false
	},
	"beber_agua": {
		"texto": "Encontre a fonte de água para recuperar estamina",
		"concluida": false
	},
	"falar_andre": {
		"texto": "Entregue o código do projeto para o André",
		"concluida": false
	}
}

func _ready():
	# Registra este nó no grupo para podermos chamá-lo de fora
	add_to_group("hud_tasks")
	
	# Desenha as tarefas na tela assim que o jogo começa
	atualizar_lista_de_tarefas()

# Limpa a interface e cria os CheckBoxes dinamicamente por código
func atualizar_lista_de_tarefas():
	# Remove os itens antigos para não duplicar na tela
	for filho in lista_tarefas.get_children():
		filho.queue_free()
	
	# Varre todas as missões do dicionário
	for id in tasks.keys():
		var dados = tasks[id]
		
		# MÁGICA AQUI: Cria um nó CheckBox novinho direto na memória
		var novo_check = CheckBox.new()
		
		# Configura as propriedades dele
		novo_check.text = dados["texto"]
		novo_check.button_pressed = dados["concluida"]
		
		# Remove o foco para o clique não roubar as teclas de andar do Zé
		novo_check.focus_mode = Control.FOCUS_NONE
		
		# Se a missão já estiver concluída, deixa ela cinza/desativada (opcional)
		if dados["concluida"]:
			novo_check.disabled = true
		
		# Adiciona o CheckBox dentro do seu VBoxContainer na tela
		lista_tarefas.add_child(novo_check)
		
		# Se o jogador clicar na caixinha, atualiza o status no dicionário
		novo_check.toggled.connect(func(botao_pressionado):
			tasks[id]["concluida"] = botao_pressionado
		)

# FUNÇÃO PARA CONCLUIR VIA CÓDIGO: Chame isso de fora quando o Zé fizer a ação
func concluir_tarefa(id: String):
	if tasks.has(id):
		tasks[id]["concluida"] = true
		print("Missão concluída: ", id)
		
		# Atualiza o visual na tela imediatamente
		atualizar_lista_de_tarefas()
