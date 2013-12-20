define 'line', ['helpers'], (helpers)->
	class Line
		constructor:(@o={})->
			@SVG = @o.SVG
			@id = helpers.genHash()
			@points = []
			@addDomElement()
			@

		addDomElement:->
			attr = 
				id: 						@id
				d: 							''
				stroke: 				'#00DFFC'
				'stroke-width': 2
				fill: 					'none'
				'marker-mid': 	'url(#marker-mid)'

			@line = @SVG.createElement 'path', attr
			@serialize()
			@SVG.lineToDom @id, @line

		serialize:->
			str = ''
			for point, i in @points
				str += "M#{point.x},#{point.y} " if i is 0
				str += if !point.type? then "L #{point.x}, #{point.y}" else str += "a1,1 0 0,1 #{App.gs},0"

			@SVG.setAttribute.call @line, 'd', str
			@