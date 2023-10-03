extends CharacterBody2D

var target = Vector2.ZERO
var speed = 10.0
var width = 0
var time_highlight = 0.4
var time_highlight_size = 0.3
var tween

func _ready():
	width = $CollisionShape2D.get_shape().size.x
	target = Vector2(Global.VP.x / 2, Global.VP.y - 60)

func _physics_process(_delta):
	target.x = clamp(target.x, 0, Global.VP.x - width)
	position = target

func _input(event):
	if event is InputEventMouseMotion:
		target.x += event.relative.x

func hit(_ball):
	$Confetti.emitting = true
	if tween:
		tween.kill()
	tween = create_tween().set_parallel(true)
	$Images/Highlight.modulate.a = 1.0
	tween.tween_property($Images/Highlight, "modulate:a", 0, time_highlight)
	$Images/Highlight.scale = Vector2(1.5,1.5)
	tween.tween_property($Images/Highlight, "scale", Vector2(1,1), time_highlight_size).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	
