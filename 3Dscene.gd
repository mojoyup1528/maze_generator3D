tool
extends Spatial

func _ready():
	randomize()

func _generate():
	$maze.create_maze()
	yield(get_tree().create_timer(5.0), "timeout")
	$maze.randomly_move_walls()
