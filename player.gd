extends Area2D

signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var shoot_cooldown = 0.3
@export var default_projectile_scene: PackedScene
@export var special_projectile_scenes: Array[PackedScene]
var current_special_index := 0
var screen_size # Size of the game window.
var time_since_last_shot = 0.0
var time_since_last_shot_special = 0.0


func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()

func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	time_since_last_shot += delta
	if Input.is_action_just_pressed("shoot") and time_since_last_shot >= shoot_cooldown:
		shoot()
		time_since_last_shot = 0.0
		
	if Input.is_action_just_pressed("next_special"):
		next_special()
		
	time_since_last_shot_special += delta
	if Input.is_action_just_pressed("shoot_special"):
		shoot_special()

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		rotation = velocity.angle()
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

func _on_body_entered(_body):
	hide()
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	
func shoot():
	var projectile = default_projectile_scene.instantiate()
	projectile.visible = true
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = global_position
	projectile.rotation = rotation
	projectile.velocity = Vector2.RIGHT.rotated(rotation) * projectile.speed
	
func shoot_special():
	if special_projectile_scenes.is_empty():
		return
	var projectile = special_projectile_scenes[current_special_index].instantiate()
	projectile.visible = true
	var cooldown = projectile.cooldown
	
	if time_since_last_shot_special >= projectile.cooldown:
		get_tree().current_scene.add_child(projectile)

		projectile.global_position = global_position
		projectile.rotation = rotation
		projectile.velocity = Vector2.RIGHT.rotated(rotation) * projectile.speed
		
		if projectile.rotate_visual_on_horizontal:
			projectile.rotation += - PI / 2
			
		time_since_last_shot_special = 0.0

func next_special():
	current_special_index = (current_special_index + 1) % special_projectile_scenes.size()
