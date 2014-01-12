define 'port', ['ProtoClass', 'path'], (ProtoClass, Path)->
	class Port extends ProtoClass
		initialize:(@o={})->
			@path = null

			console.log('create Port')

			@o.parent and (@set 'parent', @o.parent)
			@set 'connections': 	[]

			@set 'coords', @o.coords
			@setIJ()

			@addConnection @o.path
			@on 'change:ij', _.bind @onChange, @

			@

		onChange:->
			for connection,i in @get 'connections'
				connection.path.set "#{connection.direction}IJ", @get 'ij'

			App.grid.refreshGrid()

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

					path.set 'in', @

				else
					path.set 	
										'endIJ': 				@get 'ij'
										'connectedEnd': @get 'parent'
					
					path.set 'from', @



			connections = @get('connections')
			connections.push {
													direction: direction
													path: path
													id: App.helpers.genHash()
												}

			@set 'connections', connections
			@path = path
			path

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

	Port
