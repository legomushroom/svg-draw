define 'port', ['ProtoClass', 'path'], (ProtoClass, Path)->
	class Port extends ProtoClass
		
		constructor:(@o={})->
			@o.parent and (@parent = @o.parent)
			@o.role 	and (@role = @o.role)
			@connections ?= []
			@setIJ @o.role
			@

		onChange:->
			# console.log @connections 
			for path,i in @connections 
				# console.log "i:#{i}, #{path.direction}, #{@role}, connections: #{@connections.length}"
				path.set "#{path.direction}IJ", @ij

			App.grid.refreshGrid()

		addConnection:(path)->
			if !path
				path = new Path
				path.connectedTo = @parent
				path.set 
					'startIJ': @ij
					'endIJ': 	 @ij
					'direction': 'start'

			else path.set 
						'endIJ': @ij
						'direction': 'end'

			@connections.push path

			path

		setIJ:(role)->
			switch (role or @role)
				when 'top'
					i = @parent.startIJ.i + ~~(@parent.w/2)
					j = @parent.startIJ.j - 1
					@set 'ij', {i: i, j:j }

				when 'bottom'
					i = @parent.startIJ.i + ~~(@parent.w/2)
					j = @parent.startIJ.j + @parent.h
					@set 'ij', {i: i, j:j }

				when 'left'
					i = @parent.startIJ.i - 1
					j = @parent.startIJ.j + ~~(@parent.h/2)
					@set 'ij', {i: i, j:j }

				when 'right'
					i = @parent.startIJ.i + @parent.w
					j = @parent.startIJ.j + ~~(@parent.h/2)
					@set 'ij', {i: i, j:j }

			@


	Port
