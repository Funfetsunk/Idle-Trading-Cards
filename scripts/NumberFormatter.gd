extends Node

func fmt(value: float) -> String:
	if value >= 1_000_000_000.0:
		return "%.2fB" % (value / 1_000_000_000.0)
	elif value >= 1_000_000.0:
		return "%.2fM" % (value / 1_000_000.0)
	elif value >= 1_000.0:
		return "%.1fK" % (value / 1_000.0)
	elif value >= 10.0:
		return "%d" % int(value)
	else:
		return "%.1f" % value

func fmt_rate(rate: float) -> String:
	return fmt(rate) + " fl/s"

func fmt_time(unix_time: float) -> String:
	if unix_time <= 0:
		return "Never"
	var now = Time.get_unix_time_from_system()
	var diff = int(now - unix_time)
	if diff < 60:
		return "Just now"
	elif diff < 3600:
		return str(diff / 60) + "m ago"
	else:
		return str(diff / 3600) + "h ago"
