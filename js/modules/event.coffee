define 'event', ['backbone', 'underscore', 'helpers', 'port'], (B, _, helpers, Port)->

	class Event extends Port
		constructor:(@o={})->
			console.log 'event init'

	Event