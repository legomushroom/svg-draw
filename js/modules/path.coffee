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
			@removeFromGrid()
			path = App.grid.getGapPolyfill 
								from: @startIJ
								to: 	@endIJ

			@points = []
			for point, i in path 
				ij = {i: point[0], j: point[1]}; xy = App.grid.fromIJ ij
				node = App.grid.atIJ ij
				node.holders ?= {}

				node.holders[@id] = @

				point = { x: xy.x, y: xy.y, curve: null, i: i }
				@points.push point

			@detectCollisions @points
			@addLine @points
			App.grid.refreshGrid()

		detectCollisions:(points)->
			for point in points
				myDirection = @directionAt point
				node = App.grid.at point
				if _.size(node.holders) > 1
					for holder in _.where(node.holders, type: 'path')
						continue if holder.id is @id
						point.curve = "#{myDirection}" if myDirection isnt holder.directionAt point

						# console.log "myDirection: #{myDirection}"
						# console.log "collision direction: #{}"

		directionAt:(xy)->
			point = _.where(@points, {x: xy.x, y: xy.y})[0]
			if @points[point.i-1]?.x is point.x and @points[point.i+1]?.x is point.x
				direction = 'vertical'
			else if @points[point.i-1]?.y is point.y and @points[point.i+1]?.y is point.y
				direction = 'horizontal'
			else direction = 'corner'
			direction

		addLine:(points)-> if !@line? then @line = new Line points: @points else @line.resetPoints @points

		removeFromGrid:->
			return if !@points?
			for point in @points
				node = App.grid.at(point)
				delete node.holders[@id]

		removeIfEmpty:-> @isEmpty() and @line.remove()

		isEmpty:-> @line.points.length <= 2

	Path