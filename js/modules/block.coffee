define 'block', ['helpers'], (helpers)->
	class Block
		constructor:(@o={})->
			@id = helpers.genHash()
			@type = 'block'
			@isHoldCell = true

			@isValid = true
			@sizeIJ = {i:1, j:1}
			
			@coords = @o.coords or {x: 0, y: 0}
			@coords = App.grid.getNearestCell @coords

			@addSelfToDom()

			@ij = App.grid.toIJ {x: @coords.x, y: @coords.y}

			App.grid.holdCell @ij, @

			@
		addSelfToDom:->
			@$el = $('<div>').addClass('block-e')
			App.$main.append @$el
			@top = @coords.y
			@left = @coords.x
			@render()

			@

		dragResize:(deltas)->
			deltas = App.grid.getNearestCell deltas
			@newSizeIJ  = App.grid.toIJ deltas
			@w = deltas.x
			@h = deltas.y

			@isValid = @isSuiteSize()


			@render()
			@

		isSuiteSize:->
			for i in [@ij.i+@sizeIJ.i..@ij.i+@newSizeIJ.i]
				for j in [@ij.j+@sizeIJ.j..@ij.j+@newSizeIJ.j]
					node = App.grid.grid.getNodeAt i, j
					return false if !node.walkable and (node.holder.id isnt @id)

			true
			# for i in [@ij.i..@sizeIJ.i]
			# 	for j in [@ij.j..@sizeIJ.j]
			# 		console.log App.grid.grid.isWalkableAt i, j
			# true

		setToGrid:->
			for i in [@ij.i...@ij.i+@sizeIJ.i]
				for j in [@ij.j...@ij.j+@sizeIJ.j]
					if App.grid.holdCell {i:i, j:j}, @
						@isValid = false
						@render()

		render:->
			@$el.css(
				'width':  @w or 0
				'height': @h or 0
				'top':    @top  or 0
				'left':   @left or 0)

			.toggleClass('is-invalid', !@isValid or (@w < App.gs ) or (@h < App.gs ))


		removeSelf:-> @removeSelfFromDom()

		removeSelfFromDom:-> @$el.remove()

	Block