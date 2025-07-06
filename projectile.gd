extends Area2D

var velocity = Vector2.ZERO
@export var speed = 400
@export var damage: int = 1
@export var lifetime: float = 5.0
@export var cooldown: float = 0.3
@export var rotate_visual_on_horizontal: bool = false


func _ready() -> void:
	$VisibleOnScreenEnabler2D.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)
	body_entered.connect(_on_body_entered)
	add_to_group("projectile")
	$AnimatedSprite2D.play()
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float) -> void:
	position += velocity * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(damage)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
