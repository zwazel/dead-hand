extends Spatial

signal electrocuteBot

func _on_Area_body_entered(body):
	if body.is_in_group("robots"):
		connect("electrocuteBot", body, "electrocute")
		emit_signal("electrocuteBot")
