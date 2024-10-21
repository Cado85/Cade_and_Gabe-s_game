class_name MainMenu
extends Control

@onready var button: Button = $MarginContainer/HBoxContainer/VBoxContainer/Button
@onready var button_2: Button = $MarginContainer/HBoxContainer/VBoxContainer/Button2
@onready var button_3: Button = $MarginContainer/HBoxContainer/VBoxContainer/Button3
@onready var exit_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/Exit_Button as Button

@onready var start_level_1 = preload("res://scenes/Level_1.tscn") as PackedScene
@onready var start_level_2 = preload("res://scenes/Level_2.tscn") as PackedScene
@onready var start_level_3 = preload("res://scenes/Level_3.tscn") as PackedScene


func _ready():
	button.button_down.connect(on_button_pressed)
	button_2.button_down.connect(on_button_2_pressed)
	button_3.button_down.connect(on_button_3_pressed)
	exit_button.button_down.connect(on_exit_pressed)
	
func on_button_pressed():
	get_tree().change_scene_to_packed(start_level_1)
	
func on_button_2_pressed():
	get_tree().change_scene_to_packed(start_level_2)
	
func on_button_3_pressed():
	get_tree().change_scene_to_packed(start_level_3)
	
func on_exit_pressed():
		get_tree().quit()
