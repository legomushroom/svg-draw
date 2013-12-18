define 'path', ['two', 'jquery', 'helpers', 'ProtoClass'], (Two, $, helpers, ProtoClass)->
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

			@addLine (path[0][0]*App.gs)+(App.gs/2), (path[0][1]*App.gs)+(App.gs/2)

			for point, i in path 
				if i is 0 then continue
				xy = App.grid.fromIJ {i: point[0], j: point[1]}
				@line.vertices.push helpers.makePoint xy.x, xy.y

		addLine:(x,y)->
			@line?.remove(); @line = App.two.makeLine(x, y, x, y)
			@line.noFill().stroke = @o.strokeColor or "#00DFFC" 
			@line.linewidth = @o.strokeWidth or 2

			for vert in @line.vertices
				vert.addSelf @line.translation
			@line.translation.clear()
			setTimeout (=> @$dom = $("#two-#{@line.id}"); @addMarkers()), 25

		removeIfEmpty:-> @isEmpty() and @line.remove()

		isEmpty:-> @line.vertices.length <= 2

		coordsToTwo:(x,y)->
			if arguments.length <= 1
				y = x.y
				x = x.x

			v = new Two.Vector x, y
			v.position = new Two.Vector().copy v
			v

		addMarkers:->
			@$dom.attr 'marker-mid', "url('#marker-mid')"



	Path