define 'port', ['ProtoClass', 'path'], (ProtoClass, Path)->
	class Port extends ProtoClass
		connections: []
		ij: null
		constructor:(@o={})->
			@o.parent and (@parent = @o.parent)
			@setIJ @o.role
			@

		onChange:->
			console.log 'change'
			for conection in @connections
				connection.set 'startIJ', @ij

		addConnection:()->
			path = new Path
			path.connectedTo = @parent
			path.set 
				'startIJ': @ij
				'endIJ': 	 @ij

			@connections.push path
			path

		setIJ:(role=@role)->
			switch role
				when 'top'
					i = @parent.startIJ.i + ~~((@parent.startIJ.i + @parent.sizeIJ.i)/2)
					j = @parent.startIJ.j
					console.log i,j
					@set 'ij', {i: i, j:j }

			@


	Port
