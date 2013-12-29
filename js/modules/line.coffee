define 'line', ['ProtoClass', 'helpers'], (ProtoClass, helpers)->
	class Line extends ProtoClass
		initialize:(@o={})->
			@set 'id', helpers.genHash()
			path = @o.path
			@set 'path', @o.path
			@set 'points', path.get 'points'
			@addDomElement()
			@

		addDomElement:->
			attr = 
				id: 						@get 'id'
				d: 							''
				stroke: 				'#00DFFC'
				'stroke-width': 2
				fill: 					'none'
				'marker-mid': 		'url(#marker-mid)'
				'marker-start': 	'url(#marker-start)'
				'marker-end': 		'url(#marker-end)'

			@line = App.SVG.createElement 'path', attr
			@serialize()
			App.SVG.lineToDom @get('id'), @line

		serialize:->
			str = ''
			points = @get('points')
			# console.log(points)
			# points.unshift {i: points[0].x - App.gs/2, j: points[0].j}
			for point, i in points
				
				if i is 0 or i is @get('points').length-1
					if @get('path').direction is 'i' then point.x -= (App.gs/2)
					if @get('path').direction is 'j' then point.y -= (App.gs/2)

				if i is 0 
					str += "M#{point.x},#{point.y} "
				else
					if !point.curve? 
						str += "L #{point.x}, #{point.y} " 
					else
						xShift = yShift = xRadius = yRadius = 0
						if point.curve is 'vertical'
							yShift = App.gs/2
							yRadius = App.gs
							yShift = if @path.yPolar is 'minus' then yShift-App.gs else yShift
						else if point.curve is 'horizontal'
							xShift = App.gs/2
							xRadius = App.gs
							xShift = if @path.xPolar is 'minus' then xShift-App.gs else xShift

						xRadius = if @path.xPolar is 'minus' then -xRadius else xRadius
						yRadius = if @path.yPolar is 'minus' then -yRadius else yRadius

						str += "L #{point.x - xShift}, #{point.y - yShift} "
						str += "a1,1 0 0,1 #{xRadius},#{yRadius} "

			App.SVG.setAttribute.call @line, 'd', str
			@

		resetPoints:(points)-> @set 'points', points; @serialize(); @

		remove:-> @removeFromDom(); return @

		removeFromDom:-> App.SVG.canvas.removeChild @line

