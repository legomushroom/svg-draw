App.unit = 8
App.gs = 4*App.unit
App.gXCnt = 40
App.gYCnt = 50
App.gWidth = App.gs * App.gXCnt
App.dev = 
	grid: true
	time: true




class Main
	tool: 'path'
	constructor:->
		$('body').css 'min-width': App.gWidth
		$('body').css 'max-width': App.gWidth
		$('body').css 'width': App.gWidth
		@getVars()
		App.helpers.grid.make()
		@blocksInit()

	getVars:->
		@$main  = $('#js-main-l')
		@$mainH = $('#js-main-l').hammer()


	blocksInit:->
		@$main.on 'mousedown', (e)=>
			return if e.button isnt 0 or @tool isnt 'block' or $(e.target).hasClass 'block-e'
			coords = App.helpers.getNearestCell x: e.pageX, y: e.pageY
			@$main.append @$currentPlacePreview = $('<div>').addClass('place-preview-e').css 
																															'top': coords.y
																															'left': coords.x

		@$main.on 'mouseup', (e)=>
			if @$currentPlacePreview and (@$currentPlacePreview.width() isnt 0) and (@$currentPlacePreview.height() isnt 0)
				$el = @$currentPlacePreview.clone().removeClass('place-preview-e').addClass('block-e').data('id', App.helpers.genHash())
				@$main.append $el
				App.helpers.grid.posit $el
				

			@$currentPlacePreview?.remove()
			@$currentPlacePreview = null



		@$mainH.on 'drag', (e)=>
			return if not @$currentPlacePreview
			coords = App.helpers.getNearestCell x: e.gesture.deltaY, y: e.gesture.deltaX
			@$currentPlacePreview.css
				'height': coords.x
				'width': coords.y


		@$main.on 'mousedown', '.block-e', (e)=> 
			@$currentBlock = $(e.target)
			@currentBlockPosition = @$currentBlock.position()

		@$main.on 'mouseup', '.block-e', (e)=>
			App.helpers.grid.reposit @$currentBlock
			@$currentBlock = null
			@currentBlockPosition = null
		
		@$mainH.on 'drag', '.block-e', (e)=>
			e.stopPropagation()
			$el = $(e.target)
			coords = App.helpers.getNearestCell x: e.gesture.deltaX, y: e.gesture.deltaY
			y = @currentBlockPosition.top + coords.y
			x = @currentBlockPosition.left + coords.x
			if y < 0 then y = 0
			if x < 0 then x = 0

			$el.css
				'top': 	y
				'left': x
			

App.main = new Main


App.gui = new dat.GUI()
App.gui.add App.main, 'tool', ['path', 'block']