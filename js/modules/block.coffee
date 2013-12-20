define 'block', ['helpers', 'ProtoClass', 'hammer', 'path', 'port'], (helpers, ProtoClass, hammer, Path, Port)->

	class Block extends ProtoClass
		type:  			'block'
		
		constructor:(@o={})->
			@id = helpers.genHash()
			@isValid= 		false
			@startIJ= 		{i:0, j:0}
			@endIJ= 		  {i:0, j:0}
			@isDragMode= 	true
			
			if @o.coords
				coords 	= App.grid.normalizeCoords App.grid.getNearestCell @o.coords or {x: 0, y: 0}
				@set 'startIJ', coords

			@createPort()
			@render()
			@onChange = @render

			@

		createPort:-> @port = new Port parent: @

		render:->
			@calcDimentions()
			if !@$el?
				@$el = $('<div>').addClass('block-e').append($('<div>')); App.$main.append @$el
				@listenEvents()

			@$el.css(
				'width': 	@w*App.gs
				'height': @h*App.gs
				'top':    @startIJ.j*App.gs
				'left':   @startIJ.i*App.gs)
				.toggleClass('is-invalid', !@isValid or (	@w*App.gs < App.gs ) or (@h*App.gs < App.gs ) )

			@

		calcDimentions:->
			@w = @endIJ.i - @startIJ.i
			@h = @endIJ.j - @startIJ.j
			@refreshPort()

		listenEvents:->
			hammer(@$el[0]).on 'touch', (e)=>
				coords = helpers.getEventCoords e
				if App.currTool is 'path'
					App.isBlockToPath = @port.addConnection()

				helpers.stopEvent e

			hammer(@$el[0]).on 'drag', (e)=>
				coords = helpers.getEventCoords e
				if App.currTool is 'block'
					@moveTo {x: e.gesture.deltaX, y:  e.gesture.deltaY}
					helpers.stopEvent e


			hammer(@$el[0]).on 'release', (e)=>
				coords = helpers.getEventCoords e
				if App.currTool is 'path'
					if App.currPath and App.currBlock
						App.currBlock.port.addConnection App.currPath
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
				@buffStartIJ 	= @startIJ
				@buffEndIJ 		= @endIJ
				@isMoveTo 		-= true

			top  		= (@buffStartIJ.j + coords.j)
			bottom 	= (@buffEndIJ.j + coords.j)

			left 	=  @buffStartIJ.i + coords.i
			right =  @buffEndIJ.i + coords.i

			if top < 0
				shift = top
				top = 0
				bottom = top + @h

			if left < 0 
				shift = left
				left = 0 
				right = left + @w

			@set
				'startIJ': 	{i: left, 	j: top }
				'endIJ': 		{i: right, 	j: bottom }
				'isValid':  @isSuiteSize()


		setSizeDelta:(deltas)->
			@set 
				'endIJ': 		{i: @startIJ.i+deltas.i, j: @startIJ.j+deltas.j}
				'isValid':  @isSuiteSize()

		isSuiteSize:->
			# for i in [@startIJ.i...@endIJ.i]
			# 	for j in [@startIJ.j...@endIJ.j]
			# 		node = App.grid.grid.getNodeAt i, j
			# 		return false if !node.walkable and (node.holder.id isnt @id)

			@calcDimentions()
			@w > 0 and @h > 0

		addFinilize:->
			@isMoveTo = false
			if !@isValid then @removeSelf(); return false
			@isDragMode = false
			

		refreshPort:-> @port.setIJ()

		setToGrid:->
			# for i in [@startIJ.i...@endIJ.i]
			# 	for j in [@startIJ.j...@endIJ.j]
			# 		if !App.grid.holdCell {i:i, j:j}, @
			# 			@set('isValid', false); return false

			App.grid.refreshGrid()
			true

		######### REMOVE SECTION
		removeSelf:-> @removeSelfFromGrid(); @removeSelfFromDom();
		removeSelfFromGrid:->
			# for i in [@startIJ.i...@endIJ.i]
			# 	for j in [@startIJ.j...@endIJ.j]
			# 		App.grid.releaseCell {i:i, j:j}, @
			App.grid.refreshGrid()

		removeSelfFromDom:-> @$el.remove()

		removeOldSelfFromGrid:->
			# for i in [@buffStartIJ.i...@buffEndIJ.i]
			# 	for j in [@buffStartIJ.j...@buffEndIJ.j]
			# 		App.grid.releaseCell {i:i, j:j}, @
			App.grid.refreshGrid()



	Block











