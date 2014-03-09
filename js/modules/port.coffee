define 'port', ['ProtoClass', 'path', 'helpers', 'hammer'], (ProtoClass, Path, helpers, hammer)->
	class Port extends ProtoClass
		defaults:
			size: 1
			type: 'port'

		initialize:(@o={})->
			@path = null

			@o.parent and (@set 'parent', @o.parent)

			@set 'coords', @o.coords
			@setIJ()

			@addConnection @o.path
			@render()
			@events()
			@onChange()
			@on 'change:ij', _.bind @onChange, @

			@

		events:->
			hammer(@el).on 'drag', (e)=>
				coords = App.grid.normalizeCoords helpers.getEventCoords e
				App.currPath = @path
				@set 'ij', coords
				e.preventDefault()
				e.stopPropagation()

			hammer(@el).on 'touch', (e)=> helpers.stopEvent(e)

			hammer(@el).on 'release', (e)=>
				switch @get 'type'
					when 'event' 
						coords = App.currBlock.getNearestPort App.currBlock.placeCurrentEvent e
					when 'port' 
						coords = App.currBlock.getNearestPort App.grid.normalizeCoords helpers.getEventCoords e
				@set 
						'coords': coords
						'parent': App.currBlock

				@setIJ()
				App.currPath = null
				e.preventDefault()
				e.stopPropagation()


		onChange:->
			connection = @get 'connection'
			connection.path.set "#{connection.direction}IJ", @get 'ij'

			App.grid.refreshGrid()
			@render()

		render:->
			@el ?= @createDomElement()
			ij 		= @get('ij')
			size 	= @get('size')
			size = size*App.gs
			@addition = @normalizeCoords()
			x = (ij.i*App.gs)+@addition.x
			y = (ij.j*App.gs)+@addition.y
			connection =  @get 'connection'
			if connection.direction is 'start'
				@el.css
					left: "#{x}px"
					top:  "#{y}px"
			else
				App.SVG.setAttributes @el, 
					transform: "translate(#{x},#{y}) rotate(#{@addition.angle},#{App.gs/2},#{App.gs/2})"

		normalizeCoords:->
			returnValue = null
			if @get('connection').direction is 'end'
				returnValue = @normalizeArrowCoords()
			else 
				returnValue = @normalizePortCoords()
			returnValue

		normalizePortCoords:->
			coords = @get 'coords'
			size = @get('size')
			sizeU = size*App.gs
			x 	= 0
			y 	= 0
			if coords.dir is 'i'
				if coords.side is 'startIJ'
					x = sizeU/2
				else 
					x = -sizeU/2
			else 
				if coords.side is 'startIJ'
					y = sizeU/2
				else 
					y = -sizeU/2

			x: x
			y: y

		normalizeArrowCoords:->
			coords = @get 'coords'
			angle  = 0
			x 	= 0
			y 	= 0
			if coords.dir is 'i'
				if coords.side is 'startIJ'
					angle = -90
					x = (App.gs/2) + 2
				else 
					angle = 90
					x = -(App.gs/2) - 2
			else 
				if coords.side is 'startIJ'
					y = (App.gs/2) + 2
				else 
					angle = 180
					y = -(App.gs/2) - 2

			angle: 	angle
			x: x
			y: y
			
		createDomElement:->
			connection =  @get 'connection'
			size 	= @get('size')
			if connection.direction is 'start'
				$portEl = $('<div></div>')
				$portEl.css
					width:  size*App.gs
					height: size*App.gs
					'border-radius': '50%'
					'position': 'absolute'

				$portEl.addClass  'port'

				App.$main.append $portEl
				el = $portEl
			else 
				size = App.gs
				attrs =
					width:  size
					height: size
					class: 'port-arrow'
					points: "3,0 #{size - 3},0 #{size/2},#{size - 10}"

				el = App.SVG.createElement 'polygon', attrs
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


			@set 'connection',
													direction: direction
													path: path
													id: App.helpers.genHash()
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
