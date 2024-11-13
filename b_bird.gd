extends RigidBody2D

@onready var sprite = $AnimatedSprite2D
@onready var area = $Area2D
@onready var visible_notifier = $VisibleOnScreenNotifier2D  # Nodo VisibleOnScreenNotifier2D

@export var speed: float = 100
@export var wave_amplitude: float = 50  # Amplitud del movimiento sinusoidal
@export var wave_frequency: float = 2.0  # Frecuencia del movimiento sinusoidal
@export var respawn_position: Vector2 = Vector2(0, 0)  # Posición de respawn

var target_fruit: RigidBody2D = null
var time_elapsed: float = 0.0

func _ready():
	sprite.play("fly")  # Inicia la animación de vuelo
	find_closest_fruit()  # Encuentra el primer objetivo
	visible_notifier.connect("screen_exited", Callable(self, "_on_screen_exited"))

func _process(delta):
	# Verifica si el objetivo actual es válido
	if not target_fruit or not is_instance_valid(target_fruit):
		find_closest_fruit()  # Si el objetivo no es válido, encuentra otro
	
	# Si se encuentra un objetivo válido, el enemigo se mueve hacia él
	if target_fruit:
		var direction = (target_fruit.global_position - global_position).normalized()
		
		# Incrementa el tiempo para el movimiento sinusoidal
		time_elapsed += delta
		
		# Calcula el desplazamiento sinusoidal perpendicular a la dirección
		var wave_offset = Vector2(-direction.y, direction.x) * sin(time_elapsed * wave_frequency) * wave_amplitude
		
		# Aplica el movimiento hacia el objetivo
		var velocity = (direction * speed) + wave_offset
		position += velocity * delta

func find_closest_fruit():
	# Obtiene todas las frutas en la escena
	var fruits = get_tree().get_nodes_in_group("fruits")
	if fruits.is_empty():
		target_fruit = null  # No hay frutas disponibles, no se asigna un objetivo
		return

	# Encuentra la fruta más cercana
	var closest_distance = INF
	for fruit in fruits:
		if is_instance_valid(fruit):
			var distance = global_position.distance_to(fruit.global_position)
			if distance < closest_distance:
				closest_distance = distance
				target_fruit = fruit

func _on_body_entered(body: RigidBody2D) -> void:
	if body.name == "fruits":  # Verifica si el objeto entrante es una fruta
		queue_free()  # Elimina el enemigo
		body.queue_free()  # Elimina la fruta también

# Función para detectar cuándo el enemigo sale de la pantalla
func _on_screen_exited():
	queue_redraw()
	queue_free()  # Elimina el enemigo cuando sale de la pantalla
	_respawn_enemy()  # Llama a la función de respawn
	

# Función de respawn para crear un nuevo enemigo en la posición inicial
func _respawn_enemy():
	var new_enemy = preload("res://BBird.tscn").instantiate()
	new_enemy.global_position = respawn_position
	get_parent().add_child(new_enemy)
