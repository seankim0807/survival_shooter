extends Node2D

@export var player_speed = 300
@export var bullet_speed = 600
@export var enemy_speed = 120
@export var spawn_rate = 1.0

var score = 0
var game_over = false

var bullets = []
var enemies = []

@onready var player = $Player
@onready var score_label = $ScoreLabel

func _ready():
	randomize()
	score_label.text = "Score: 0"

func _process(delta):
	if game_over:
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().reload_current_scene()
		return
	
	player_movement(delta)
	handle_shooting()
	move_bullets(delta)
	move_enemies(delta)
	check_collisions()

func player_movement(delta):
	var dir = Vector2.ZERO
	
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1
	if Input.is_action_pressed("ui_down"):
		dir.y += 1
	
	player.velocity = dir.normalized() * player_speed
	player.move_and_slide()

func handle_shooting():
	if Input.is_action_just_pressed("ui_accept"):
		var bullet = ColorRect.new()
		bullet.color = Color.YELLOW
		bullet.size = Vector2(6, 12)
		bullet.position = player.position
		add_child(bullet)
		bullets.append(bullet)

func move_bullets(delta):
	for b in bullets:
		b.position.y -= bullet_speed * delta

func spawn_enemy():
	var enemy = ColorRect.new()
	enemy.color = Color.RED
	enemy.size = Vector2(30, 30)
	enemy.position = Vector2(randi_range(0, 800), -20)
	add_child(enemy)
	enemies.append(enemy)

func move_enemies(delta):
	if randf() < spawn_rate * delta:
		spawn_enemy()
	
	for e in enemies:
		var dir = (player.position - e.position).normalized()
		e.position += dir * enemy_speed * delta

func check_collisions():
	for e in enemies:
		if e.get_rect().has_point(player.position):
			game_over = true
			score_label.text = "GAME OVER - Score: " + str(score) + " (Press Enter)"
	
	for b in bullets:
		for e in enemies:
			if e.get_rect().intersects(b.get_rect()):
				e.queue_free()
				b.queue_free()
				enemies.erase(e)
				bullets.erase(b)
				score += 1
				score_label.text = "Score: " + str(score)
				return
