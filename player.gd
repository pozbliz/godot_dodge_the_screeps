extends Area2D

signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var default_projectile_scene: PackedScene
@export var special_projectile_scene: PackedScene
var screen_size # Size of the game window.
var shoot_cooldown = 0.3  # seconds between shots
var time_since_last_shot = 0.0
var shoot_cooldown_special = 0.5
var time_since_last_shot_special = 0.0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
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
		
		time_since_last_shot_special += delta
	if Input.is_action_just_pressed("shoot_special") and time_since_last_shot_special >= shoot_cooldown_special:
		shoot_special()
		time_since_last_shot_special = 0.0

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
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	
func shoot():
	var projectile = default_projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = global_position
	projectile.rotation = rotation
	projectile.velocity = Vector2.RIGHT.rotated(rotation) * projectile.speed
	
func shoot_special():
	var projectile = special_projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = global_position
	projectile.rotation = rotation
	projectile.velocity = Vector2.RIGHT.rotated(rotation) * projectile.speed

	
