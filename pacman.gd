extends CharacterBody2D
class_name Player

@export var pacman_starting_location: Vector2
var reset_flag = false

const SPEED = 100.0

var state = NORMAL

enum {
	NORMAL,
	SUPER,
}

signal ghost_eat_player()
signal player_eat_ghost(ghost)

signal move_after_reset()

func _physics_process(_delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity = direction * SPEED
	else:
		direction = Vector2.ZERO

	if reset_flag:
		move_after_reset.emit()
		reset_flag = false

	move_and_slide()

func set_normal():
	state = NORMAL

func set_super():
	state = SUPER

func reset(level_starting_pos):
	velocity = Vector2.ZERO
	global_position = level_starting_pos
	reset_flag = true

func _on_area_2d_body_entered(body):
	if body is Ghost:
		if state == NORMAL:
			ghost_eat_player.emit()
		if state == SUPER:
			player_eat_ghost.emit(body)
