require.config
	paths:
		jquery: 			'lib/jquery-2.0.1'
		underscore: 	'lib/lodash.underscore'
		hammer: 			'lib/hammer'
		tween: 				'lib/tween.min'
		two: 					'lib/two'
		path: 				'modules/path'

	shim: { "two": { exports: "Two" } }

define 'main', ['helpers', 'hammer', 'jquery', 'two', 'path'], (helpers, hammer, $, Two, Path )->
	'use strict'
	class App
		constructor:->
			@initVars()
			@listenToTouches()    

		initVars:->
			@two = new Two(
				fullscreen: true
				autostart:  true
			).appendTo($('#js-main')[0])

			@$svgCanvas = $ @two.renderer.domElement
			@helpers = helpers
			@paths 		= []
			@objects 	= []



		listenToTouches:->
			@currDrawLine = null
			hammer(@$svgCanvas[0]).on 'touch', (e)=>
				@currDrawLine = new Path
							coords: @helpers.getNearestCellCenter { x: e.gesture.center.pageX, y: e.gesture.center.pageY }
				@paths.push @currDrawLine

			hammer(@$svgCanvas[0]).on 'release', (e)=>
				@currDrawLine.line.vertices.length is 2 and @currDrawLine.line.remove()

			# hammer(@$svgCanvas[0]).on 'drag', (e)=>
			# 	@currDrawLine.vertices.push @helpers.to2Coordinates e

		
	window.App = new App
