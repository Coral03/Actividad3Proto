extends CharacterBody2D

@export var max_speed := 200.0
@export var acceleration := 800.0
@export var friction := 600.0

#salto
@export var jump_velocity := -350.0
@export var gravity := 900.0
@export var max_fall_speed := 500.0

# doble salto
@export var max_jumps := 2
var jump_count := 0

# salto que varia manteniendo apretada la tecla
@export var jump_cut_multiplier := 0.5

func _physics_process(delta):

	# gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)

	# reset de saltos
	if is_on_floor():
		jump_count = 0

	# input horizontal
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		# aceleracion preogresiva
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		# friccion (desaceleración suave)
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	# salto
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		velocity.y = jump_velocity
		jump_count += 1

	# corte del salto (si soltás el botón, baja antes)
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier

	# movimiento
	move_and_slide()
