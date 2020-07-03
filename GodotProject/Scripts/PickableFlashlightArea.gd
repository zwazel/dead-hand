extends Area

signal pickUp

func interact():
	emit_signal("pickUp")
