define 'grid', ['path-finder', 'underscore'], (PathFinder, _)->

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
			@highLights = {}
			@highLightsEvent = {}
			@
			
		holdCell:(ij, obj)->
			ij = if ij.x then @toIJ ij else ij
			node = @grid.getNodeAt(ij.i, ij.j)
			
			if node.block? and (node.block.id isnt obj.id)
				console.error 'Hold cell error - current cell is already taken'
				return false

			node.block = obj
			true

		releaseCell:(ij, obj)->
			ij = if ij.x? then @toIJ ij else ij
			
			node = @grid.getNodeAt(ij.i, ij.j)
			if node.block?.id is obj.id
				node.block = null

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

		isPathEndCell:(coords)->
			coords = @normalizeCoords coords

			node = @grid.getNodeAt coords.i, coords.j
			holders = node.holders
			path = holders[Object.keys(holders)[0]] if holders
			if path and path.get('startIJ').i is coords.i and path.get('startIJ').j is coords.j
				path.currentAddPoint = 'startIJ'
			
			path


		highlightCell:(coords, type)->
			return if @highLights["#{coords.i}#{coords.j}"]
			i = coords.i
			j = coords.j
			$div = $('<div/>')
			addition = @normalizePortCoords coords.coords, if App.currTool is 'path' then 1 else 2
			$div.css(
								left:"#{i*App.gs+addition.x}px"
								top:"#{j*App.gs+addition.y}px"
							).addClass("#{type}-ghost")

			App.$main.append $div
			@highLights["#{coords.i}#{coords.j}"] = $div

		normalizePortCoords:(coords,size)->
			sizeU = size*App.gs
			x 	= 0
			y 	= 0
			if coords.dir is 'i'
				if coords.side is 'startIJ'
					x = if size is 2 then 0 else sizeU/2
				else 
					x = -sizeU/2
			else 
				if coords.side is 'startIJ'
					y = if size is 2 then 0 else sizeU/2
				else 
					y = -sizeU/2

			x: x
			y: y


		lowlightCell:(coords)-> 
			if @highLights["#{coords.i}#{coords.j}"] 
				@highLights["#{coords.i}#{coords.j}"].remove()
				@highLights["#{coords.i}#{coords.j}"] = null


		# DEBUG SECTION
		refreshGrid:->
			return if !App.debug.isGrid 
			@clearGrid()
			for j in [0...@h]
				for i in [0...@w]
					if _.size((@grid.getNodeAt i, j).holders) or (@grid.getNodeAt i, j).block?
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




















