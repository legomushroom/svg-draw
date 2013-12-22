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
				if i is 0 
					str += "M#{point.x},#{point.y} "
				else
					if !point.curve? 
						str += "L #{point.x}, #{point.y} " 
					else
						xShift = 0
						yShift = 0
						xRadius = 0
						yRadius = 0
						if point.curve is 'vertical'
							yShift = App.gs/2
							yRadius = App.gs
						else if point.curve is 'horizontal'
							xShift = App.gs/2
							xRadius = App.gs

						str += "L #{point.x - xShift}, #{point.y - yShift} "
						str += "a1,1 0 0,1 #{xRadius},#{yRadius} "

			App.SVG.setAttribute.call @line, 'd', str
			@

		resetPoints:(points)-> @points = points; @serialize(); @

		remove:-> @removeFromDom(); return @

		removeFromDom:-> App.SVG.canvas.removeChild @line