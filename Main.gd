### Andrew Rucks 11/2/2024 ###
## Main driver. Contains BFS and DFS functions.

extends Node

const GRIDSIZE = 30

var start_point:Vector2i
var end_point:Vector2i
var grid:Grid

var bfs_thread:Thread
var bfs_result:Grid
var bfs_complete:bool
var dfs_thread:Thread
var dfs_result:Grid
var dfs_complete

var ready_for_render:bool


## Generates a new grid and starts traversal threads
func new_grid() -> void:
	# initialize variables
	bfs_result = null
	bfs_complete = false
	dfs_result = null
	dfs_complete = false
	ready_for_render = false
	start_point = Vector2i()
	end_point = Vector2i()
	
	# generate random grid
	grid = Grid.new(GRIDSIZE, GRIDSIZE)
	
	# pick start and end. make sure they aren't the same
	while start_point == end_point:
		start_point = select_random_point()
		end_point = select_random_point()
		
	# mark them on the grid
	grid.query(start_point).data = "start"
	grid.query(end_point).data = "end"
	
	# Multithreading: BFS thread
	bfs_thread = Thread.new()
	bfs_thread.start(BFS.bind(grid.duplicate(), start_point, end_point))
	
	# Multithreading: DFS thread
	dfs_thread = Thread.new()
	dfs_thread.start(DFS.bind(grid.duplicate(), start_point, end_point))
	
	
## Breadth-first search / flood fill. Uses a queue. Writes resulting grid with path to bfs_result.
func BFS(grid:Grid, start_point:Vector2i, end_point:Vector2i) -> void:
	var Q = Queue.new()
	
	# set start point as visited and queue it
	grid.query(start_point).was_visited = true
	grid.query(start_point).distance = 0
	Q.enqueue(start_point)
	
	# loop through the queue while it has spots
	while not Q.is_empty():
		
		# get all open-spaces adjacent to the spot
		var current_space = Q.dequeue()
		var neighbors = grid.get_open_neighbors(current_space)
		
		# check them all out
		for n in neighbors:
			var s = grid.query(n)
			
			# early return if the end is found
			if s.data == "end":
				bfs_result = grid
				backtrack(bfs_result, end_point)
				bfs_complete = true
				return
			
			# Enqueue the next unvisited spaces
			if not s.was_visited:
				s.was_visited = true
				s.distance = grid.query(current_space).distance + 1
				Q.enqueue(n)
	
	bfs_result = grid
	bfs_complete = true
	

## Depth-first search / flood fill. Uses a stack. Writes resulting grid with path to dfs_result.
func DFS(grid:Grid, start_point:Vector2i, end_point:Vector2i) -> void:
	var S = Stack.new()
	
	# set start point as visited and push it to stack
	grid.query(start_point).distance = 0
	S.push(start_point)
	
	# loop through the stack while it has spots
	while not S.is_empty():
		var current_space = S.pop()
		
		if not grid.query(current_space).was_visited:
			grid.query(current_space).was_visited = true
			
			var neighbors = grid.get_open_neighbors(current_space)
			for n in neighbors:

				# make sure not adding already visited spaces to the stack	
				if not grid.query(n).was_visited:
					grid.query(n).distance = grid.query(current_space).distance + 1
					S.push(n)
	
	# flood fill is done			
	dfs_result = grid
	backtrack(dfs_result, end_point)
	dfs_complete = true
	return
		
		
## Takes a flood-filled grid, and discovers a path connecting the start to end.
func backtrack(grid:Grid, end_point:Vector2i):
	
	# start from the end point.
	var c = end_point
	var current_distance = 9999
	while current_distance > 0:
		var neighbors = grid.get_visited_neighbors(c)

		# get min:
		var i = 0
		var current_smallest:Vector2i

		if len(neighbors) > 0: # prevents index out of bounds error
			current_smallest = neighbors[i]
			
		while i < len(neighbors):
			if grid.query(neighbors[i]).distance < grid.query(current_smallest).distance:
				current_smallest = neighbors[i]
				
			i += 1
	
		# mark path
		if grid.query(current_smallest).data != "start":
			grid.query(current_smallest).data = "path"
			
		c = current_smallest
		current_distance = grid.query(c).distance

	
## Randomly chooses an empty space in the grid.
func select_random_point() -> Vector2i:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var random_point = Vector2i(rng.randi_range(0, grid.width - 1), rng.randi_range(0, grid.height - 1))
	while (grid.query(random_point) == null) or grid.query(random_point).is_obstacle:
		random_point = Vector2i(rng.randi_range(0, grid.width), rng.randi_range(0, grid.height))
		
	return random_point


## Runs every frame.
func _process(_delta) -> void:
	
	# if both threads are complete, allow for rendering of the grid.
	if bfs_complete and dfs_complete:
		get_node("/root/display/anchor").set_bfs_grid(bfs_result)
		get_node("/root/display/anchor").set_dfs_grid(dfs_result)
		
		# when the UI sees this, it will render the grid.
		ready_for_render = true
		
		# clean up finished threads
		if bfs_thread != null:
			bfs_thread.wait_to_finish()
			bfs_thread = null
		if dfs_thread != null:
			dfs_thread.wait_to_finish()
			dfs_thread = null
			
			
## clean up
func _exit_tree():
	if bfs_thread != null:
		bfs_thread.wait_to_finish()
	if dfs_thread != null:
		dfs_thread.wait_to_finish()
	
