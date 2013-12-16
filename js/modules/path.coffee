define 'path', ['two', 'jquery', 'helpers'], (Two, $, helpers)->
	class Path
		constructor:(@o={})->
			@line = App.two.makeLine(@o.coords.x, @o.coords.y, @o.coords.x, @o.coords.y)
			@line.noFill().stroke = @o.strokeColor or "#00DFFC" 
			@line.linewidth = @o.strokeWidth or 2

			App.grid.holdCell @o.coords

			for vert in @line.vertices
				vert.addSelf @line.translation
			@line.translation.clear()
			setTimeout (=> @$dom = $("#two-#{@line.id}"); @addMarkers()), 25

		removeIfEmpty:->
			return if @line.vertices.length > 2
			App.grid.releaseCell { x: @line.vertices[0].x, y: @line.vertices[0].y}
			@line.remove()


		addPoint:(coords)->
			coords = App.grid.getNearestCellCenter coords
			twojsCoords = helpers.makePoint coords.x, coords.y

			App.settings.isSmartPath and @fillGapOnAdd coords
			
			@pushPoint twojsCoords

		fillGapOnAdd:(coords)->
			xGap = Math.abs(@line.vertices[@line.vertices.length-1].x - coords.x) > App.gs
			yGap = Math.abs(@line.vertices[@line.vertices.length-1].y - coords.y) > App.gs


			if xGap or yGap 
				path = App.grid.getGapPolyfill 
										from: {x:@line.vertices[@line.vertices.length-1].x, y:@line.vertices[@line.vertices.length-1].y}
										to:   {x:coords.x, y:coords.y}

				@addPathToLine path

		addPathToLine:(path)->
			for coord, i in path
				if i is 0 or i is path.length - 1 then continue
				xy = App.grid.fromIJ {i: coord[0], j: coord[1]}
				@pushPoint helpers.makePoint xy.x, xy.y


		pushPoint:(point)->
			App.grid.holdCell point
			@line.vertices.push point








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