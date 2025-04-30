extends CharacterBody2D

@onready var visible_notifier = $VisibleOnScreenNotifier2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const THROW_SPEED_MIN = 300.0
const THROW_SPEED_MAX = 600.0
const THROW_COOLDOWN = 1.0  # Tiempo en segundos antes de poder recoger la fruta lanzada
const COLLECT_DISTANCE = 1.0  # Distancia máxima para recoger una fruta

var collected_fruit: WeakRef = null
var throw_timer: float = 0.0
@export var respawn_position: Vector2 = Vector2(0, 0) # Posición inicial para usar como punto de respawn

func _ready():
	print("Personaje listo")
	respawn_position = global_position  # Guardar la posición inicial del personaje
	

func _physics_process(delta: float) -> void:

	if throw_timer > 0:
		throw_timer -= delta

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jumpp") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimatedSprite2D.play("jump")
	elif not is_on_floor():
		$AnimatedSprite2D.play("jump")
		
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.play("run")
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			$AnimatedSprite2D.play("idle")
			
	move_and_slide()
	
	# Actualizar la posición de la fruta recolectada para que se superponga al personaje
	update_collected_fruit_position()
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print("El personaje salió de la pantalla, reapareciendo...")
	respawn()

func respawn():

	# Lleva al personaje de vuelta a la posición de respawn
	global_position = respawn_position
	velocity = Vector2.ZERO  # Restablece la velocidad a cero
	print("Personaje reaparecido en el punto de respawn")
	
	
# Detectar entrada para recolección de frutas y lanzamiento
func _input(_event):
	if Input.is_action_just_pressed("collect_fruit"):
		_collect_fruit()
	if Input.is_action_just_pressed("throw_fruit"):
		_throw_fruit()

func _collect_fruit():
	if collected_fruit:
		print("Ya tienes una fruta recolectada")
		return

	var closest_fruit = find_closest_fruit()
	if closest_fruit:
		_on_fruit_collision(closest_fruit)
	else:
		print("No hay frutas cercanas para recolectar")

func find_closest_fruit() -> RigidBody2D:
	var fruits = get_tree().get_nodes_in_group("fruits")
	var closest_fruit = null
	var closest_distance = COLLECT_DISTANCE

	for fruit in fruits:
		if fruit.has_meta("is_thrown") and fruit.get_meta("is_thrown"):
			continue
		var distance = global_position.distance_to(fruit.global_position)
		if distance < closest_distance:
			closest_fruit = fruit
			closest_distance = distance

	return closest_fruit

func update_collected_fruit_position():
	if collected_fruit:
		var fruit = collected_fruit.get_ref()
		if fruit and is_instance_valid(fruit):
			fruit.global_position = global_position + Vector2(0, 0)  # Ajusta este offset
		else:
			collected_fruit = null

func _on_fruit_collision(fruit: RigidBody2D) -> void:
	if collected_fruit or throw_timer > 0:
		return

	collected_fruit = weakref(fruit)
	
	fruit.get_parent().call_deferred("remove_child", fruit)
	call_deferred("add_child", fruit)
	
	fruit.set_deferred("physics_process_mode", Node.PROCESS_MODE_DISABLED)
	fruit.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	fruit.set_deferred("angular_velocity", 0)
	fruit.set_deferred("rotation", 0)
	
	var timer = fruit.get_node_or_null("Timer")
	if timer:
		timer.stop()
		timer.call_deferred("queue_free")
	
	var animated_sprite = fruit.get_node_or_null("AnimatedSprite2D")
	if animated_sprite:
		animated_sprite.stop()
	
	for child in fruit.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", true)
	
	# Imprime el nombre de la animación, que representa la fruta recogida
	if animated_sprite:
		print("Fruta recogida: ", animated_sprite.animation)


func _throw_fruit():
	if not collected_fruit:
		print("No hay fruta para lanzar")
		return

	var fruit = collected_fruit.get_ref()
	if not fruit or not is_instance_valid(fruit):
		collected_fruit = null
		print("No se puede lanzar: la fruta ya no es válida")
		return

	# Remover la fruta del personaje y añadirla de nuevo al padre
	call_deferred("remove_child", fruit)
	get_parent().call_deferred("add_child", fruit)
	
	fruit.set_meta("is_thrown", true)
	
	fruit.set_deferred("physics_process_mode", Node.PROCESS_MODE_INHERIT)
	fruit.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	
	for child in fruit.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", false)
	
	# Determinar la dirección del lanzamiento basado en la entrada del jugador
	var throw_direction = Vector2()
	if Input.is_action_pressed("ui_up"):
		throw_direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		throw_direction.y += 1
	if Input.is_action_pressed("ui_left"):
		throw_direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		throw_direction.x += 1

	# Normaliza el vector para evitar que tenga una velocidad mayor en diagonales
	throw_direction = throw_direction.normalized()
	
	# Si no se ha indicado una dirección, usa la dirección horizontal predeterminada del personaje
	if throw_direction == Vector2.ZERO:
		throw_direction = Vector2(1 if not $AnimatedSprite2D.flip_h else -1, -0.5).normalized()
	
	var throw_speed = randf_range(THROW_SPEED_MIN, THROW_SPEED_MAX)
	
	# Aplica la fuerza de lanzamiento
	call_deferred("apply_throw_force", fruit, throw_direction * throw_speed)
	
	collected_fruit = null
	throw_timer = THROW_COOLDOWN
	print("Fruta lanzada en dirección: ", throw_direction)

