extends CanvasLayer

@onready var score_label = %Score
@onready var lives_container = $LivesContainer

func _on_level_1_update_score(score):
	score_label.text = str(score)


func _on_level_1_update_lives():
	lives_container.take_life()
