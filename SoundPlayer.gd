extends Node2D
class_name SoundPlayer

@onready var munch1: AudioStreamPlayer = $munch1
@onready var munch2: AudioStreamPlayer = $munch2
@onready var power_pellet: AudioStreamPlayer = $power_pellet
@onready var death_1: AudioStreamPlayer = $death_1
@onready var death_2: AudioStreamPlayer = $death_2
@onready var eat_ghost: AudioStreamPlayer = $eat_ghost
@onready var game_start: AudioStreamPlayer = $game_start
@onready var retreating: AudioStreamPlayer = $retreating
@onready var siren_1: AudioStreamPlayer = $siren_1

var munch1_ready = true
var death_ready = true
var death_2_sound = 0

signal game_start_finished()
signal player_death_finished()

func _ready():
	munch1.finished.connect(_play_munch2)
	munch2.finished.connect(_munch_2_finished)
	death_1.finished.connect(_play_death2)
	death_2.finished.connect(_play_death2)
	power_pellet.finished.connect(_loop_power_pellet)
	game_start.finished.connect(_game_start_finished)
	siren_1.finished.connect(_loop_siren_1)
	retreating.finished.connect(_loop_retreating)

func play_munch():
	if munch1_ready:
		munch1_ready = false
		munch1.play()

func _play_munch2():
	munch2.play()

func _munch_2_finished():
	munch1_ready = true

func power_pellet_start():
	power_pellet.play()

func power_pellet_stop():
	power_pellet.stop()

func _loop_power_pellet():
	power_pellet.play()

func play_death():
	if death_ready:
		stop_retreating()
		stop_siren()
		death_ready = false
		death_2_sound = 0
		death_1.play()

func _play_death2():
	if !(death_2_sound > 1):
		death_2.play()
		death_2_sound += 1
	else:
		death_ready = true
		player_death_finished.emit()

func play_eat_ghost():
	eat_ghost.play()

func play_game_start():
	game_start.play()

func play_siren():
	siren_1.play()

func stop_siren():
	siren_1.stop()

func _loop_siren_1():
	siren_1.play()

func play_retreating():
	retreating.play()

func stop_retreating():
	retreating.stop()

func _loop_retreating():
	retreating.play()

func _game_start_finished():
	game_start_finished.emit()
