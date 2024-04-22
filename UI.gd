extends CanvasLayer
class_name UI

@onready var score_label = %Score
@onready var lives_container = $LivesContainer
@onready var win_text = $Win
@onready var game_over_text = $GameOver
@onready var read_label = $ReadyLabel

func _on_level_1_update_score(score):
	score_label.text = str(score)


func _on_level_1_update_lives():
	lives_container.take_life()

func toggle_win(on: bool):
	win_text.visible = on
	
func toggle_game_over(on: bool):
	game_over_text.visible = on
	
func toggle_ready(on: bool):
	read_label.visible = on
