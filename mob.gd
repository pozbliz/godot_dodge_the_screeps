extends RigidBody2D


@export var health = 1
@export var points = 1
@export var speed = 200
@export var sprite_scale: Vector2 = Vector2(1, 1)
@export var collision_scale: Vector2 = Vector2(1, 1)
var blink_count = 0
var shader_material: ShaderMaterial
var is_blinking = false


signal enemy_died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$VisibleOnScreenEnabler2D.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)
	add_to_group("enemy")
	$AnimatedSprite2D.scale = sprite_scale
	$CollisionShape2D.scale = collision_scale
	linear_velocity = Vector2(speed, 0).rotated(rotation)
	var hp_bar = $HPBar
	hp_bar.max_value = health
	hp_bar.value = health
	hp_bar.visible = false
	
	# Set shader
	shader_material = $AnimatedSprite2D.material.duplicate()
	$AnimatedSprite2D.material = shader_material
	var tint_color = $AnimatedSprite2D.modulate
	shader_material.set_shader_parameter("tint_color", tint_color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_damage(amount):
	if is_blinking:
		return
	health -= amount	
	
	if health > 0:
		$HitSound.pitch_scale = randf_range(0.9, 1.1)
		$HitSound.play()
		await _blink()
		var hp_bar = $HPBar
		hp_bar.visible = true
		hp_bar.value = health
		
	else:
		# Detach and play death sound separately
		var death_sound = $DeathSound.duplicate()
		get_tree().current_scene.add_child(death_sound)
		death_sound.global_position = global_position
		death_sound.play()
		
		await _blink()
		enemy_died.emit()
		queue_free()
		
		death_sound.connect("finished", death_sound.queue_free)

func _blink() -> void:
	is_blinking = true
	var material := $AnimatedSprite2D.material as ShaderMaterial

	if material:
		material.set_shader_parameter("hit_blink", true)
		await get_tree().create_timer(0.1).timeout
		material.set_shader_parameter("hit_blink", false)

	is_blinking = false

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
