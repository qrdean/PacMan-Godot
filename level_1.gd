extends Node2D

var score = 0
const SCORE_PELLET = 10
var pellets_remaining = 0
var starting_pellets = 0
var lives = 3

signal update_lives()
signal update_score(score)

var current_global_state = Ghost.SCATTER
var next_global_state = Ghost.CHASE

var red_starting_pos: Vector2
var pink_starting_pos: Vector2
var blue_starting_pos: Vector2
var orange_starting_pos: Vector2
var pacman_starting_pos: Vector2

@onready var red_ghost: CharacterBody2D = %RedGhost
@onready var pink_ghost: CharacterBody2D = %PinkGhost
@onready var blue_ghost: CharacterBody2D = %BlueGhost
@onready var orange_ghost: CharacterBody2D = %OrangeGhost
@onready var pacman: CharacterBody2D = %Pacman
@onready var ghost_start_location = %GhostStartLocation

@onready var blue_scatter_location = $BlueScatterLocation
@onready var orange_scatter_location = $OrangeScatterLocation
@onready var red_scatter_location = $RedScatterLocation
@onready var pink_scatter_location = $PinkScatterLocation
@onready var ghost_pen_location = $GhostPenArea

@onready var nav_to_ghost_pen: NavigationRegion2D = %navtoghostpen

@onready var chase_timer = $ChaseTimer
@onready var scatter_timer = $ScatterTimer
@onready var super_timer = $SuperTimer
# TODO: remove me once we setup the scene
@onready var mock_intro_timer = $MockIntro
var timer_rounds = 0

var ghosts = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var children = self.get_children()
	ghosts = [red_ghost, pink_ghost, blue_ghost, orange_ghost]
	red_starting_pos = red_ghost.global_position
	pink_starting_pos = pink_ghost.global_position
	blue_starting_pos = blue_ghost.global_position
	orange_starting_pos = orange_ghost.global_position
	pacman_starting_pos = pacman.global_position
	pacman.ghost_eat_player.connect(_ghost_eat_player)
	pacman.player_eat_ghost.connect(_player_eat_ghost)
	for child in children:
		if child is Pellet:
			pellets_remaining += 1
			child.pellet_eaten.connect(_pellet_eaten)
		if child is PowerPellet:
			pellets_remaining += 1
			child.power_pellet_eaten.connect(_power_pellet_eaten)
	starting_pellets = pellets_remaining
	mock_intro_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func reset():
	pacman.movement_enabled = false
	red_ghost.reset(red_starting_pos)
	pink_ghost.reset(pink_starting_pos)
	blue_ghost.reset(blue_starting_pos)
	orange_ghost.reset(orange_starting_pos)
	pacman.reset(pacman_starting_pos)
	scatter_timer.stop()
	chase_timer.stop()
	$PinkResetTimer.stop()
	$BlueResetTimer.stop()
	$OrangeResetTimer.stop()
	mock_intro_timer.start()
	# reset timer
	pass

func play_intro():
	# plays intro timer
	pass

# Ghost handling
func _on_timer_timeout():
	ghost_check()

func debug_state(state):
	match state:
		Ghost.CHASE:
			return "chase"
		Ghost.SCATTER:
			return "scatter"
		Ghost.SCARED:
			return "scared"
		Ghost.EATEN:
			return "eaten"
		Ghost.PEN:
			return "pen"

func ghost_check():
	for ghost in ghosts:
		match ghost.state:
			Ghost.CHASE:
				if ghost.ghost_type == "red":
					red_chase_logic()
				if ghost.ghost_type == "pink":
					pink_chase_logic()
				if ghost.ghost_type == "blue":
					blue_chase_logic()
				if ghost.ghost_type == "orange":
					orange_chase_logic()
			Ghost.SCARED:
				pass
			Ghost.SCATTER:
				pass
			Ghost.EATEN:
				pass
			Ghost.PEN:
				pass

func red_chase_logic():
	red_ghost.set_pac_position(pacman.global_position)

func pink_chase_logic():
	var pink_ghost_target = pacman.global_position + (pacman.velocity).normalized() * 4 * 8
	pink_ghost.set_pac_position(pink_ghost_target)

func blue_chase_logic():
	var blue_ghost_to_player = pacman.global_position + (pacman.velocity).normalized() * 4 * 8
	var to_red = red_ghost.global_position - blue_ghost_to_player
	var blue_ghost_target = blue_ghost_to_player - to_red
	blue_ghost.set_pac_position(blue_ghost_target)

