extends Node

var loops = 0

var suspects_killed = [false, false, false]
var worst_end = false

func reset():
	loops = 0
	suspects_killed = [false, false, false]
	worst_end = false
