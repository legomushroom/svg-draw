define 'block', ['backbone', 'underscore', 'helpers', 'ProtoClass', 'hammer', 'path', 'ports-collection', 'port', 'event'], (B, _, helpers, ProtoClass, hammer, Path, PortsCollection, Port, Event)->

	class Block extends ProtoClass
		type:  			'block'
		defaults:
			isValid: 					false
			startIJ: 					{i:0, j:0}
			endIJ: 						{i:0, j:0}
			isDragMode:				true
			isValidPosition: 	true
			isValidSize: 			false

		
		initialize:(@o={})->
			@set 
				'id': helpers.genHash()
			if @o.coords
				coords 	= App.grid.normalizeCoords App.grid.getNearestCell @o.coords or {x: 0, y: 0}
				@set 
					'startIJ': coords
					'endIJ': coords

			@ports = new PortsCollection
			window.ports = @ports
			@release = _.bind @release, @

			# @ports.on 'destroy', => console.log 'destroy'

			@render()
			@on 'change', _.bind @render, @

			@

		createPort:(o)-> 
			o.parent = @

			# destroy the old port if it exists
			portDirection = if o.path?.currentAddPoint is 'startIJ' then 'from' else 'in'
			(o.path?.get portDirection)?.destroy()

			port = new Port o
			@ports.add port
			port

		createEvent:(o)-> 
			o.parent = @
			# destroy the old port if it exists
			portDirection = if o.path?.currentAddPoint is 'startIJ' then 'from' else 'in'
			(o.path?.get portDirection)?.destroy()

			port = new Event o
			@ports.add port
			port

		render:->
			@calcDimentions()
			# @removeOldSelfFromGrid()
			if !@$el?
				@$el = $('<div>').addClass('block-e').append($('<div>')); App.$main.append @$el
				@listenEvents()

			startIJ = @get 'startIJ'
			@$el.css(
				'width': 	@get('w')*App.gs
				'height': @get('h')*App.gs
				'top':    startIJ.j*App.gs
				'left':   startIJ.i*App.gs)
				.toggleClass('is-invalid', !@get('isValid') or (	@get('w')*App.gs < App.gs ) or (@get('h')*App.gs < App.gs ) )

			@

		calcDimentions:->
			startIJ = @get('startIJ')
			endIJ 	= @get('endIJ')
			@set 	
						'w': endIJ.i - startIJ.i
						'h': endIJ.j - startIJ.j

			@refreshPort()

		listenEvents:->
			hammer(@$el[0]).on 'touch', (e)=>
				coords = App.grid.normalizeCoords helpers.getEventCoords e

				if App.currTool is 'path'
					port = @createPort
												coords: 			@getNearestPort coords
												positionType: 'fixed'

					App.isBlockToPath = port.path

				if App.currTool is 'event'
					port = @createEvent
												coords: 			@getNearestPort coords
												positionType: 'fixed'

					App.isBlockToPath = port.path

				helpers.stopEvent e

			hammer(@$el[0]).on 'drag', (e)=>
				if App.blockDrag then return true
				coords = helpers.getEventCoords e
				if App.currTool is 'block'
					@moveTo {x: e.gesture.deltaX, y:  e.gesture.deltaY}
					helpers.stopEvent e

				if App.currTool is 'path'
					@highlightCurrPort e

			hammer(@$el[0]).on 'release', @release

			@$el.on 'mouseenter', =>
				if @isDragMode then return
				
				App.currBlock = @
				if App.currTool is 'path'
					@$el.addClass 'is-connect-path'
				# else @$el.addClass 'is-drag'

			@$el.on 'mouseleave', (e)=>
				@highlighted  		and App.grid.lowlightCell(@highlighted)
				@highlightedEvent and App.grid.lowlightEvent(@highlightedEvent)
				if @isDragMode then return

				App.currBlock = null
				if App.currTool is 'path'
					@$el.removeClass 'is-connect-path'
				# else @$el.removeClass 'is-drag'

			@$el.on 'mousemove', (e)=>
				if App.currTool is 'path'
					@highlightCurrPort e

				if App.currTool is 'event'
					@highlightCurrPort e

		# placeCurrentEvent:(e)->
		# 	@highlightedEvent and App.grid.lowlightEvent(@highlightedEvent)
		# 	if !App.currBlock then return true
		# 	portCoords = @translateToNearestPort e, true
		# 	App.grid.highlightEvent portCoords
		# 	@highlightedEvent = portCoords

		highlightCurrPort:(e)->
			@highlighted and App.grid.lowlightCell(@highlighted)
			if !App.currBlock then return true
			portCoords = @translateToNearestPort e
			App.grid.highlightCell portCoords
			@highlighted = portCoords

		translateToNearestPort:(e, isEvent)->
			coords = App.grid.normalizeCoords helpers.getEventCoords e
			relativePortCoords = App.currBlock.getNearestPort coords
			# coef = if relativePortCoords.side is 'startIJ' and !isEvent then -1 else 0
			coef = if relativePortCoords.side is 'startIJ' then -1 else 0
			if relativePortCoords.dir is 'j'
				if relativePortCoords.side is 'startIJ'
					i = App.currBlock.get(relativePortCoords.side).i + relativePortCoords.coord
					j = App.currBlock.get(relativePortCoords.side).j + coef
				else 
					i = App.currBlock.get('startIJ').i + relativePortCoords.coord
					j = App.currBlock.get(relativePortCoords.side).j + coef
			else 
				if relativePortCoords.side is 'startIJ'
					i = App.currBlock.get(relativePortCoords.side).i + coef
					j = App.currBlock.get(relativePortCoords.side).j + relativePortCoords.coord
				else 
					i = App.currBlock.get(relativePortCoords.side).i + coef
					j = App.currBlock.get('startIJ').j + relativePortCoords.coord

			i: i
			j: j


		release:(e)->
			@highlighted and App.grid.lowlightCell(@highlighted)

			coords = helpers.getEventCoords e
			coordsIJ = App.grid.normalizeCoords coords
			if App.currTool is 'path' or App.currTool is 'event'
				if App.currPath and App.currBlock

					method = if App.currTool is 'path' then 'Port' else 'Event'
					coords = App.currBlock.getNearestPort coordsIJ
					port = App.currBlock["create#{method}"]
																path: App.currPath
																coords: coords
																positionType: 'fixed'

					App.currPath.currentAddPoint = null
					App.isBlockToPath = null

			else 
				@addFinilize()
				return false

			helpers.stopEvent e

		getNearestPort:(ij)->
			startIJ = @get('startIJ')
			endIJ 	= @get('endIJ')

			# console.log startIJ, endIJ
			
			i = (startIJ.i + @get('w')/2) - ij.i  - 1
			j = (startIJ.j + @get('h')/2)  - ij.j - 1
			
			if Math.abs(i) >= Math.abs(j)
				dir = 'i'
				side = if i < 0 then 'endIJ' else 'startIJ'
				coord = ij.j - startIJ.j
			else
				dir = 'j'
				side = if j < 0 then 'endIJ' else 'startIJ'
				coord = ij.i - startIJ.i

			portCoords = 
				dir: dir
				side: side
				coord: coord

		moveTo:(coords)->
			@removeSelfFromGrid()
			coords = App.grid.normalizeCoords coords
			
			if !@isMoveTo
				@buffStartIJ 	= helpers.cloneObj @get('startIJ')
				@buffEndIJ 		= helpers.cloneObj @get('endIJ')
				@isMoveTo 		= true

			top  		= (@buffStartIJ.j + coords.j)
			bottom 	= (@buffEndIJ.j + coords.j)

			left 	=  @buffStartIJ.i + coords.i
			right =  @buffEndIJ.i + coords.i

			if top < 0
				shift = top
				top = 0
				bottom = top + @get 'h'

			if left < 0 
				shift = left
				left = 0 
				right = left + @get 'w'

			@setToGrid {i: left, 	j: top }, {i: right, 	j: bottom }

			@set
				'startIJ': 	{i: left, 	j: top }
				'endIJ': 		{i: right, 	j: bottom }
				'isValid':  @isSuiteSize()



		setSizeDelta:(deltas)->
			startIJ = @get('startIJ')
			@set 
				'endIJ': 		{i: startIJ.i+deltas.i, j: startIJ.j+deltas.j}
				'isValid':  @isSuiteSize()

		isSuiteSize:->
			startIJ = @get('startIJ')
			endIJ 	= @get('endIJ')
			@isValidPosition = true
			for i in [startIJ.i...endIJ.i]
				for j in [startIJ.j...endIJ.j]
					node = App.grid.grid.getNodeAt i, j
					if node.block? and (node.block.get('id') isnt @get('id'))
						@set 'isValidPosition', false
						return false

			@calcDimentions()
			isValidSize = @get('w') > 0 and @get('h') > 0
			@set 
				'isValidSize': 			isValidSize
				'isValidPosition': 	true
			isValidSize

		addFinilize:->
			@isMoveTo = false
			if !@get('isValid') and !@get('isValidSize')
				@removeSelf(); return false
			else if !@get 'isValidPosition'
				@set
					'startIJ': 					helpers.cloneObj @buffStartIJ
					'endIJ': 						helpers.cloneObj @buffEndIJ
					'isValid':  				true
					'isValidPosition': 	true

			@isDragMode = false
			@setToGrid()

		refreshPort:-> @ports.each (port)=> port.setIJ()

		setToGrid:(startIJ, endIJ)->
			startIJ ?= @get 'startIJ'
			endIJ 	?= @get 'endIJ'
			for i in [startIJ.i...endIJ.i]
				for j in [startIJ.j...endIJ.j]
					if !App.grid.holdCell {i:i, j:j}, @
						@set('isValid', false); return false

			App.grid.refreshGrid()
			true

		######### REMOVE SECTION
		removeSelf:-> @removeSelfFromGrid(); @removeSelfFromDom();
		removeSelfFromGrid:->
			startIJ = @get('startIJ')
			endIJ 	= @get('endIJ')
			for i in [startIJ.i...endIJ.i]
				for j in [startIJ.j...endIJ.j]
					App.grid.releaseCell {i:i, j:j}, @
			App.grid.refreshGrid()

		removeSelfFromDom:-> @$el.remove()

		removeOldSelfFromGrid:->
			return if !@buffStartIJ?
			for i in [@buffStartIJ.i...@buffEndIJ.i]
				for j in [@buffStartIJ.j...@buffEndIJ.j]
					App.grid.releaseCell {i:i, j:j}, @
			App.grid.refreshGrid()



	Block











