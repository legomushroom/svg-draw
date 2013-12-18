define 'block', ['helpers', 'ProtoClass', 'hammer', 'path', 'port'], (helpers, ProtoClass, hammer, Path, Port)->

	class Block extends ProtoClass
		type:  			'block'
		isValid: 		false
		startIJ: 		{i:0, j:0}
		endIJ: 		  {i:0, j:0}
		isDragMode: true

		constructor:(@o={})->
			@id = helpers.genHash()
			
			if @o.coords
				coords 	= App.grid.normalizeCoords App.grid.getNearestCell @o.coords or {x: 0, y: 0}
				@set 'startIJ', coords

			@createPorts()
			@onChange = @render
			@

		createPorts:->
			@ports = {}
			portRoles = ['top', 'bottom', 'left', 'right']
			for role, i in portRoles
				@ports[role] = new Port 
					role: 	portRoles[i]
					parent: @

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
			@refreshPorts()

		listenEvents:->
			hammer(@$el[0]).on 'touch', (e)=>
				coords = helpers.getEventCoords e
				if App.currTool is 'path'
					App.isBlockToPath = @getNearestPort(coords).addConnection()

			hammer(@$el[0]).on 'drag', (e)=>
				coords = helpers.getEventCoords e
				if App.currTool is 'block'
					@moveTo {x: e.gesture.deltaX, y:  e.gesture.deltaY}
					return false

			hammer(@$el[0]).on 'release', (e)=>
				coords = helpers.getEventCoords e
				if App.currTool is 'path'
					if App.currPath and App.currBlock
						App.currBlock.getNearestPort(coords).addConnection App.currPath
						App.isBlockToPath = null

				else 
					@removeOldSelfFromGrid()
					@addFinilize()
					return false


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
				@isMoveTo = true

			# console.log @buffStartIJ is @startIJ
			@set
				'startIJ': 	{i: @buffStartIJ.i + coords.i, j: @buffStartIJ.j + coords.j }
				'endIJ': 		{i: @buffEndIJ.i + coords.i, j: @buffEndIJ.j + coords.j }
				'isValid':  @isSuiteSize()

		getNearestPort:(coords)->
			ij = App.grid.normalizeCoords coords
			min = 
				ij:
					i: 9999999999
					j: 9999999999
				port: null

			for portName, port of @ports
				i = Math.abs( port.ij.i - ij.i ); j = Math.abs( port.ij.j - ij.j )
				if min.ij.i > i or min.ij.j > j
					min.ij 		= {i: i, j: j}
					min.port 	= port

			if min.port is null then @ports['bottom'] else min.port

		setSizeDelta:(deltas)->
			@set 
				'endIJ': 		{i: @startIJ.i+deltas.i, j: @startIJ.j+deltas.j}
				'isValid':  @isSuiteSize()

		isSuiteSize:->
			for i in [@startIJ.i...@endIJ.i]
				for j in [@startIJ.j...@endIJ.j]
					node = App.grid.grid.getNodeAt i, j
					return false if !node.walkable and (node.holder.id isnt @id)

			@calcDimentions()
			@w > 0 and @h > 0

		addFinilize:->
			@isMoveTo = false
			if !@isValid then @removeSelf(); return false
			@setToGrid()
			@isDragMode = false
			

		refreshPorts:->
			for portName, port of @ports
				port.setIJ()

		setToGrid:->
			for i in [@startIJ.i...@endIJ.i]
				for j in [@startIJ.j...@endIJ.j]
					if !App.grid.holdCell {i:i, j:j}, @
						@set('isValid', false); return false

			App.grid.refreshGrid()
			true

		######### REMOVE SECTION
		removeSelf:-> @removeSelfFromGrid(); @removeSelfFromDom();
		removeSelfFromGrid:->
			for i in [@startIJ.i...@endIJ.i]
				for j in [@startIJ.j...@endIJ.j]
					App.grid.releaseCell {i:i, j:j}, @
			App.grid.refreshGrid()

		removeSelfFromDom:-> @$el.remove()

		removeOldSelfFromGrid:->
			for i in [@buffStartIJ.i...@buffEndIJ.i]
				for j in [@buffStartIJ.j...@buffEndIJ.j]
					App.grid.releaseCell {i:i, j:j}, @
			App.grid.refreshGrid()



	Block











