extends CanvasLayer


func _ready() -> void:
	$MessageTimer.timeout.connect(_on_message_timer_timeout)

func _process(delta: float) -> void:
	pass
	
func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	
func update_score(score):
	$ScoreLabel.text = str(score)
	
func _on_message_timer_timeout():
	$Message.hide()
