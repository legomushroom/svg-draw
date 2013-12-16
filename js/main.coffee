require.config
	paths:
		jquery: 			'lib/jquery-2.0.1'
		underscore: 	'lib/lodash.underscore'
		hammer: 			'lib/hammer'
		tween: 				'lib/tween.min'
		two: 					'lib/two'
		'path-finder':'lib/pathfinding-browser'
		path: 				'modules/path'

	shim: { "two": { exports: "Two" } }

define 'main', ['helpers', 'hammer', 'jquery', 'two', 'path', 'grid', 'path-finder'], (helpers, hammer, $, Two, Path, Grid, PathFinder )->
	'use strict'
	class App
		constructor:->
			@initVars()
			@listenToTouches()    
			@listenToTools()    

		initVars:->

			@two = new Two(
				fullscreen: true
				autostart:  true
			).appendTo($('#js-main')[0])

			@$svgCanvas = $ @two.renderer.domElement
			@helpers = helpers
			@paths 		= []
			@objects 	= []
			
			@gs = 16

			@grid 		= new Grid

			@settings = 
				isSmartPath: true

			@debug = 
				isGrid: false

			@currTool = 'path'

		listenToTools:->
			it = @; 
			$('#js-tools').on 'click', '#js-tool', (e)-> 
				$this = $(@); it.currTool = $this.data().role
				$this.addClass('is-check').siblings().removeClass('is-check')


		listenToTouches:->
			@currPath = null
			hammer(@$svgCanvas[0]).on 'touch', (e)=>
				switch @currTool
					when 'path'
						@touchPath(e)

			hammer(@$svgCanvas[0]).on 'release', (e)=>
				switch @currTool
					when 'path'
						@releasePath(e)

			hammer(@$svgCanvas[0]).on 'drag', (e)=>
				switch @currTool
					when 'path'
						@dragPath(e)
				

		touchPath:(e)->
			coords = helpers.getEventCoords(e)
			if !@grid.isFreeCell coords
				@currPath = null
				return

			@currPath = new Path
						coords: @grid.getNearestCellCenter coords
			@paths.push @currPath

		releasePath:(e)-> @currPath?.removeIfEmpty()

		dragPath:(e)->
			coords = helpers.getEventCoords(e)
			if @grid.isFreeCell coords
				@currPath?.addPoint coords


		
	window.App = new App
