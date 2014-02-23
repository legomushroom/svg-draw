define 'line', ['ProtoClass', 'helpers', 'hammer'], (ProtoClass, helpers, hammer)->
	class Line extends ProtoClass
		initialize:(@o={})->
			@set 'id', helpers.genHash()
			path = @o.path
			@set 'path', @o.path
			@set 'points', path.get 'points'
			@addContainer()
			@serialize()
			@

		addContainer:->
			@g = App.SVG.createElement 'g', { id: @.get 'id' }
			@events()

		events:->
			hammer($(@g)).on 'touch', (e)=>
				@currentDragHandle = e.target
				@preventEvent e
			hammer($(@g)).on 'drag', (e)=>
				@dragHandle e
				@preventEvent e
			hammer($(@g)).on 'release', (e)=>
				@currentDragHandle = null
				@preventEvent e

		dragHandle:(e)->
			$segment = $ @currentDragHandle
			data = $segment.data()
			coords = App.grid.getNearestCellCenter App.helpers.getEventCoords e
			points = @get 'points'		
				
			if data.direction is 'x'
				points[data.segment].y 	= coords.y
				points[data.segment+1].y = coords.y
			else 
				points[data.segment].x 	= coords.x
				points[data.segment+1].x = coords.x

			@serialize()


		preventEvent:(e)->
			e.stopPropagation()
			e.preventDefault()
			false

		addDomElement:->
			attr = 
				stroke: 				'#00DFFC'
				'stroke-width': 2
				fill: 					'none'
				'marker-mid': 		'url(#marker-mid)'
				# 'marker-start': 	'url(#marker-start)'
				# 'marker-end': 		'url(#marker-end)'

			@line = App.SVG.createElement 'path', attr
			@g.appendChild @line
			!@appended and App.SVG.lineToDom(@g)
			@appended = true
			

		serialize:->
			@removeFromDom()
			@addDomElement()
			str = ''
			points = @get('points')
			for point, i in points
				if i is 0 
					str += "M#{point.x},#{point.y} "
				else
					if !point.curve? 
						str += "L#{point.x},#{point.y} " 
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
			@addHandles(points)
			@


		addHandles:(points)->
			points ?= @get('points')
			@handles = []
			for point, i in points
				if (i >= points.length-2) or (i is 0) then continue
				nextPoint = points[i+1]
				isY = if point.x is nextPoint.x then true else false
				@handles.push 
							x: if isY then point.x else (point.x+nextPoint.x)/2
							y: if isY then (point.y+nextPoint.y)/2 else point.y
							segment: i
							direction: if isY then 'y' else 'x'

			@appendHandles()

		appendHandles:->
			for handle, i in @handles
				dir = handle.direction
				attr = 
					fill: 					'red'
					'marker-mid': 		'url(#marker-mid)'
					x: if dir is 'x' then handle.x - (App.gs) else handle.x - (App.gs/4)
					y: if dir is 'y' then handle.y - (App.gs/2) else handle.y - App.gs
					width:  if dir is 'y' then App.gs/2 else App.gs
					height: if dir is 'x' then App.gs/2 else App.gs
					class: 	'path-handle'
					id: 		'js-path-handle'
					'data-segment':   handle.segment
					'data-direction': handle.direction

				handleSvg = App.SVG.createElement 'rect', attr
				@g.appendChild handleSvg

		resetPoints:(points)-> @set 'points', points; @serialize(); @

		remove:-> @removeFromDom(); return @

		removeFromDom:-> 
			if !@g then return
			while @g.hasChildNodes()
				@g.removeChild(@g.lastChild)

