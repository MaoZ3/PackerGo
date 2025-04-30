extends RigidBody2D

@onready var sprite = $AnimatedSprite2D
@onready var area = $Area2D
@onready var visible_notifier = $VisibleOnScreenNotifier2D

@export var speed: float = 100
@export var wave_amplitude: float = 50
@export var wave_frequency: float = 2.0
@export var respawn_position: Vector2 = Vector2(0, 0)

var target_fruit: RigidBody2D = null
var time_elapsed: float = 0.0

func _ready():
	sprite.play("fly")
	find_closest_fruit()
	visible_notifier.screen_exited.connect(_on_screen_exited)

func _process(delta):
	if not target_fruit or not is_instance_valid(target_fruit):
		find_closest_fruit()
	
	if target_fruit:
		move_towards_target(delta)

func move_towards_target(delta):
	var direction = (target_fruit.global_position - global_position).normalized()
	time_elapsed += delta
	var wave_offset = Vector2(-direction.y, direction.x) * sin(time_elapsed * wave_frequency) * wave_amplitude
	var velocity = (direction * speed) + wave_offset
	position += velocity * delta

func find_closest_fruit():
	var fruits = get_tree().get_nodes_in_group("fruits")
	if fruits.is_empty():
		target_fruit = null
		return

	var closest_distance = INF
	for fruit in fruits:
		if is_instance_valid(fruit):
			var distance = global_position.distance_to(fruit.global_position)
			if distance < closest_distance:
				closest_distance = distance
				target_fruit = fruit

func _on_body_entered(body: RigidBody2D) -> void:
	if body.is_in_group("fruits"):
		queue_free()
		body.queue_free()

func _on_screen_exited():
	queue_free()
	_respawn_enemy()

func _respawn_enemy():
	var new_enemy = preload("res://BBird.tscn").instantiate()
	new_enemy.global_position = respawn_position
	get_parent().add_child(new_enemy)
