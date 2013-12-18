define 'block', ['helpers', 'ProtoClass', 'hammer', 'path', 'port'], (helpers, ProtoClass, hammer, Path, Port)->

	class Block extends ProtoClass
		type:  	'block'
		isValid: false
		sizeIJ:  		{i:1, j:1}
		newSizeIJ: 	{i:0, j:0}
		paths: []

		constructor:(@o={})->
			@id = helpers.genHash()
			@coords = App.grid.getNearestCell @o.coords or {x: 0, y: 0}
			@startIJ 		= App.grid.toIJ {x: @coords.x, y: @coords.y}
			@addSelfToDom()
			@onChange = @render
			@createPorts()
			@

		createPorts:->
			@ports = {}
			portRoles = ['top', 'bottom', 'left', 'right']
			for role, i in portRoles
				@ports[role] = new Port 
					role: 	portRoles[i]
					parent: @

		addSelfToDom:->
			@$el = $('<div>').addClass('block-e').append($('<div>')); App.$main.append @$el
			@set {'top': 	@coords.y, 'left': @coords.x}
			@listenEvents()
			@

		listenEvents:->
			hammer(@$el[0]).on 'touch', (e)=>
				coords = helpers.getEventCoords e
				if App.currTool is 'path'
					@getNearestPort(coords).addConnection()

			hammer(@$el[0]).on 'release', (e)=>
				coords = helpers.getEventCoords e
				if App.currTool is 'path' and App.currPath
					@getNearestPort(coords).addConnection App.currPath

			@$el.on 'mouseenter', =>
				App.currBlock = @
				if App.currTool is 'path'
					@$el.addClass 'is-connect-path'

			@$el.on 'mouseleave', =>
				App.currBlock = null
				if App.currTool is 'path'
					@$el.removeClass 'is-connect-path'

		getNearestPort:(coords)->
			ij = App.grid.normalizeCoords coords
			min = 
				ij:
					i: -1
					j: -1
				port: null

			for portName, port of @ports
				console.log port.ij
				
				i = Math.abs( port.ij.i - ij.i ); j = Math.abs( port.ij.j - ij.j )
				console.log i, j

				if min.ij.i < i or min.ij.j < j
					min.ij 		= {i: i, j: j}
					min.port 	= port

			console.log min.port

			if min.port is null then @ports['bottom'] else min.port


		dragResize:(deltas)->
			deltas = App.grid.getNearestCell deltas
			@set 'newSizeIJ', App.grid.toIJ deltas
			@refreshPorts()

			@set 
				'isValid': @isSuiteSize()
				'w': deltas.x
				'h': deltas.y

			@

		refreshPorts:->
			for portName, port of @ports
				port.setIJ()


		isSuiteSize:->
			for i in [@startIJ.i+@sizeIJ.i...@startIJ.i+@newSizeIJ.i]
				for j in [@startIJ.j+@sizeIJ.j...@startIJ.j+@newSizeIJ.j]
					node = App.grid.grid.getNodeAt i, j
					return false if !node.walkable and (node.holder.id isnt @id)

			@newSizeIJ.i > 0 and @newSizeIJ.j > 0


		setToGrid:->
			for i in [@startIJ.i...@startIJ.i+@newSizeIJ.i]
				for j in [@startIJ.j...@startIJ.j+@newSizeIJ.j]
					if !App.grid.holdCell {i:i, j:j}, @
						@set('isValid', false); return false;

		render:->
			@$el.css(
				'width':  @w or 0
				'height': @h or 0
				'top':    @top  or 0
				'left':   @left or 0)

			.toggleClass('is-invalid', !@isValid or (@w < App.gs ) or (@h < App.gs ))

		addFinilize:->
			if !@isValid 
				@removeSelf()
				return false
			@setToGrid()
			App.grid.refreshGrid()

		removeSelf:-> @removeSelfFromGrid(); @removeSelfFromDom();

		removeSelfFromGrid:->
			for i in [@startIJ.i...@startIJ.i+@newSizeIJ.i]
				for j in [@startIJ.j...@startIJ.j+@newSizeIJ.j]
					App.grid.releaseCell {i:i, j:j}, @

		removeSelfFromDom:-> @$el.remove()

	Block











