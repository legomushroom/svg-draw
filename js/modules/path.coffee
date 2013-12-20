define 'path', ['jquery', 'helpers', 'ProtoClass', 'line'], ($, helpers, ProtoClass, Line)->
	class Path extends ProtoClass
		type: 'path'
		isHoldCell: false
		constructor:(@o={})->
			@id = helpers.genHash()

			if @o.coords
				@set 
					startIJ: 	App.grid.toIJ @o.coords
					endIJ: 		App.grid.toIJ @o.coords


		onChange:-> @render()

		render:->
			path = App.grid.getGapPolyfill 
								from: @startIJ
								to: 	@endIJ

			points = []
			for point, i in path 
				xy = App.grid.fromIJ {i: point[0], j: point[1]}
				points.push helpers.makePoint xy.x, xy.y
			@addLine points

		addLine:(points)-> @line?.remove(); @line = new Line points: points

		removeIfEmpty:-> @isEmpty() and @line.remove()

		isEmpty:-> @line.points.length <= 2

	Path