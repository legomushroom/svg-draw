define 'block', ['backbone', 'underscore', 'helpers', 'ProtoClass', 'hammer', 'path', 'port'], (B, _, helpers, ProtoClass, hammer, Path, Port)->

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

			@ports = []
			@render()
			@on 'change', _.bind @render, @

			@

		createPort:(o)-> 
			o.parent = @
			port = new Port o
			@ports.push port
			port

		render:->
			@calcDimentions()
			@removeOldSelfFromGrid()
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
				coords = helpers.getEventCoords e
				coordsIJ = App.grid.normalizeCoords coords
				if App.currTool is 'path'
					port = @createPort
												coords: coordsIJ

					App.isBlockToPath = port.path
				helpers.stopEvent e

			hammer(@$el[0]).on 'drag', (e)=>
				if App.blockDrag then return true
				coords = helpers.getEventCoords e
				if App.currTool is 'block'
					@moveTo {x: e.gesture.deltaX, y:  e.gesture.deltaY}
					helpers.stopEvent e


			hammer(@$el[0]).on 'release', (e)=>
				coords = helpers.getEventCoords e
				if App.currTool is 'path'
					if App.currPath and App.currBlock
						port = App.currBlock.createPort App.currPath
						App.currPath.currentAddPoint = null
						App.isBlockToPath = null

				else 
					@removeOldSelfFromGrid()
					@addFinilize()
					return false

				helpers.stopEvent e

			@$el.on 'mouseenter', =>
				if @isDragMode then return
				
				App.currBlock = @
				if App.currTool is 'path'
					@$el.addClass 'is-connect-path'
				else @$el.addClass 'is-drag'

			@$el.on 'mouseleave', =>
				if @isDragMode then return

				App.currBlock = null
				if App.currTool is 'path'
					@$el.removeClass 'is-connect-path'
				else @$el.removeClass 'is-drag'

		moveTo:(coords)->
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

		refreshPort:-> 
			for port, i in @ports
				port.setIJ()

		setToGrid:->
			startIJ = @get 'startIJ'
			endIJ 	= @get 'endIJ'
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











