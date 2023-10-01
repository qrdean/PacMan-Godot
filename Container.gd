extends Container

var lives : Array[Node2D]

func _ready():
	for child in get_children():
		if child is Node2D:
			child.visible = true
			lives.append(child)

func take_life():
	for i in range(lives.size()):
		if lives[i].visible:
			lives[i].visible = false
			break
