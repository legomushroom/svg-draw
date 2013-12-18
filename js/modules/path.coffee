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


		# addLine:(coords, normalize)->
		# 	@ij = App.grid.toIJ coords

		# 	if normalize
		# 		console.log normalize
		# 		if App.grid.atIJ({i: @ij.i-1, j: @ij.j}).holder?.id is @connectedTo.id
		# 			coords.x -= App.gs/2

		# 		if App.grid.atIJ({i: @ij.i+1, j: @ij.j}).holder?.id is @connectedTo.id
		# 			coords.x += App.gs/2

		# 		if App.grid.atIJ({i: @ij.i, j: @ij.j-1}).holder?.id is @connectedTo.id
		# 			coords.y -= App.gs/2

		# 		if App.grid.atIJ({i: @ij.i, j: @ij.j+1}).holder?.id is @connectedTo.id
		# 			coords.y += App.gs/2

		# 	@line = App.two.makeLine(coords.x, coords.y, coords.x, coords.y)
		# 	@line.noFill().stroke = @o.strokeColor or "#00DFFC" 
		# 	@line.linewidth = @o.strokeWidth or 2

		# 	App.grid.holdCell coords, @

		# 	for vert in @line.vertices
		# 		vert.addSelf @line.translation
		# 	@line.translation.clear()
		# 	setTimeout (=> @$dom = $("#two-#{@line.id}"); @addMarkers()), 25

		

		# addPoint:(coords)->
		# 	coords = App.grid.getNearestCellCenter coords

		# 	if !@line
		# 		console.log coords
		# 		@addLine coords, true
		# 	else 
		# 		if !@alwaysRecalc
		# 			twojsCoords = helpers.makePoint coords.x, coords.y
		# 			App.settings.isSmartPath and @fillGapOnAdd coords
		# 			@pushPoint twojsCoords
		# 		else 
		# 			@newEndPoint coords

		# newEndPoint:(coords)->
		# 	# @ij
		# 	@endIJ = App.grid.toIJ coords
		# 	path = App.grid.getGapPolyfill 
		# 						from: @ij
		# 						to: 	@endIJ


		# 	@resetLine path

		# newStartPoint:(coords)-> console.log 'new start point'



		# resetLine:(path)->
		# 	@line?.remove()
		# 	@line = App.two.makeLine((path[0][0]*App.gs)+(App.gs/2), (path[0][1]*App.gs)+(App.gs/2), (path[0][0]*App.gs)+(App.gs/2), (path[0][1]*App.gs)+(App.gs/2))
		# 	@line.noFill().stroke = @o.strokeColor or "#00DFFC" 
		# 	@line.linewidth = @o.strokeWidth or 2

		# 	for vert in @line.vertices
		# 		vert.addSelf @line.translation
		# 	@line.translation.clear()
		# 	setTimeout (=> @$dom = $("#two-#{@line.id}"); @addMarkers()), 25

		# 	for point, i in path 
		# 		if i is 0 then continue
		# 		xy = App.grid.fromIJ {i: point[0], j: point[1]}
		# 		@line.vertices.push helpers.makePoint xy.x, xy.y


		# fillGapOnAdd:(coords)->
		# 	xGap = Math.abs(@line.vertices[@line.vertices.length-1].x - coords.x) > App.gs
		# 	yGap = Math.abs(@line.vertices[@line.vertices.length-1].y - coords.y) > App.gs


		# 	if xGap or yGap 
		# 		path = App.grid.getGapPolyfill 
		# 								from: {x:@line.vertices[@line.vertices.length-1].x, y:@line.vertices[@line.vertices.length-1].y}
		# 								to:   {x:coords.x, y:coords.y}

		# 		@addPathToLine path

		# addPathToLine:(path)->
		# 	for coord, i in path
		# 		if i is 0 or i is path.length - 1 then continue
		# 		xy = App.grid.fromIJ {i: coord[0], j: coord[1]}
		# 		@pushPoint helpers.makePoint xy.x, xy.y


		# pushPoint:(point)->
		# 	App.grid.holdCell point, @
		# 	@line.vertices.push point


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