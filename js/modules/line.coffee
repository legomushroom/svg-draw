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
				'marker-end': 		'url(#marker-start)'

			@line = App.SVG.createElement 'path', attr
			@serialize()
			App.SVG.lineToDom @get('id'), @line

		serialize:->
			str = ''
			for point, i in @get('points')
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

