extends CanvasLayer

signal start_game
signal restart_game
signal ignore_input(val)

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game\nover!")
	# Wait until the MessageTimer has counted down.
	yield(get_tree().create_timer(1.0), "timeout")
	$Message.show()
	$RestartButton.show()

func update_score(score):
	$ScoreLabel.text = str(score)

func _on_MessageTimer_timeout():
	$Message.hide()
	emit_signal("ignore_input", false)

func _on_StartButton_pressed():
	$StartButton.hide()
	emit_signal("start_game")
	emit_signal("ignore_input", true)

func _on_RestartButton_pressed():
	$RestartButton.hide()
	emit_signal("restart_game")