func apply_throw_force(fruit: RigidBody2D, throw_velocity: Vector2) -> void: 
	if is_instance_valid(fruit):
		fruit.linear_velocity = throw_velocity
		fruit.angular_velocity = randf_range(-10, 10)
		fruit.global_position = global_position + throw_velocity.normalized() * 20
		
		var animated_sprite = fruit.get_node_or_null("AnimatedSprite2D")
		if animated_sprite:
			animated_sprite.play()

		get_tree().create_timer(THROW_COOLDOWN).connect("timeout", Callable(fruit, "set_meta").bind("is_thrown", false))
""" Version cgtp 28/11/2024
extends CharacterBody2D

@onready var visible_notifier = $VisibleOnScreenNotifier2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const THROW_SPEED_MIN = 300.0
const THROW_SPEED_MAX = 600.0
const THROW_COOLDOWN = 1.0
const COLLECT_DISTANCE = 50.0  # Distancia máxima para recoger una fruta

@export var respawn_position: Vector2 = Vector2(0, 0)  # Punto de respawn

var collected_fruit: RigidBody2D = null
var throw_timer: float = 0.0

func _ready():
	respawn_position = global_position
	print("Personaje listo en la posición de respawn:", respawn_position)

func _physics_process(delta: float) -> void:
	# Actualizar temporizador de lanzamiento
	if throw_timer > 0:
		throw_timer -= delta

	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += get_gravity() * delta

	# Manejar salto
	if Input.is_action_just_pressed("jumpp") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimatedSprite2D.play("jump")
	elif not is_on_floor():
		$AnimatedSprite2D.play("jump")

	# Manejar movimiento horizontal
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.play("run")
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			$AnimatedSprite2D.play("idle")

	# Mover personaje
	velocity = move_and_slide(velocity, Vector2.UP)

	# Actualizar posición de fruta recolectada
	if collected_fruit:
		collected_fruit.global_position = global_position

func _input(event):
	if event.is_action_pressed("collect_fruit"):
		collect_fruit()
	elif event.is_action_pressed("throw_fruit"):
		throw_fruit()

func collect_fruit():
	if collected_fruit:
		print("Ya tienes una fruta recolectada.")
		return

	var closest_fruit = find_closest_fruit()
	if closest_fruit:
		attach_fruit(closest_fruit)
	else:
		print("No hay frutas cercanas para recolectar.")

func find_closest_fruit() -> RigidBody2D:
	var closest_fruit: RigidBody2D = null
	var closest_distance = COLLECT_DISTANCE

	for fruit in get_tree().get_nodes_in_group("fruits"):
		if fruit.get_meta("is_thrown", false):
			continue
		var distance = global_position.distance_to(fruit.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_fruit = fruit

	return closest_fruit

func attach_fruit(fruit: RigidBody2D):
	collected_fruit = fruit
	fruit.get_parent().remove_child(fruit)
	add_child(fruit)
	fruit.physics_process_mode = Node.PhysicsProcessMode.DISABLED
	fruit.rotation = 0
	fruit.angular_velocity = 0
	fruit.get_node_or_null("AnimatedSprite2D")?.stop()
	print("Fruta recolectada:", fruit.name)

func throw_fruit():
	if not collected_fruit:
		print("No tienes una fruta para lanzar.")
		return

	if throw_timer > 0:
		print("Aún no puedes lanzar otra fruta.")
		return

	var throw_direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	if throw_direction == Vector2.ZERO:
		throw_direction = Vector2(1 if not $AnimatedSprite2D.flip_h else -1, -0.5).normalized()

	var throw_speed = randf_range(THROW_SPEED_MIN, THROW_SPEED_MAX)
	collected_fruit.linear_velocity = throw_direction * throw_speed
	collected_fruit.angular_velocity = randf_range(-10, 10)

	# Reasignar fruta al nodo padre original
	remove_child(collected_fruit)
	get_parent().add_child(collected_fruit)
	collected_fruit.physics_process_mode = Node.PhysicsProcessMode.INHERIT
	collected_fruit.set_meta("is_thrown", true)

	collected_fruit = null
	throw_timer = THROW_COOLDOWN
	print("Fruta lanzada en dirección:", throw_direction)

func _on_visible_on_screen_notifier_2d_screen_exited():
	print("El personaje salió de la pantalla. Reapareciendo...")
	respawn()

func respawn():
	global_position = respawn_position
	velocity = Vector2.ZERO
	print("Personaje reaparecido en:", respawn_position)

"""
