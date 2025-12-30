class_name Scene extends Node2D

@onready var player : CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var camera : CameraController = get_tree().get_first_node_in_group("camera")
