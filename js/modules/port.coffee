define 'port', ['ProtoClass', 'path'], (ProtoClass, Path)->
	class Port extends ProtoClass
		initialize:(@o={})->
			@path = null
			console.log  @o.coords

			@o.parent and (@set 'parent', @o.parent)
			@set 'connections': 	[]
			@setIJ()

			@addConnection @o.path
			@on 'change', _.bind @onChange, @

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
			if @positionType isnt 'fixed'
				
				parent = @get 'parent'
				parentStartIJ = parent.get 'startIJ'
				i = parentStartIJ.i + ~~(parent.get('w')/2)
				j = parentStartIJ.j + ~~(parent.get('h')/2)
				@set 'ij', {i: i, j:j }
			else 
				console.log 'custom port'
			@


	Port
