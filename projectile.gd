extends Area2D

var velocity = Vector2.ZERO
@export var speed = 400
@export var damage: int = 1
@export var lifetime: float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VisibleOnScreenEnabler2D.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)
	body_entered.connect(_on_body_entered)
	add_to_group("projectile")
	await get_tree().create_timer(lifetime).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(1)  # Call mob’s method to handle damage
		queue_free()         # Destroy the projectile

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
