extends Area2D
class_name PowerPellet

signal power_pellet_eaten()

func _on_area_entered(_area):
	pass

func _on_body_entered(body):
	if body is Player:
		self.queue_free()
		power_pellet_eaten.emit()
