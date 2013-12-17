define 'block', ['helpers', 'ProtoClass', 'hammer', 'path'], (helpers, ProtoClass, hammer, Path)->

	class Block extends ProtoClass
		type:  	'block'
		isValid: false
		sizeIJ:  		{i:1, j:1}
		newSizeIJ: 	{i:0, j:0}
		paths: []

		constructor:(@o={})->
			@id = helpers.genHash()
			@coords = App.grid.getNearestCell @o.coords or {x: 0, y: 0}
			@ij 		= App.grid.toIJ {x: @coords.x, y: @coords.y}
			@addSelfToDom()
			@onChange = @render
			@

		addSelfToDom:->
			@$el = $('<div>').addClass('block-e').append($('<div>')); App.$main.append @$el
			@set {'top': 	@coords.y, 'left': @coords.x}
			@listenEvents()
			@

		listenEvents:->
			hammer(@$el[0]).on 'touch', =>
				if App.currTool is 'path'
					@connectPath()

		connectPath:->
			@connectPath = new Path
			@connectPath.connectedTo = @
			@paths.push @connectPath
			App.isBlockToPath = @connectPath


 
		dragResize:(deltas)->
			deltas = App.grid.getNearestCell deltas
			@newSizeIJ  = App.grid.toIJ deltas

			@set 
				'isValid': @isSuiteSize()
				'w': deltas.x
				'h': deltas.y

			@

		isSuiteSize:->
			for i in [@ij.i+@sizeIJ.i...@ij.i+@newSizeIJ.i]
				for j in [@ij.j+@sizeIJ.j...@ij.j+@newSizeIJ.j]
					node = App.grid.grid.getNodeAt i, j
					return false if !node.walkable and (node.holder.id isnt @id)

			@newSizeIJ.i > 0 and @newSizeIJ.j > 0


		setToGrid:->
			for i in [@ij.i...@ij.i+@newSizeIJ.i]
				for j in [@ij.j...@ij.j+@newSizeIJ.j]
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
			for i in [@ij.i...@ij.i+@newSizeIJ.i]
				for j in [@ij.j...@ij.j+@newSizeIJ.j]
					App.grid.releaseCell {i:i, j:j}, @

		removeSelfFromDom:-> @$el.remove()

	Block











