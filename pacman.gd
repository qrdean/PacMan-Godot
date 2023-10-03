extends CharacterBody2D
class_name Player

@export var pacman_starting_location: Vector2
var reset_flag = false
var movement_enabled = false
var death = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100.0

var state = NORMAL

enum {
	NORMAL,
	SUPER,
}

signal ghost_eat_player()
signal player_eat_ghost(ghost)

signal death_animation_finished()

signal move_after_reset()

func _physics_process(_delta):
	if !death:
		var direction = Input.get_vector("left", "right", "up", "down")
		if movement_enabled:
			if direction:
				velocity = direction * SPEED
			else:
				direction = Vector2.ZERO

			if reset_flag:
				move_after_reset.emit()
				reset_flag = false
			
			if velocity.x != 0 || velocity.y != 0:
				if velocity.x > 0:
					animated_sprite.flip_h = false
					animated_sprite.rotation = 0
				elif velocity.x < 0:
					animated_sprite.flip_h = true
					animated_sprite.rotation = 0

				if velocity.y > 0:
					animated_sprite.flip_h = false
					animated_sprite.rotation = 90
				elif velocity.y < 0:
					animated_sprite.flip_h = false
					animated_sprite.rotation = -90
				play_animation_run()
			else:
				play_animation_idle()

			move_and_slide()

func set_normal():
	state = NORMAL

func set_super():
	state = SUPER

func play_animation_run():
	animated_sprite.play("run")

func play_animation_idle():
	animated_sprite.play("idle")
	
func play_animation_die():
	death = true
	animated_sprite.play("die")

func reset(level_starting_pos):
	play_animation_idle()
	animated_sprite.flip_h = false
	animated_sprite.rotation = 0 
	velocity = Vector2.ZERO
	global_position = level_starting_pos
	reset_flag = true
	death = false

func _on_area_2d_body_entered(body):
	if body is Ghost:
		if state == NORMAL:
			ghost_eat_player.emit()
		if state == SUPER:
			player_eat_ghost.emit(body)


func _on_animated_sprite_2d_animation_finished():
	print_debug(animated_sprite.animation)
	if animated_sprite.animation == "die":
		death_animation_finished.emit()
