extends Node
class_name MazeGen

static func _randomize(maze, _3dscene):
	randomize()
	for wall in maze.get_children():
		if wall.get_name().begins_with("@"):
			wall.queue_free()
	maze.row.clear()
	maze.layer.clear()
	maze.grid.clear()
	_3dscene.call_deferred('_generate')
	print('Randomizing')
