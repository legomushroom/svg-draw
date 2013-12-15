App = {}

# Array Remove - By John Resig (MIT Licensed)
Array::remove = (from, to) ->
  rest = @slice((to or from) + 1 or @length)
  @length = (if from < 0 then @length + from else from)
  @push.apply this, rest

App.helpers = 
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

	timeIn:(name)->
		console.time name
	timeOut:(name)->
		console.timeEnd name

	genHash:->
		md5 (new Date) + (new Date).getMilliseconds() + Math.random(9999999999999) + Math.random(9999999999999) + Math.random(9999999999999)

	grid:
		timeIn:(name)->
			App.dev.time and console.time name
		timeOut:(name)->
			App.dev.time and console.timeEnd name

		make:->
			App.grid = []
			for j in [0...App.gYCnt]
				line = []
				for i in [0...App.gXCnt]
					line.push 0
				App.grid.push line
		
		isFreeCell:(coords)->
			ij = @toIJ(coords)
			App.grid[ij.j][ij.i] is 0

		toIJ:(coords)->
			result = 
				i: ~~(coords.x/App.gs)
				j: ~~(coords.y/App.gs)

		holdCell:(ij, obj)->
			App.grid[ij.j][ij.i] = obj.id
			@refreshGrid()


		refreshGrid:->
			App.dev.grid and App.paths.refreshGrid()

		holdCellXY:(coords, obj)->
			ij = @toIJ(coords)
			@holdCell ij, obj

		isNewSegment:(segments, ij)->
			return if not segments.length
			for segment, i in segments
				ijLocal = @toIJ segment.point
				
				if (ijLocal.i is ij.i) and (ijLocal.j is ij.j)
					segments.remove i
					return true

		reposit:(obj)->
			@timeIn 'reposit'

			if obj instanceof $
				$obj = obj; metrics = @getNodeIJMetrics $obj
				id = $obj.data().id
				for line, j in App.grid
					for cell, i in line
						if cell is id
							App.grid[j][i] = 0
				@posit obj
			else
				segments = obj.segments.slice(0)

				for line, j in App.grid
					for cell, i in line
						if cell is obj.id
							App.grid[j][i] = 0
						if @isNewSegment(segments, {i: i, j: j})
							App.grid[j][i] = obj.id

			@refreshGrid()

			@timeOut 'reposit'

		posit:(obj)->
			if obj instanceof $
				$obj = obj; metrics = @getNodeIJMetrics $obj
				id = $obj.data().id
				for i in [metrics.coords.i..metrics.coords.i+metrics.size.i]
					for j in [metrics.coords.j..metrics.coords.j+metrics.size.j]
						App.grid[j][i] = id

			@refreshGrid()

		getNodeIJMetrics:($obj)->
			position = $obj.position()
			coords = @toIJ(x: position.left, y: position.top)
			size 	 = @toIJ(x: $obj.width(),  y: $obj.height())
			metrics =
				coords: coords
				size: size


