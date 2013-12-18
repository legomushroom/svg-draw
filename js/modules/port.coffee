define 'port', ['ProtoClass', 'path'], (ProtoClass, Path)->
	class Port extends ProtoClass
		connections: []
		ij: null
		constructor:(@o={})->
			@o.parent and (@parent = @o.parent)
			@o.role 	and (@role = @o.role)
			@setIJ @o.role
			@

		onChange:->
			for conection in @connections
				connection.set 'startIJ', @ij

		addConnection:(path)->
			if !path
				path = new Path
				path.connectedTo = @parent
				path.set 
					'startIJ': @ij
					'endIJ': 	 @ij

				@connections.push path
			else path.set 'endIJ', {i:@ij.i-1, j: @ij.j}

			path

		setIJ:(role)->
			switch (role or @role)
				when 'top'
					i = @parent.startIJ.i + ~~(@parent.newSizeIJ.i/2)
					j = @parent.startIJ.j
					@set 'ij', {i: i, j:j }

				when 'bottom'
					i = @parent.startIJ.i + ~~(@parent.newSizeIJ.i/2)
					j = @parent.startIJ.j + @parent.newSizeIJ.j - 1
					@set 'ij', {i: i, j:j }

				when 'left'
					i = @parent.startIJ.i
					j = @parent.startIJ.j + ~~(@parent.newSizeIJ.j/2)
					@set 'ij', {i: i, j:j }

				when 'right'
					i = @parent.startIJ.i + @parent.newSizeIJ.i - 1
					j = @parent.startIJ.j + ~~(@parent.newSizeIJ.j/2)
					@set 'ij', {i: i, j:j }

			@


	Port
