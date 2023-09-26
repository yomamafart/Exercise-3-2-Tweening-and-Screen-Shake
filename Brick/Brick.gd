extends StaticBody2D

var score = 0
var new_position = Vector2.ZERO
var dying = false
var time_appear = 0.5
var time_fall = 0.8
var time_rotate = 1.0
var time_a = 0.8
var time_s = 1.2
var time_v = 1.5
var tween

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	position = new_position
	if score >= 100:
		$ColorRect.color = Color8(224,49,49)
	elif score >= 90:
		$ColorRect.color = Color8(255,146,43)
	elif score >= 80:
		$ColorRect.color = Color8(255,212,59)
	elif score >= 70:
		$ColorRect.color = Color8(148,216,45)
	elif score >= 60:
		$ColorRect.color = Color8(34,139,230)
	elif score >= 50:
		$ColorRect.color = Color8(132,94,247)
	elif score >= 40:
		$ColorRect.color = Color8(190,75,219)
	else:
		$ColorRect.color = Color8(134,142,150)

func _physics_process(_delta):
	if dying and not $Confetti.emitting and not tween:
		queue_free()

func hit(_ball):
	die()

func die():
	dying = true
	$CollisionShape2D.queue_free()
	Global.update_score(score)
	get_parent().check_level()
	$Confetti.emitting = true
