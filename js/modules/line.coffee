define 'line', ['helpers'], (helpers)->
	class Line
		constructor:(@o={})->
			@id = helpers.genHash()
			@points = @o.points or []
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

			@line = App.SVG.createElement 'path', attr
			@serialize()
			App.SVG.lineToDom @id, @line

		serialize:->
			str = ''
			for point, i in @points
				str += "M#{point.x},#{point.y} " if i is 0
				str += if !point.type? then "L #{point.x}, #{point.y}" else str += "a1,1 0 0,1 #{App.gs},0"

			App.SVG.setAttribute.call @line, 'd', str
			@

		remove:-> @removeFromDom(); return @

		removeFromDom:-> App.SVG.canvas.removeChild @line