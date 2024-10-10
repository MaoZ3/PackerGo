extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var collected= []
@onready var fruit_markers: Array[Marker2D] = []

func _ready():
	# Inicializar fruit_markers con los nodos existentes
	for i in range(5):
		var marker = get_node_or_null("fruit" + str(i))
		if marker is Marker2D:
			fruit_markers.append(marker)
		else:
			push_warning("Marcador de fruta no encontrado o no es Marker2D: fruit" + str(i))
	
	print("Número de marcadores de fruta válidos: ", fruit_markers.size())
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
	# As good practice, you should replace UI actions with custom gameplay actions.
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
	
	# Función para recoger frutas
# Función para recoger frutas
func _on_fruit_collision(fruit: RigidBody2D) -> void:
	if fruit in collected or collected.size() >= fruit_markers.size():
		return
	
	fruit.collected = true
	
	var timer = fruit.get_node("Timer")
	if timer:
		timer.queue_free()
	
	fruit.set_physics_process(false)
	fruit.rotation = 0
	
	var marker = fruit_markers[collected.size()]
	fruit.get_parent().remove_child(fruit)
	add_child(fruit)
	fruit.global_position = marker.global_position
	
	collected.append(fruit)
	
	if collected.size() == fruit_markers.size():
		print("¡Has recogido todas las frutas!")
