extends CharacterBody2D

@export_group("Movimiento Horizontal")
@export var walk_speed := 220.0       # Velocidad al caminar
@export var run_speed := 400.0        # Velocidad al apretar Shift
@export var acceleration := 600.0     # Inercia al arrancar
@export var friction := 800.0         # Fricción al soltar el mando
@export var turn_around_friction := 1800.0 # El "derrape" al cambiar de dirección

@export_group("Mecánicas de Salto")
@export var jump_velocity := -380.0
@export var gravity := 1100.0
@export var max_fall_speed := 600.0
@export var max_jumps := 2            # Doble salto
@export var jump_cut_multiplier := 0.4 # Salto variable (mantener vs presionar)

var jump_count := 0

func _ready():
	# Ubica al personaje y resetea velocidad al inicio
	global_position = Vector2(100, 250)
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_horizontal_movement(delta)
	move_and_slide()
	
	# ver la velocidad en consola
	# print(velocity.x)

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)
	else:
		jump_count = 0

func handle_jump() -> void:
	# Salto inicial y doble salto
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		velocity.y = jump_velocity
		jump_count += 1

	# Salto variable: si soltás el botón, la velocidad de subida se corta
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_multiplier

func handle_horizontal_movement(delta: float) -> void:
	# Captura dirección (-1, 0, 1)
	var direction := Input.get_axis("move_left", "move_right")
	
	# Lógica de Carrera: cambia la velocidad con Shift
	var target_speed = walk_speed
	if Input.is_action_pressed("run"):
		target_speed = run_speed

	if direction != 0:
		var current_accel = acceleration
		
		# Lógica de derrape (Skid): si cambia de dirección bruscamente
		if sign(direction) != sign(velocity.x) and velocity.x != 0:
			current_accel = turn_around_friction
		
		velocity.x = move_toward(velocity.x, direction * target_speed, current_accel * delta)
	else:
		# Desaceleración suave hasta frenar
		velocity.x = move_toward(velocity.x, 0, friction * delta)
