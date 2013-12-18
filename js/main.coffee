require.config
	paths:
		jquery: 			'lib/jquery-2.0.1'
		underscore: 	'lib/lodash.underscore'
		hammer: 			'lib/hammer'
		tween: 				'lib/tween.min'
		two: 					'lib/two'
		md5: 					'lib/md5'
		'path-finder':'lib/pathfinding-browser'
		path: 				'modules/path'
		block: 				'modules/block'
		port: 	'modules/port'
		ProtoClass: 	'modules/ProtoClass'

	shim: { "two": { exports: "Two" } }

define 'main', ['helpers', 'hammer', 'jquery', 'two', 'path', 'block', 'grid', 'path-finder'], (helpers, hammer, $, Two, Path, Block, Grid, PathFinder )->
	'use strict'
	class App
		constructor:->
			@initVars()
			@listenToTouches()    
			@listenToTools()    

		initVars:->	
			@$main = $('#js-main')
			@$tools = $('#js-tools')

			@two = new Two(
				fullscreen: true
				autostart:  true
			).appendTo(@$main[0])

			@$svgCanvas = $ @two.renderer.domElement
			@helpers = helpers
			@gs = 16
			@grid 		= new Grid
			@paths 	= []
			@blocks = []

			@debug = 
				isGrid: true

			@currTool = 'path'
			@$tools.find("[data-role=\"#{@currTool}\"]").addClass 'is-check'

			@

		listenToTouches:->
			@currPath = null
			hammer(@$main[0]).on 'touch', (e)=>
				switch @currTool
					when 'path'
						@touchPath(e)
					when 'block'
						@touchBlock(e)

			hammer(@$main[0]).on 'drag', (e)=>
				switch @currTool
					when 'path'
						@dragPath(e)
					when 'block'
						@dragBlock(e)

			hammer(@$main[0]).on 'release', (e)=>
				switch @currTool
					when 'path'
						@releasePath(e)
					when 'block'
						@releaseBlock(e)

		releaseBlock:(e)-> @currBlock.addFinilize()

		touchBlock:(e)->
			coords = helpers.getEventCoords(e)
			if !@grid.isFreeCell coords then return
			@currBlock = new Block coords: coords

		dragBlock:(e)->
			coords = helpers.getEventCoords(e)
			if @grid.isFreeCell coords
				@currBlock?.dragResize  {x: e.gesture.deltaX, y:  e.gesture.deltaY}







		touchPath:(e)->
			coords = helpers.getEventCoords(e)
			if not @grid.isFreeCell coords
				@currPath = null
				return

			@addCurrentPath(coords)

		releasePath:(e)-> @currPath?.removeIfEmpty()

		dragPath:(e)->
			coords = helpers.getEventCoords(e)
			if @grid.isFreeCell coords
				if @isBlockToPath
					@currPath = @isBlockToPath; @isBlockToPath = false
				else @currPath?.set 'endIJ', @grid.toIJ coords



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




















