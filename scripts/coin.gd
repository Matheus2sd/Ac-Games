# Arquivo: coin.gd

extends Area2D

# Novo sinal criado (é possível criar um sinal caso os padrões não 
# tenham o que é preciso
signal collected

# Cria as variáveis que referenciam o nó de Partículas, Sprite2D e CollisionShape
@onready var particles: GPUParticles2D = $Particles
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

# Ao ser criado na tela, o sinal body_entered (sinal emitido automaticamente 
# quando um corpo físico entra na área do nó Area2D) é conectado à função 
# on_body_entered
func _ready():
	body_entered.connect(_on_body_entered)
	
# Toda vez que um corpo entra na Area2D, a função _on_body_entered recebe
# automaticamente como parâmetro o nó que entrou nessa área, representado
# pelo body
func _on_body_entered(body):
		# Se o nome do nó que entrou na área for Player, execute as ações
	if body.name == "Player":
		# printe no console "+1"
		print("+1")
		  # Emita o sinal collected (criado no início do código)
		collected.emit()
	  # Deixa a moeda invisível
		sprite_2d.visible = false
	  # Desabilita o colisor (set_deferred é um modo mais seguro do que acessar 
	  # diretamente a propriedade disabled
		collision_shape_2d.set_deferred("disabled", true)
			# Ativa as partículas
		particles.emitting = true
			# Espera as partículas acabarem antes de seguir
			# O await pausa a execução da função até que o sinal finished seja emitido 
			# — sem travar o jogo, pausando somente a função de forma assíncrona.
		await particles.finished
	  # Remova a moeda da cena
		queue_free()
