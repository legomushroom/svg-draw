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


		getOrientation: (block,point,tobj) ->

			pt1 = {}
			pt2 = {}
			pt1.i = block.get('startIJ').i-1
			pt1.j = block.get('startIJ').j-1
			pt2.i  = block.get('endIJ').i;
			pt2.j  = block.get('endIJ').j;
			

			if tobj
				point1 = @transform(tobj,point)
				b1 = @transform(tobj,pt1)
				b2 = @transform(tobj,pt2)
				if b1.i>b2.i
					tmp = b1.i; b1.i = b2.i; b2.i = tmp
				if b1.j> b2.j
					tmp = b1.j; b1.j = b2.j; b2.j = tmp
			else
				point1 = point
				b1 = pt1 #block.get('startIJ')
				b2 = pt2 #block.get('endIJ')



			if point1.i == b1.i  #-1
				orient = 'W'
			else
				if point1.j == b1.j #-1 
					orient = 'N'
				else
					if point1.i == b2.i
						orient = 'E'
					else
						orient = 'S'
			return orient

		# создать объект для линейного преобразования координат
		# orientation - поворот 
		transfObject: (origin,orientation) ->

			tobj = {}
			tobj.i0 = origin.i
			tobj.j0 = origin.j
			tobj.ki = 1
			tobj.kj = 1

			if (orientation == 'W' or orientation == 'E')
				tobj.x = 'i'
				tobj.y = 'j'
			else
				tobj.x = 'j'
				tobj.y = 'i'


			if orientation == 'N' or orientation == 'W' 
				tobj.ki = -1
			if orientation == 'S' or orientation == 'W'
				tobj.kj = -1

			return tobj


		# линейное преобразование пространства - если back=true, то преобразуем в изначальную систему
		transform: (tobj,point,back) ->

			newPoint = {}
			if (back)
				newPoint[tobj.x] = tobj[tobj.x+'0']+point.i*tobj.ki;
				newPoint[tobj.y] = tobj[tobj.y+'0']+point.j*tobj.kj;
			else
				newPoint.i = (-tobj[tobj.x+'0']+point[tobj.x])/tobj.ki;
				newPoint.j = (-tobj[tobj.y+'0']+point[tobj.y])/tobj.kj;

			return newPoint

		rect: (p1,p2) ->
			b = {}
			b.left = Math.min(p1.i, p2.i)
			b.right = Math.max(p1.i, p2.i)
			b.top = Math.min(p1.j, p2.j)
			b.bottom = Math.max(p1.j, p2.j)
			return b

		recalcPath:->

			@points = []
			startIJ 	= @get 'startIJ'
			endIJ 		= @get 'endIJ'
			startBlock =  @get('connectedStart')
			endBlock 	 = @get('connectedEnd')


			if startBlock 
				oStart = @getOrientation(startBlock,startIJ)
			else
				oStart = "E"

			# трансформация
			t = @transfObject(startIJ,oStart)
			startPoint = @transform(t,startIJ)
			endPoint = @transform(t,endIJ)

			if endBlock
				oEnd = @getOrientation(endBlock,endIJ,t)
			else
				oEnd = "W"


			if (startPoint.i > endPoint.i) #and (startPoint.j < endPoint.j) and (oEnd!="W")

				tt = @transfObject(endIJ,oEnd)
				ep = @transform(tt,endIJ)
				sp = @transform(tt,startIJ)

				if ep.i<sp.i

					tmp = startPoint; startPoint = endPoint; endPoint = tmp
					tmp = startIJ; startIJ = endIJ; endIJ = tmp
					tmp = startBlock; startBlock = endBlock; endBlock = tmp

					#if startBlock 
					#	oStart = @getOrientation(startBlock,startIJ)
					#else
					#	oStart = "E"

					# трансформация
					#t = @transfObject(startIJ,oStart)
					startPoint = @transform(tt,startIJ)
					endPoint = @transform(tt,endIJ)
					t = tt


			if startBlock
				startBlockR = @rect(@transform(t,startBlock.get('startIJ')),@transform(t,startBlock.get('endIJ')))

			if endBlock 
				oEnd = @getOrientation(endBlock,endIJ,t)
				endBlock1 = @transform(t,endBlock.get('startIJ'))
				endBlock2 = @transform(t,endBlock.get('endIJ'))
				endBlockR = @rect(endBlock1,endBlock2)


			@pushPoint startIJ, 0

			console.log(oEnd)


			#if (endPoint.i>0)
			if oEnd == 'W'
				#intX = endPoint.i+Math.round(Math.abs(startIJ.i - endIJ.i)/2);
				intX = Math.round(endPoint.i/2);
				xy = {i: intX, j: 0}
				@pushPoint @transform(t,xy,true),1
				xy1 = {i: intX, j: endPoint.j}
				@pushPoint @transform(t,xy1,true),2

	

			if oEnd == 'N' or oEnd == 'S'
				if ((endPoint.j > 0) and (oEnd == 'N')) or ((endPoint.j < 0) and (oEnd == 'S'))
					# вправо и вниз
					xy = {i: endPoint.i, j: 0}
					@pushPoint @transform(t,xy,true),1
				else
					intX = Math.round(endPoint.i/2);
					
					if intX<=startBlockR.right
						intX = startBlockR.right+1
					
					if intX>=endBlockR.left
						intX = Math.max(endBlockR.left-1,startBlockR.right+1)

					if endBlockR.left<=(startBlockR.right+1)
						intX = endBlockR.right+1
					if intX>=0
						xy = {i: intX, j: 0}
						@pushPoint @transform(t,xy,true),1
					xy1 = {i: Math.max(intX,0), j: endPoint.j}
					@pushPoint @transform(t,xy1,true),2	

			if oEnd == 'E' 
					if endBlock and endBlockR.top<1 and endBlockR.bottom>0
						xy = {i: endBlockR.left-1, j: 0}
						@pushPoint @transform(t,xy,true),1
						xy = {i: endBlockR.left-1, j: endBlockR.top-1}
						@pushPoint @transform(t,xy,true),2
						xy = {i: endBlockR.right, j: endBlockR.top-1}
						@pushPoint @transform(t,xy,true),3
					else
						xy = {i: endPoint.i, j: 0}
						@pushPoint @transform(t,xy,true),1					


			@pushPoint endIJ, 33			


			cur = startIJ


			# helpers.timeIn 'path recalc'
			# glimps = @makeGlimps()
			# @points = []

			# startIJ = @get('startIJ')
			# endIJ = @get('endIJ')
			# dir = glimps.direction
			# @direction = dir
			# @set 'direction', dir
			# console.log @

			# # START SEGMENT
			# coef = if Math.ceil(glimps.base) > startIJ[dir] then 1 else -1

			# node = if dir is 'i'
			# 	App.grid.grid.getNodeAt startIJ[dir]+coef, startIJ.j
			# else App.grid.grid.getNodeAt startIJ.i, startIJ[dir]+coef

			# # if sibling cell is free then draw straight line
			# if !node.block
			# 	# the first path console
			# 	for i in [startIJ[dir]..Math.ceil(glimps.base)]
			# 		if dir is 'i'
			# 			ij = {i: i, j: startIJ.j}
			# 		else
			# 			ij = {i: startIJ.i, j: i}

			# 		@pushPoint ij, i

			# # if sibling cell isnt free then draw corner line
			# else 
			# 	if dir is 'i'
			# 		# calc nearest corner line point
			# 		x1 = startIJ.j - glimps.startBlock.get('startIJ').j 
			# 		x2 = glimps.startBlock.get('endIJ').j - startIJ.j
			# 		y1 = endIJ.j - startIJ.j
			# 		side = if x1+y1 < x2-y1 then 'startIJ' else 'endIJ'

			# 		coef = if side is 'startIJ' then 1 else 0
			# 		for i in [startIJ.j..glimps.startBlock.get(side).j-coef]
			# 			ij = {i: startIJ.i, j: i}
			# 			@pushPoint ij, i

			# 		for i in [startIJ.i..Math.ceil(glimps.base)]
			# 			ij = {i: i, j: glimps.startBlock.get(side).j-coef}
			# 			@pushPoint ij, i
			# 	else 
			# 		side = 'startIJ' 
			# 		coef = if side is 'startIJ' then 1 else 0
			# 		for i in [startIJ.i..glimps.startBlock.get(side).i-coef]
			# 			ij = {i: i, j: startIJ.j}
			# 			@pushPoint ij, i

			# 		for i in [startIJ.j..Math.ceil(glimps.base)]
			# 			ij = {i: glimps.startBlock.get(side).i-coef, j: i}
			# 			@pushPoint ij, i


			# # END SEGMENT

			# coef = if Math.ceil(glimps.base) > startIJ[dir] then -1 else 1

			# node = if dir is 'i'
			# 	App.grid.grid.getNodeAt endIJ[dir]+coef, endIJ.j
			# else App.grid.grid.getNodeAt endIJ.i, endIJ[dir]+coef

			# if !node.block
			# 	# the end path console
			# 	for i in [Math.ceil(glimps.base)..endIJ[dir]]
			# 		if dir is 'i'
			# 			ij = {i: i, j: endIJ.j}
			# 		else 
			# 			ij = {i: endIJ.i, j: i}
			# 		@pushPoint ij, i

			# else
			# 	# TODO 
			# 	# new path connectors algorithm for j direction
			# 	if dir is 'i'
			# 		block = glimps.endBlock or App.currBlock
			# 		if block
			# 			# calc nearest corner line point
			# 			x1 = endIJ.j - block.get('startIJ').j 
			# 			x2 = block.get('endIJ').j - endIJ.j
			# 			y1 = endIJ.j - startIJ.j
			# 			side = if x1+y1 > x2-y1 then 'startIJ' else 'endIJ'
						
			# 			# side = 'startIJ'
			# 			coef = if side is 'startIJ' then 1 else 0

			# 			for i in [Math.ceil(glimps.base)..endIJ.i]
			# 				ij = {i: i, j: block.get(side).j-coef}
			# 				@pushPoint ij, i

			# 			for i in [block.get(side).j-coef..endIJ.j]
			# 				ij = {i: endIJ.i, j: i}
			# 				@pushPoint ij, i

			# 	else 
			# 		block = glimps.endBlock or App.currBlock
			# 		if block
			# 			# calc nearest corner line point
			# 			side = 'startIJ'
			# 			coef = if side is 'startIJ' then 1 else 0

			# 			for i in [Math.ceil(glimps.base)..block.get(side).j-coef]
			# 				ij = {i: block.get(side).i-coef, j: i}
			# 				@pushPoint ij, i

			# 			for i in [block.get(side).i-coef..endIJ.i]
			# 				ij = {i: i, j: block.get(side).j-coef}
			# 				@pushPoint ij, i

						


					



			@set 'points', @points
			# @calcPolar()
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