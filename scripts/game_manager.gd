extends Node

var score = 0

#Signal to check whether player hits the other
var player1_hits = false
var player2_hits = false

#Position of the sword hitbox for knockback
var p1_sword_pos_right = false
var p2_sword_pos_right = false

@onready var score_label = $ScoreLabel


func add_point():
	score += 1
	score_label.text = "You collected " + str(score) + " coins."
