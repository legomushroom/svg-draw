require.config
	paths:
		jquery: 			'lib/jquery-2.0.1'
		underscore: 	'lib/lodash.underscore'
		hammer: 			'lib/hammer'
		tween: 				'lib/tween.min'
		md5: 					'lib/md5'
		'path-finder':'lib/pathfinding-browser'
		path: 				'modules/path'
		block: 				'modules/block'
		port: 				'modules/port'
		event: 				'modules/event'
		'ports-collection': 				'modules/ports-collection'
		line: 				'modules/line'
		ProtoClass: 	'modules/ProtoClass'
		ProtoCollection: 	'modules/ProtoCollection'
		backbone: 		'lib/backbone'

	shim: 
		"two": { exports: "Two" }

		backbone:
			exports: 'Backbone'
			deps: 	['jquery','underscore']


define 'main', ['helpers', 'hammer', 'jquery', 'svg', 'path', 'block', 'grid', 'path-finder'], (helpers, hammer, $, SVG, Path, Block, Grid, PathFinder )->
	class App
		constructor:->
			@initVars()
			@listenToTouches()    
			@listenToTools()    

		initVars:->	
			@$main = $('#js-main')
			@$tools = $('#js-tools')

			@helpers = helpers
			@gs = 16
			@grid 	= new Grid
			@paths 	= []
			@blocks = []

			@SVG = new SVG 
				$el: @$main
				grid: @grid


			@debug = 
				isGrid: false
				time: 	false

			@currTool = ['path', 'block', 'event'][0]
			@$tools.find("[data-role=\"#{@currTool}\"]").addClass 'is-check'

			@

		listenToTouches:->
			@currPath = null
			hammer(@$main[0]).on 'touch', (e)=>
				switch @currTool
					when 'path', 'event'
						@touchPath(e)
					when 'block'
						@touchBlock(e)

			hammer(@$main[0]).on 'drag', (e)=>
				switch @currTool
					when 'path', 'event'
						@dragPath(e)
					when 'block'
						@dragBlock(e)

			hammer(@$main[0]).on 'release', (e)=>
				switch @currTool
					when 'path', 'event'
						@releasePath(e)
					when 'block'
						@releaseBlock(e)

		releaseBlock:(e)-> @currBlock.addFinilize(); @blockDrag = false

		touchBlock:(e)->
			coords = helpers.getEventCoords(e)
			if !@grid.isFreeCell coords then return
			@currBlock = new Block coords: coords

		dragBlock:(e)->
			@blockDrag = true
			coords = helpers.getEventCoords(e)
			@currBlock?.setSizeDelta @grid.normalizeCoords {x: e.gesture.deltaX, y: e.gesture.deltaY}


		touchPath:(e)->
			coords = helpers.getEventCoords(e)
			pathEndCell = @grid.isPathEndCell(coords)

			if pathEndCell then @currPath = pathEndCell; return
			if not @grid.isFreeCell coords
				@currPath = null; return
			else @addCurrentPath(coords)

		releasePath:(e)-> 
			if @currBlock
				@currBlock.release e

		dragPath:(e)->
			coords = helpers.getEventCoords(e)
			if @grid.isFreeCell coords
				if @isBlockToPath
					@currPath = @isBlockToPath; @isBlockToPath = false
				else 
					point = @currPath.currentAddPoint or 'endIJ'
					@currPath?.set point, @grid.toIJ coords

		listenToTools:->
			it = @; 
			$('#js-tools').on 'click', '#js-tool', (e)-> 
				$this = $(@); it.currTool = $this.data().role
				$this.addClass('is-check').siblings().removeClass('is-check')

		addCurrentPath:(coords)->
			@currPath = new Path
					coords: @grid.getNearestCellCenter coords
			@paths.push @currPath


		
	window.App = new App




















