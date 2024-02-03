extends Node

signal PlayerMovedSignal
# Global reference to player
# Defined in player.gd (Godot loads autoload before loading other nodes)
# Keep 'player' inferred but not defined until after Player is loaded
#@onready var player : Node2D
