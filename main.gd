extends Node

@export var mob_scene: PackedScene
@export var fast_enemy_scene: PackedScene
@export var tank_enemy_scene: PackedScene
var score


# Called when the node enters the scene tree for the first time.
func _ready():
	$HUD.start_game.connect(new_game)
	$Player.hit.connect(game_over)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$Music.stop()
	$HUD.show_game_over()
	$DeathSound.play()

func new_game():
	score = 0
	get_tree().call_group("mobs", "queue_free")
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$Music.play()
	$HUD.show_message("Get Ready")

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob: RigidBody2D
	if randf() < 0.7:
		mob = mob_scene.instantiate()
	elif randf() >= 0.7 and randf() < 0.9:
		mob = fast_enemy_scene.instantiate()
	else:
		mob = tank_enemy_scene.instantiate()
	
	mob.enemy_died.connect(_increase_score)

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	mob.linear_velocity = Vector2(mob.speed, 0.0).rotated(direction)
	
	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)
	
func _increase_score(points):
	score += points
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
