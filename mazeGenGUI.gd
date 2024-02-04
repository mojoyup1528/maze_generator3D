tool
extends Control

func _ready():
	if get_tree().edited_scene_root.get_name() == '3dScene':
		var _3dscene = get_tree().edited_scene_root
		var maze = _3dscene.get_node('maze')
		get_node('gridsizeLbl').text = str(maze.cell_size*5) + " x " + str(maze.cell_size*5)

func _on_randomizeBtn_pressed():
	if get_tree().edited_scene_root.get_name() == '3dScene':
		var _3dscene = get_tree().edited_scene_root
		var maze = _3dscene.get_node('maze')
		MazeGen._randomize(maze, _3dscene)
	else:
		print("3D SCENE NEEDS TO BE IN VIEWPORT!")
	
	
func _on_increaseBtn_pressed():
	if get_tree().edited_scene_root.get_name() == '3dScene':
		var _3dscene = get_tree().edited_scene_root
		var maze = _3dscene.get_node('maze')
		maze.cell_size += 1
		maze.maze_size = Vector3(maze.cell_size * 5, 1, maze.cell_size * 5)
		get_node('gridsizeLbl').text = str(maze.cell_size * 5) + " x " + str(maze.cell_size * 5)


func _on_decreaseBtn_pressed():
	if get_tree().edited_scene_root.get_name() == '3dScene':
		var _3dscene = get_tree().edited_scene_root
		var maze = _3dscene.get_node('maze')
		maze.cell_size -= 1
		maze.maze_size = Vector3(maze.cell_size * 5, 1, maze.cell_size * 5)
		get_node('gridsizeLbl').text = str(maze.cell_size * 5) + " x " + str(maze.cell_size * 5)


func _on_saveBtn_pressed():
	if get_tree().edited_scene_root.get_name() == '3dScene':
		var _3dscene = get_tree().edited_scene_root
		var maze = _3dscene.get_node('maze')
		maze.export_all_to_obj("res://my_exported_model.obj")


func _on_clearBtn_pressed():
	if get_tree().edited_scene_root.get_name() == '3dScene':
		var _3dscene = get_tree().edited_scene_root
		var maze = _3dscene.get_node('maze')
		for c in maze.get_children():
			c.queue_free()
			
		for s in _3dscene.get_children():
			if s.is_in_group("locations"):
				s.queue_free()
