define 'grid', ['path-finder'], (PathFinder)->
	class Grid
		constructor:(@o={})->
			@w = @o.width  or 100
			@h = @o.height or 100
			
			@pf = PathFinder
			@grid 	= new PathFinder.Grid @w, @h
			@finder = new PathFinder.AStarFinder
											allowDiagonal: 		true
											dontCrossCorners: true

			@debugGrid = []
			@

		toIJ:(coords)->
			result = 
				i: ~~(coords.x/App.gs)
				j: ~~(coords.y/App.gs)

		fromIJ:(ij)->
			result =
				x: ij.i*App.gs+(App.gs/2)
				y: ij.j*App.gs+(App.gs/2)

		isFreeCell:(coords)->
			ij = @toIJ(coords)
			@grid.isWalkableAt ij.i, ij.j
			
		holdCell:(ij, obj)->
			ij = if ij.x then @toIJ ij else ij
			node = @grid.getNodeAt(ij.i, ij.j)

			if obj.isHoldCell 
				node.walkable = false
				node.holder = obj
			else 
				node.lines ?= {}
				node.lines[obj.id] = obj
				console.log node.lines.length

				
			# if !node.walkable and (node.holder.id isnt obj.id)
			# 	console.error 'Hold cell error - current cell is already taken'
			# 	return false


			@refreshGrid()

		releaseCell:(ij, obj)->
			ij = if ij.x then @toIJ ij else ij
			
			if @grid.isWalkableAt ij.i, ij.j
				console.warn 'Release cell warning - current cell is already empty'
				return

			node = @grid.getNodeAt(ij.i, ij.j)
			node.walkable = true
			node.holder = null
			@refreshGrid()

		holdCellXY:(coords, obj)->
			ij = @toIJ(coords)
			@holdCell ij, obj

		getNearestCell:(coords)->
			x = App.gs * ~~(coords.x / App.gs)
			y = App.gs * ~~(coords.y / App.gs)

			result = 
				x: x
				y: y

		getNearestCellCenter:(coords)->
			coords = @getNearestCell(coords)
			result = 
				x: coords.x + (App.gs/2)
				y: coords.y + (App.gs/2)

		getGapPolyfill:(fromTo)->
			from = @toIJ fromTo.from
			to   = @toIJ fromTo.to
			@gridBackup = @grid.clone()
			@finder.findPath from.i, from.j, to.i, to.j, @gridBackup


		# DEBUG SECTION
		refreshGrid:->
			return if !App.debug.isGrid 
			@clearGrid()
			for j in [0...@h]
				for i in [0...@w]
					node = @grid.getNodeAt i, j
					if node.walkable is false or node.lines?.length > 0
						rect = App.two.makeRectangle (i*App.gs)+(App.gs/2), (j*App.gs)+(App.gs/2), App.gs, App.gs
						rect.fill = 'rgba(255,255,255,.15)'
						rect.noStroke()
						@debugGrid.push rect

		clearGrid:->
			for rect in @debugGrid
				rect.remove()

			@debugGrid.length = 0


	Grid




















