extends Node

var score = 0

var player1_hit = false
var player2_hit = false

@onready var score_label = $ScoreLabel


func add_point():
	score += 1
	score_label.text = "You collected " + str(score) + " coins."
