define 'event', ['backbone', 'underscore', 'helpers', 'port'], (B, _, helpers, Port)->

	class Event extends Port
		defaults:
			size: 2
	Event