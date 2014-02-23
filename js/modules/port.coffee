define 'port', ['ProtoClass', 'path', 'helpers', 'hammer'], (ProtoClass, Path, helpers, hammer)->
	class Port extends ProtoClass
		defaults:
			size: 1
			type: 'port'

		initialize:(@o={})->
			@path = null

			@o.parent and (@set 'parent', @o.parent)
			@set 'connections': 	[]

			@set 'coords', @o.coords
			@setIJ()

			@addConnection @o.path
			@render()
			@events()
			@on 'change:ij', _.bind @onChange, @

			@

		events:->
			hammer(@el).on 'drag', (e)=>
				coords = App.grid.normalizeCoords helpers.getEventCoords e
				App.currPath = @path
				@set 'ij', coords
				e.preventDefault()
				e.stopPropagation()

			hammer(@el).on 'release', (e)=>
				switch @get 'type'
					when 'event' 
						coords = App.currBlock.getNearestPort App.currBlock.placeCurrentEvent e
					when 'port' 
						coords = App.currBlock.getNearestPort App.grid.normalizeCoords helpers.getEventCoords e
				@set 'coords', coords
				console.log coords
				@setIJ()
				App.currPath = null
				e.preventDefault()
				e.stopPropagation()


		onChange:->
			for connection,i in @get 'connections'
				connection.path.set "#{connection.direction}IJ", @get 'ij'

			App.grid.refreshGrid()
			@render()

		render:->
			@el ?= @createDomElement()
			ij = @get('ij')
			App.SVG.setAttributes @el, 
				x: ij.i*App.gs
				y: ij.j*App.gs
			
		createDomElement:->
			ij 		= @get('ij')
			size 	= @get('size')
			attrs =
				width:  size*App.gs
				height: size*App.gs
				fill: 	'orange'
			
			el = App.SVG.createElement 'rect', attrs
			App.SVG.lineToDom el
			el

		removeFromDom:->
			App.SVG.removeElem @el

		addConnection:(path)->
			direction = ''
			if !path?
				path = new Path
				path.set 
					'connectedStart': 	@get 'parent'
					'startIJ': 					@get 'ij'
					'endIJ': 	 					@get 'ij'
				direction = 'start'
				path.set 'from', @
			else 
				point = path.currentAddPoint or 'endIJ'
				direction = if point is 'startIJ' then 'start' else 'end'
				if point is 'startIJ'
					path.set 	
										'startIJ': 				@get 'ij'
										'connectedStart': @get 'parent'

					path.set 'from', @
				else
					path.set 	
										'endIJ': 				@get 'ij'
										'connectedEnd': @get 'parent'
					
					path.set 'in', @



			connections = @get('connections')
			connections.push {
													direction: direction
													path: path
													id: App.helpers.genHash()
												}

			@set 'connections', connections
			@path = path
			path

		###
		 * [setIJ set relative coordinates from nearest port/event object]
		###
		setIJ:->
			parent = @get 'parent'
			parentStartIJ = parent.get 'startIJ'

			if @get('positionType') isnt 'fixed'
				ij = 
					i: parentStartIJ.i + ~~(parent.get('w')/2)
					j: parentStartIJ.j + ~~(parent.get('h')/2)
			else
				coords = @get('coords')
				side = parent.get(coords.side)[coords.dir] - (if coords.side is 'startIJ' then 1 else 0)
				ij = if coords.dir is 'i'
						i: side
						j: parentStartIJ.j + coords.coord
				else
						i: parentStartIJ.i + coords.coord
						j: side

			@set 'ij', ij

			@

		destroy:->
			hammer(@el).off 'drag'
			@removeFromDom()
			super

	Port
