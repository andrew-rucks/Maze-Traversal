### Andrew Rucks 11/2/2024 ###
## User Interface controller.

extends Control

@onready var grid_renderer = get_node("/root/display/anchor")

var ui_update:bool = false

func _process(_delta) -> void:
	
	# if the user interacted with the UI
	if ui_update:
		if Main.ready_for_render:
			grid_renderer.render_grid()
			grid_renderer.visible = true
			ui_update = false
			
	# UI consistency
	if not grid_renderer.show_visited:
		$Menu/distance.disabled = true
	else:
		$Menu/distance.disabled = false
	
func _on_modetoggle_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		grid_renderer.grid_mode = "BFS"
		$modelabel.text = "breadth\nfirst\ntraversal"
	else:
		grid_renderer.grid_mode = "DFS"
		$modelabel.text = "depth\nfirst\ntraversal"
	ui_update = true
	return
	
func _on_visited_toggled(toggled_on: bool) -> void:
	grid_renderer.show_visited = toggled_on
	ui_update = true
	return

func _on_distance_toggled(toggled_on: bool) -> void:
	grid_renderer.show_distance = toggled_on
	ui_update = true
	return
	
func _on_path_toggled(toggled_on: bool) -> void:
	grid_renderer.show_path = toggled_on
	ui_update = true
	return
	
func _on_gen_pressed() -> void:
	Main.new_grid()
	ui_update = true
	return

func _on_creditbutton_pressed() -> void:
	if $credits.visible == true:
		$credits.visible = false
	else:
		$credits.visible = true
