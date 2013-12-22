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


		onChange:-> 
			@render()

		render:(isRepaintIntersects=true)->
			@removeFromGrid()
			@recalcPath()

			@detectCollisions()
			# isRepaintIntersects and @repaintIntersects()
			@makeLine()
			App.grid.refreshGrid()

		recalcPath:->
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

		repaintIntersects:(isRepaintIntersects=false)->
			for name, path of @intersects
				continue if path.id is @id
				path.render isRepaintIntersects

		detectCollisions:()->
			console.log @intersects
			@intersects = {}
			for point in @points
				myDirection = @directionAt point
				node = App.grid.at point
				if _.size(node.holders) > 1
					_.chain(node.holders).where(type: 'path').each (holder)=>
						@intersects[holder.id] = holder

					for name, holder of @intersects
						continue if holder.id is @id
						point.curve = "#{myDirection}" if myDirection isnt holder.directionAt point

		directionAt:(xy)->
			point = _.where(@points, {x: xy.x, y: xy.y})[0]
			if @points[point.i-1]?.x is point.x and @points[point.i+1]?.x is point.x
				direction = 'vertical'
			else if @points[point.i-1]?.y is point.y and @points[point.i+1]?.y is point.y
				direction = 'horizontal'
			else direction = 'corner'
			direction

		makeLine:()-> if !@line? then @line = new Line points: @points else @line.resetPoints @points

		removeFromGrid:->
			return if !@points?
			for point in @points
				node = App.grid.at(point)
				delete node.holders[@id]

		removeIfEmpty:-> @isEmpty() and @line.remove()

		isEmpty:-> @line.points.length <= 2

	Path