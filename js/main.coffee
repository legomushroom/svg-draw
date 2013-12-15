require.config
	paths:
		jquery: 			'lib/jquery-2.0.1'
		underscore: 	'lib/lodash.underscore'
		hammer: 			'lib/hammer'
		tween: 				'lib/tween.min'
		two: 					'lib/two'

	shim: { "two": { exports: "Two" } }

define 'main', ['helpers', 'hammer', 'jquery', 'two'], (_, hammer, $, Two )->
	
	class Application
		constructor:->
			@initVars()
			@listenToTouches()    

		initVars:->
			@two = new Two(
				fullscreen: true
				autostart:  true
			).appendTo($('#js-main')[0])

			@$svgCanvas = $ @two.renderer.domElement


		listenToTouches:->
			@line = @two.makeLine(0,0,0,0)
			@line.noFill().stroke = "#00DFFC" 
			@line.noFill().linewidth = 2
			for v in @line.vertices
				v.addSelf @line.translation
			@line.translation.clear()

			hammer(@$svgCanvas[0]).on 'drag', (e)=>
				@line.vertices.push @makePoint( _.getNearestCellCenter { x: e.gesture.center.pageX, y: e.gesture.center.pageY })


		makePoint:(x, y)->
			if arguments.length <= 1
				y = x.y
				x = x.x

			v = new Two.Vector(x, y)
			v.position = new Two.Vector().copy(v)
			v


		
	new Application
