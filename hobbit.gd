extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var collected_fruit: WeakRef = null

const THROW_SPEED_MIN = 300.0
const THROW_SPEED_MAX = 600.0

func _ready():
	print("Personaje listo")

func _physics_process(delta: float) -> void:
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
# Función de entrada para detectar el lanzamiento de frutas
func _input(_event):
	# Verificar si se presiona la acción para lanzar la fruta
	if Input.is_action_just_pressed("throw_fruit"):
		_throw_fruit()

# Función para recoger frutas
func update_collected_fruit_position():
	if collected_fruit:
		var fruit = collected_fruit.get_ref()
		if fruit and is_instance_valid(fruit):
			fruit.global_position = global_position + Vector2(0, 0)
		else:
			collected_fruit = null
			print("La fruta recolectada ya no es válida")

func _on_fruit_collision(fruit: RigidBody2D) -> void:
	if collected_fruit:
		return
	
	collected_fruit = weakref(fruit)
	
	# Usar call_deferred para remover el nodo de forma segura
	fruit.get_parent().call_deferred("remove_child", fruit)
	call_deferred("add_child", fruit)
	
	# Desactivar la física y la rotación de forma segura
	fruit.set_deferred("physics_process_mode", Node.PROCESS_MODE_DISABLED)
	fruit.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	fruit.set_deferred("angular_velocity", 0)
	fruit.set_deferred("rotation", 0)
	
	# Detener el timer si existe
	var timer = fruit.get_node_or_null("Timer")
	if timer:
		timer.stop()
		timer.call_deferred("queue_free")
	
	# Detener la animación si existe
	var animated_sprite = fruit.get_node_or_null("AnimatedSprite2D")
	if animated_sprite:
		animated_sprite.stop()
	
	# Desactivar las colisiones de forma segura
	for i in fruit.get_child_count():
		var child = fruit.get_child(i)
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", true)
	
	print("Fruta recogida: ", fruit.name)
	
	# Actualizar la posición de la fruta en el próximo frame
	call_deferred("update_fruit_position", fruit)

func update_fruit_position(fruit: RigidBody2D) -> void:
	if is_instance_valid(fruit):
		fruit.global_position = global_position + Vector2(0, 0)  # Ajusta este offset según necesites

func _throw_fruit():
	print("Intentando lanzar fruta")
	if collected_fruit:
		var fruit = collected_fruit.get_ref()
		if fruit and is_instance_valid(fruit):
			call_deferred("remove_child", fruit)
			get_parent().call_deferred("add_child", fruit)
			
			# Marcar la fruta como lanzada
			fruit.set_meta("is_thrown", true)
			
			# Reactivar la física y procesos de forma segura
			fruit.set_deferred("physics_process_mode", Node.PROCESS_MODE_INHERIT)
			fruit.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
			
			# Reactivar las colisiones
			for i in fruit.get_child_count():
				var child = fruit.get_child(i)
				if child is CollisionShape2D or child is CollisionPolygon2D:
					child.set_deferred("disabled", false)
			
			# Calcular la dirección y velocidad de lanzamiento
			var throw_direction = Vector2(1 if not $AnimatedSprite2D.flip_h else -1, -0.5).normalized()
			var throw_speed = randf_range(THROW_SPEED_MIN, THROW_SPEED_MAX)
			
			# Aplicar la velocidad y rotación en el próximo frame
			call_deferred("apply_throw_force", fruit, throw_direction * throw_speed)
			
			collected_fruit = null
			print("Fruta lanzada")
		else:
			collected_fruit = null
			print("No se puede lanzar: la fruta ya no es válida")
	else:
		print("No hay fruta para lanzar")

func apply_throw_force(fruit: RigidBody2D, throw_velocity: Vector2) -> void:
	if is_instance_valid(fruit):
		fruit.linear_velocity = throw_velocity  # Usar throw_velocity en lugar de velocity
		fruit.angular_velocity = randf_range(-10, 10)
		fruit.global_position = global_position  # Asegurar que la posición se actualice correctamente
		
		# Reiniciar la animación si existe
		var animated_sprite = fruit.get_node_or_null("AnimatedSprite2D")
		if animated_sprite:
			animated_sprite.play()
