define 'port', ['ProtoClass', 'path'], (ProtoClass, Path)->
	class Port extends ProtoClass
		
		constructor:(@o={})->
			@o.parent and (@parent = @o.parent)
			@o.role 	and (@role = @o.role)
			@connections ?= []
			@setIJ @o.role
			@

		onChange:->
			for connection,i in @connections 
				connection.path.set "#{connection.direction}IJ", @ij

			App.grid.refreshGrid()

		addConnection:(path)->
			direction = ''
			if !path?
				path = new Path
				path.connectedTo = @parent
				path.set 
					'startIJ': @ij
					'endIJ': 	 @ij
				direction = 'start'
			else 
				path.set 'endIJ': @ij
				direction = 'end'

			@connections.push {
													direction: direction
													path: path
													id: App.helpers.genHash()
												}

			path

		setIJ:->
			i = @parent.startIJ.i + ~~(@parent.w/2)
			j = @parent.startIJ.j + ~~(@parent.h/2)
			@set 'ij', {i: i, j:j }
			@


	Port
