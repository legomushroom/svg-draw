define 'path', ['jquery', 'helpers', 'ProtoClass', 'line', 'underscore', 'hammer'], ($, helpers, ProtoClass, Line, _, hammer)->
	class Path extends ProtoClass
		type: 'path'

		initialize:(@o={})->
			@set 'id', helpers.genHash()


			if @o.coords
				@set 
					'startIJ': 	App.grid.toIJ @o.coords
					'endIJ': 		App.grid.toIJ @o.coords

			@on 'change:startIJ', _.bind @onChange, @
			@on 'change:endIJ',		_.bind @onChange, @


		onChange:-> 
			console.log @
			@set 'oldIntersects', helpers.cloneObj @get 'intersects'
			@render()


		render:(isRepaintIntersects=false)->
			@removeFromGrid()
			@recalcPath()
			@makeSvgPath()
			App.grid.refreshGrid()

		pushPoint:(ij,i)->
			xy = App.grid.fromIJ ij
			node = App.grid.atIJ ij
			node.holders ?= {}

			node.holders[@get 'id'] = @

			point = { x: xy.x, y: xy.y, curve: null, i: i }
			@points.push(point)
			@points


		recalcPath:->
			helpers.timeIn 'path recalc'
			glimps = @makeGlimps()
			@points = []

			startIJ = @get('startIJ')
			endIJ = @get('endIJ')
			dir = glimps.direction
			@direction = dir
			@set 'direction', dir

			# if inPositionType isnt 'fixed' or fromPositionType isnt 'fixed'
			# 	startBlock 	= glimps.startBlock
			# 	endBlock 		= glimps.endBlock

			# 	startBlockEndIJ 		= if startBlock then startBlock.get('endIJ')   else @get('endIJ')
			# 	startBlockStartIJ 	= if startBlock then startBlock.get('startIJ') else @get('startIJ')

			# 	endBlockEndIJ 	= if endBlock then endBlock.get('endIJ') 		else @get('endIJ')
			# 	endBlockStartIJ = if endBlock then endBlock.get('startIJ')  else @get('startIJ')

			# 	fromPort = @get('from')
			# 	fromPositionType = fromPort?.get('positionType')

			# 	inPort = @get('in')
			# 	inPositionType = fromPort?.get('positionType')
			# 	# normalize start/end points to block size
			# 	if dir is 'i'
			# 		if @get('xPolar') is 'plus'
			# 			if startBlock and fromPositionType isnt 'fixed'
			# 				startIJ = {i: startBlockEndIJ.i,j: startIJ.j}
			# 			if endBlock and inPositionType isnt 'fixed'
			# 				endIJ = {i: endBlockStartIJ.i-1,j: endIJ.j}
			# 		else 
			# 			startIJ = {i: startBlockStartIJ.i-1,j: startIJ.j}
			# 			endIJ 	= {i: endBlockEndIJ.i,j: endIJ.j}
			# 	else 
			# 		if @get('yPolar') is 'plus'
			# 			if startBlock and fromPositionType isnt 'fixed'
			# 				startIJ = {i: startIJ.i, j: startBlockEndIJ.j}
			# 			if endBlock and inPositionType isnt 'fixed'
			# 				endIJ = {i: endIJ.i, j: endBlockStartIJ.j-1}
			# 		else 
			# 			startIJ = {i: startIJ.i, j: startBlockStartIJ.j-1}
			# 			endIJ 	= {i: endIJ.i, j: endBlockEndIJ.j}

			# the first path console
			for i in [startIJ[dir]..Math.ceil(glimps.base)]
				if dir is 'i'
					ij = {i: i, j: startIJ.j}
				else
					ij = {i: startIJ.i, j: i}

				@pushPoint ij, i

			# the end path console
			for i in [Math.ceil(glimps.base)..endIJ[dir]]
				if dir is 'i'
					ij = {i: i, j: endIJ.j}
				else 
					ij = {i: endIJ.i, j: i}
				@pushPoint ij, i


			@set 'points', @points
			@calcPolar()
			helpers.timeOut 'path recalc'
			@

		makeGlimps:->
			startIJ 	= @get 'startIJ'
			endIJ 		= @get 'endIJ'
			startBlock = @get('connectedStart')
			endBlock 	 = @get('connectedEnd')

			startBlockW = if not startBlock then 0 else startBlock.get('w')/2
			startBlockH = if not startBlock then 0 else startBlock.get('h')/2

			endBlockW = if not endBlock then 0 else endBlock.get('w')/2
			endBlockH = if not endBlock then 0 else endBlock.get('h')/2

			if startIJ.i < endIJ.i
				end = (startIJ.i + startBlockW)
				xDifference =  (endIJ.i - endBlockW) - end
				xBase = end + (xDifference/2)
			else
				start = (endIJ.i + endBlockW)
				xDifference = (startIJ.i - startBlockW) - start
				xBase = start + (xDifference/2)

			if startIJ.j < endIJ.j
				end = (startIJ.j + startBlockH)
				yDifference =  (endIJ.j - endBlockH) - end
				yBase = end + (yDifference/2)
			else
				start = (endIJ.j + endBlockH)
				yDifference = (startIJ.j - startBlockH) - start
				yBase = start + (yDifference/2)

			baseDirection = if (xDifference >= yDifference) then 'i' else 'j'
			return returnValue =
								direction: baseDirection
								base: if baseDirection is 'i' then xBase else yBase
								startBlock: startBlock
								endBlock: 	endBlock

		calcPolar:->
			points = @get 'points'
			firstPoint  = points[0]
			lastPoint 	= points[points.length-1]
			@set 'xPolar', if firstPoint.x < lastPoint.x then 'plus' else 'minus'
			@set 'yPolar', if firstPoint.y < lastPoint.y then 'plus' else 'minus'

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


		makeSvgPath:()-> 
			if !@line?
				@line = new Line path: @ 
				hammer(@line.line).on 'touch', =>
					console.log 'touch'

			else @line.resetPoints @get 'points'

		removeFromGrid:->
			points = @get 'points'
			return if !points?
			for point in points
				node = App.grid.at(point)
				delete node.holders[@get 'id']

		removeIfEmpty:-> 
			if @isEmpty()
				@line.remove()
				@removeFromGrid()
			App.grid.refreshGrid()

		isEmpty:-> 
			@line?.get('points').length <= 2

	Path