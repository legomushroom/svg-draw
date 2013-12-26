define 'path', ['jquery', 'helpers', 'ProtoClass', 'line', 'underscore'], ($, helpers, ProtoClass, Line, _)->
	class Path extends ProtoClass
		type: 'path'

		initialize:(@o={})->
			@set 'id', helpers.genHash()


			if @o.coords
				@set 
					'startIJ': 	App.grid.toIJ @o.coords
					'endIJ': 		App.grid.toIJ @o.coords

			@on 'change', _.bind @onChange, @


		onChange:-> 
			@set 'oldIntersects', helpers.cloneObj @get 'intersects'
			@render()

		render:(isRepaintIntersects=false)->
			@removeFromGrid()
			@recalcPath()
			@makeLine()
			App.grid.refreshGrid()

		recalcPath:->
			path = App.grid.getGapPolyfill 
								from: @get 'startIJ'
								to: 	@get 'endIJ'


			points = []
			for point, i in path 
				ij = {i: point[0], j: point[1]}; xy = App.grid.fromIJ ij
				node = App.grid.atIJ ij
				node.holders ?= {}

				node.holders[@get 'id'] = @

				point = { x: xy.x, y: xy.y, curve: null, i: i }
				points.push(point)
			
			@attributes.points = points
			@calcPolar()
			@

		calcPolar:->
			points = @get 'points'
			firstPoint  = points[0]
			lastPoint 	= points[points.length-1]
			@attributes.xPolar = if firstPoint.x < lastPoint.x then 'plus' else 'minus'
			@attributes.yPolar = if firstPoint.y < lastPoint.y then 'plus' else 'minus'

		repaintIntersects:(intersects)->
			for name, path of intersects
				continue if path.id is @id 
				path.render [path.id]
			@set 'oldIntersects', {}

		detectCollisions:()->
			@set 'intersects', {}
			for point in @get 'points'
				myDirection = @directionAt point
				node = App.grid.at point
				if _.size(node.holders) > 1
					_.chain(node.holders).where(type: 'path').each (holder)=>
						@set 'intersects', (@get('intersects')[holder.id] = holder)

					for name, path of @get 'intersects'
						continue if path.get 'id' is @get 'id'
						point.curve = "#{myDirection}" if myDirection isnt path.directionAt(point) and path.directionAt(point) isnt 'corner' and myDirection isnt 'corner'

		directionAt:(xy)->
			points = @get 'points'
			point = _.where(points, {x: xy.x, y: xy.y})[0]
			if !point then return 'corner'
			if points[point.i-1]?.x is point.x and points[point.i+1]?.x is point.x
				direction = 'vertical'
			else if points[point.i-1]?.y is point.y and points[point.i+1]?.y is point.y
				direction = 'horizontal'
			else direction = 'corner'
			direction


		makeLine:()-> 
			if !@line? then @line = new Line path: @ else @line.resetPoints @get 'points'

		removeFromGrid:->
			points = @get 'points'
			return if !points?
			for point in points
				node = App.grid.at(point)
				delete node.holders[@get 'id']

		removeIfEmpty:-> 
			if @isEmpty()
				console.log('is empty')
				@line.remove()
				@removeFromGrid()
			App.grid.refreshGrid()

		isEmpty:-> 
			console.log(@)
			@line?.get('points').length <= 2

	Path