func orange_chase_logic():
	var orange_distance_to_player = orange_ghost.global_position.distance_to(pacman.global_position)
	if orange_distance_to_player > 8 * 8:
		orange_ghost.set_pac_position(pacman.global_position)
	else:
		var orange_ghost_target = pacman.global_position + (pacman.velocity.normalized() * -10 * 8)
		orange_ghost.set_pac_position(orange_ghost_target)

# Score keeping && pellet eating
func _pellet_eaten():
	score += SCORE_PELLET
	update_score.emit(score)
	pellets_remaining -= 1
	if pellets_remaining == starting_pellets - 1:
		scatter_timer.start()
		red_ghost.state = current_global_state 

	if pellets_remaining == starting_pellets - 10:
		pink_ghost.global_position = ghost_start_location.global_position
		pink_ghost.state = current_global_state
		
	if pellets_remaining == starting_pellets - 30:
		blue_ghost.global_position = ghost_start_location.global_position
		blue_ghost.state = current_global_state 

	if pellets_remaining == starting_pellets - 90:
		orange_ghost.global_position = ghost_start_location.global_position
		orange_ghost.state = current_global_state 
	if pellets_remaining == 0:
		print_debug("You win")

func _power_pellet_eaten():
	scatter_timer.paused = true
	chase_timer.paused = true
	score += SCORE_PELLET * 2
	update_score.emit(score)
	pellets_remaining -= 1
	pacman.set_super()

	for ghost in ghosts:
		if ghost.state == Ghost.PEN:
			continue
		# ghost.set_scared()
		ghost.state = Ghost.SCARED

	# nav_to_ghost_pen.enabled = true
	ghost_check()
	super_timer.start()

# player and ghost interactions
func _player_eat_ghost(ghost):
	ghost.state = Ghost.EATEN 
	ghost.set_pac_position(ghost_pen_location.global_position)

func _ghost_eat_player():
	lives -= 1
	update_lives.emit()
	pacman.play_animation_die()

func _on_ghost_pen_area_body_entered(body):
	if body is Ghost:
		if body.state == Ghost.EATEN:
			body.state = current_global_state

# chase or scatter timers
func _on_scatter_timer_timeout():
	# set state of ghosts to chase
	scatter_timer.stop()
	current_global_state = next_global_state
	next_global_state = Ghost.SCATTER
	for ghost in ghosts:
		if ghost.state == Ghost.PEN:
			continue
		if ghost.state != current_global_state:
			ghost.state = current_global_state
	chase_timer.start()

func _on_chase_timer_timeout():
	# set state of ghosts to scatter
	if timer_rounds >= 4:
		return
	if timer_rounds == 3:
		scatter_timer.wait_time = 5.0
	chase_timer.stop()
	current_global_state = next_global_state
	next_global_state = Ghost.CHASE
	for ghost in ghosts:
		if ghost.state == Ghost.PEN:
			continue
		if ghost.state != current_global_state:
			ghost.state = current_global_state
	scatter_timer.start()
	timer_rounds += 1

func _on_super_timer_timeout():
	super_timer.stop()
	chase_timer.paused = false
	scatter_timer.paused = false
	pacman.set_normal()
	for ghost in ghosts:
		if ghost.state == Ghost.PEN:
			continue
		if ghost.state != current_global_state:
			ghost.state = current_global_state

func _on_nav_left_body_entered(body):
	if body is Player:
		body.global_position = $NavRight/Offset.global_position

func _on_nav_right_body_entered(body):
	if body is Player:
		body.global_position = $NavLeft/Offset.global_position

func _on_pacman_move_after_reset():
	scatter_timer.start()
	if pellets_remaining <= starting_pellets - 1:
		red_ghost.global_position = ghost_start_location.global_position
		red_ghost.state = current_global_state

	if pellets_remaining <= starting_pellets - 10:
		$PinkResetTimer.start()
		
	if pellets_remaining <= starting_pellets - 30:
		$BlueResetTimer.start()

	if pellets_remaining <= starting_pellets - 90:
		$OrangeResetTimer.start()

func _on_mock_intro_timeout():
	pacman.movement_enabled = true
	scatter_timer.start()

func _on_pink_reset_timer_timeout():
	pink_ghost.global_position = ghost_start_location.global_position
	pink_ghost.state = current_global_state

func _on_blue_reset_timer_timeout():
	blue_ghost.global_position = ghost_start_location.global_position
	blue_ghost.state = current_global_state 

func _on_orange_reset_timer_timeout():
	orange_ghost.global_position = ghost_start_location.global_position
	orange_ghost.state = current_global_state


func _on_pacman_death_animation_finished():
	if lives < 1:
		pacman.queue_free()
		print_debug("player loses")
		print_debug("play lose message")
		get_tree().paused = true
	else:
		reset()
