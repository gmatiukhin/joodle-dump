extends Node2D

var top_platform := 0

func _on_Player_new_platform(platform_index):
	if platform_index > top_platform:
		top_platform = platform_index
		$HUD.update_score(platform_index)

func start_game():
	$HUD.show_message("Get\nready!")

func game_over():
	$HUD.show_game_over()

func restart_game():
	get_tree().reload_current_scene()
