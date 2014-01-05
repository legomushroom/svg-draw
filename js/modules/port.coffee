define 'port', ['ProtoClass', 'path'], (ProtoClass, Path)->
	class Port extends ProtoClass
		initialize:(@o={})->
			@path = null

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

		setIJ:->
			if @get('positionType') isnt 'fixed'
				parent = @get 'parent'
				parentStartIJ = parent.get 'startIJ'
				i = parentStartIJ.i + ~~(parent.get('w')/2)
				j = parentStartIJ.j + ~~(parent.get('h')/2)
			else
				coords = @get('coords')
				parent = @get('parent')

				if coords.dir is 'i'
					i 	= parent.get(coords.side).i
					j 	= parent.get('startIJ').j + coords.coord
				else
					j = parent.get(coords.side).j
					i = parent.get('startIJ').i + coords.coord

				# console.log i, j, coords.dir

			@set 'ij', {i: i, j:j }

			@


	Port
