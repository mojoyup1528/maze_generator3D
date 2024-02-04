tool
extends Spatial

var maze_size = Vector3(10, 1, 10)
var cell_size = 2.0
var grid = []  # Each cell contains information about its walls
var row = []
var layer = []

func create_maze():
	grid.clear()
	row.clear()
	layer.clear()
	# Initialize the grid with all walls
	for z in range(maze_size.z):
		layer = []
		for y in range(maze_size.y):
			row = []
			for x in range(maze_size.x):
				var walls = {
					"top": true,
					"bottom": true,
					"left": true,
					"right": true,
					"visited": false
				}
				row.append(walls)
			layer.append(row)
		grid.append(layer)

	# Generate maze using DFS algorithm
	var start_cell = Vector3(0, 0, 0)
	var exit_cell = Vector3(maze_size.x - 1, maze_size.y - 1, maze_size.z - 1)

	dfs(start_cell, exit_cell)

	# Create wall meshes based on grid
	create_wall_meshes()
	
	
func dfs(current_cell, exit_cell):
	var directions = shuffle_array([Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)])
	var x = int(current_cell.x)
	var y = int(current_cell.y)
	var z = int(current_cell.z)

	grid[z][y][x]["visited"] = true

	for dir in directions:
		var nx = x + int(dir.x)
		var ny = y + int(dir.y)
		var nz = z + int(dir.z)

		if Vector3(nx, ny, nz) == exit_cell:
			grid[z][y][x]["exit_direction"] = dir
			return

		if nx >= 0 and nx < maze_size.x and ny >= 0 and ny < maze_size.y and nz >= 0 and nz < maze_size.z:
			if not grid[nz][ny][nx]["visited"]:
				if dir.x == 1:
					grid[z][y][x]["right"] = false
					grid[nz][ny][nx]["left"] = false
				elif dir.x == -1:
					grid[z][y][x]["left"] = false
					grid[nz][ny][nx]["right"] = false
				elif dir.z == 1:
					grid[z][y][x]["bottom"] = false
					grid[nz][ny][nx]["top"] = false
				elif dir.z == -1:
					grid[z][y][x]["top"] = false
					grid[nz][ny][nx]["bottom"] = false

				dfs(Vector3(nx, ny, nz), exit_cell)



func create_wall_meshes():
	for z in range(maze_size.z):
		for y in range(maze_size.y):
			for x in range(maze_size.x):
				var walls = grid[z][y][x]
				if walls["top"]:
					create_wall(Vector3(x, y, z), Vector3(x + 1, y, z))
				if walls["bottom"]:
					create_wall(Vector3(x, y, z + 1), Vector3(x + 1, y, z + 1))
				if walls["left"]:
					create_wall(Vector3(x, y, z), Vector3(x, y, z + 1))
				if walls["right"]:
					create_wall(Vector3(x + 1, y, z), Vector3(x + 1, y, z + 1))

func create_wall(start, end):
	var wall_mesh = CubeMesh.new()
	var wall_instance = MeshInstance.new()
	wall_instance.mesh = wall_mesh
	
	# Calculate the wall's position and size
	var position = (start + end) * 0.5 * cell_size
	var size = Vector3(0.05, 0.5, 0.05)  # Initial size

	# Calculate wall size and position adjustments based on wall direction
	if start.x != end.x:  # Wall is along the x-axis
		size.x = cell_size
		position.x = (start.x + end.x) * 0.5 * cell_size
		size.z = 0.05  # Set z-size to match wall thickness
		position.z += (0.5 * cell_size) * (1.0 - size.z)
	elif start.z != end.z:  # Wall is along the z-axis
		size.z = cell_size
		position.z = (start.z + end.z) * 0.5 * cell_size
		size.x = 0.05  # Set x-size to match wall thickness
		position.x += (0.5 * cell_size) * (1.0 - size.x)

	# Set wall position and scale
	wall_instance.transform.origin = position
	wall_instance.scale = size
	wall_instance.set_name('Wall')
	add_child(wall_instance)
	wall_instance.set_owner(get_tree().edited_scene_root)


func randomly_move_walls():
	for wall in get_children():
		if !wall.get_name().begins_with("@"):
			if wall.scale.x >= cell_size:
				wall.global_transform.origin.x += cell_size / 2
				wall.scale.x = cell_size/2
			elif wall.scale.z >= cell_size:
				wall.global_transform.origin.z += cell_size / 2
				wall.scale.z = cell_size/2
			wall.scale.y = cell_size
	place_spheres_at_start_and_end()

func shuffle_array(arr: Array) -> Array:
	var shuffled = arr.duplicate()
	for i in range(shuffled.size()):
		var j = randi() % shuffled.size()
		var temp = shuffled[i]
		shuffled[i] = shuffled[j]
		shuffled[j] = temp
	return shuffled



var obj_data = []
func export_all_to_obj(file_path: String):
	var file = File.new()
	file.open(file_path, File.WRITE)
	
	var vertex_offset = 1  # Starting vertex index
	
	for child in get_children():
		if child is MeshInstance:
			var mesh_instance = child as MeshInstance
			var mesh = mesh_instance.mesh
			
			if mesh is CubeMesh:
				var transform = mesh_instance.global_transform
				var vertices = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
				var normals = mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL]
				var indices = mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX]
				
				for i in range(vertices.size()):
					var v = transform.xform(vertices[i])
					var n = transform.basis.xform(normals[i])
					
					file.store_string("v " + str(v.x) + " " + str(v.y) + " " + str(v.z) + "\n")
					file.store_string("vn " + str(n.x) + " " + str(n.y) + " " + str(n.z) + "\n")
				
				# Renumber indices and add to obj file
				for i in range(0, indices.size(), 3):
					var v1 = indices[i] + vertex_offset
					var v2 = indices[i + 1] + vertex_offset
					var v3 = indices[i + 2] + vertex_offset
					
					file.store_string("f " + str(v1) + "//" + str(v1) + " " + str(v2) + "//" + str(v2) + " " + str(v3) + "//" + str(v3) + "\n")
				
				file.store_string("\n")  # Add an empty line as a separator between mesh data sections
				
				vertex_offset += vertices.size()  # Update vertex offset for the next mesh
	
	file.close()


# Place sphere meshes at the start and end points of the maze
func place_spheres_at_start_and_end():
	var start_sphere = SphereMesh.new()
	start_sphere.radius = 0.25  # Adjust the radius as needed
	start_sphere.height = 0.5
	var start_sphere_instance = MeshInstance.new()
	start_sphere_instance.mesh = start_sphere
	start_sphere_instance.translation = Vector3(0, 0, 0) * cell_size  # Place sphere at the start point
	start_sphere_instance.add_to_group('locations')
	get_parent().add_child(start_sphere_instance)  # Add the sphere node to the scene
	
	var exit_sphere = SphereMesh.new()
	exit_sphere.radius = 0.25  # Adjust the radius as needed
	exit_sphere.height = 0.5
	var exit_sphere_instance = MeshInstance.new()
	exit_sphere_instance.mesh = exit_sphere
	exit_sphere_instance.translation = Vector3(maze_size.x - 1, maze_size.y - 1, maze_size.z - 1) * cell_size  # Place sphere at the exit point
	exit_sphere_instance.add_to_group('locations')
	get_parent().add_child(exit_sphere_instance)  # Add the sphere node to the scene
	
	start_sphere_instance.set_owner(get_tree().edited_scene_root)
	exit_sphere_instance.set_owner(get_tree().edited_scene_root)
