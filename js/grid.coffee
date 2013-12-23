define 'grid', ['path-finder', 'underscore'], (PathFinder, _)->
	window._ = _
	class Grid
		constructor:(@o={})->
			@w = @o.width  or 100
			@h = @o.height or 100
			
			@pf = PathFinder
			@grid 	= new PathFinder.Grid @w, @h
			@finder = new PathFinder.IDAStarFinder
											allowDiagonal: 		true
											dontCrossCorners: true
											heuristic: @pf.Heuristic.manhattan

			@debugGrid = []
			@
			
		holdCell:(ij, obj)->
			ij = if ij.x then @toIJ ij else ij
			node = @grid.getNodeAt(ij.i, ij.j)

			
			if !node.walkable and (node.holder.id isnt obj.id)
				console.error 'Hold cell error - current cell is already taken'
				return false

			node.walkable = false
			node.holder = obj
			true

		releaseCell:(ij, obj)->
			ij = if ij.x then @toIJ ij else ij
			
			node = @grid.getNodeAt(ij.i, ij.j)
			if node.holder?.id is obj.id
				node.walkable = true
				node.holder = null

		atIJ:(ij)-> @grid.getNodeAt(ij.i, ij.j)
		at:(xy)-> ij = @normalizeCoords(xy);@grid.getNodeAt(ij.i, ij.j)

		normalizeCoords:(coords)-> if coords.x? then @toIJ coords else coords

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
			from = fromTo.from
			to   = fromTo.to
			
			if from.x
				from = @toIJ 	from
				to = @toIJ 		to

			@gridBackup = @grid.clone()
			@finder.findPath from.i, from.j, to.i, to.j, @gridBackup


		toIJ:(coords)->
			result = 
				i: ~~(coords.x/App.gs)
				j: ~~(coords.y/App.gs)

		fromIJ:(ij)->
			result =
				x: ij.i*App.gs+(App.gs/2)
				y: ij.j*App.gs+(App.gs/2)

		isFreeCell:(coords)->
			if coords.x
				ij = @toIJ(coords)
			else ij = coords

			@grid.isWalkableAt ij.i, ij.j

		# ifBlockCell:(coords)->
		# 	if coords.x
		# 		ij = @toIJ(coords)
		# 	else ij = coords

		# 	node = @grid.getNodeAt(ij.i, ij.j)
		# 	return if node.holder?.type is 'block' then node.holder else false


		# DEBUG SECTION
		refreshGrid:->
			return if !App.debug.isGrid 
			@clearGrid()
			for j in [0...@h]
				for i in [0...@w]
					if _.size((@grid.getNodeAt i, j).holders)
						attrs = 
							x: "#{i}em"
							y: "#{j}em"
							width: 	"1em"
							height: "1em"
							fill: 'rgba(255,255,255,.15)'
						rect = App.SVG.createElement 'rect', attrs
						App.SVG.lineToDom null, rect
						@debugGrid.push rect

		clearGrid:->
			for rect in @debugGrid
				App.SVG.removeElem rect
			@debugGrid.length = 0


	Grid




















