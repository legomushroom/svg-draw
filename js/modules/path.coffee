define 'path', ['two', 'jquery'], (Two, $)->
	class Path
		constructor:(@o={})->
			@line = App.two.makeLine(@o.coords.x, @o.coords.y, @o.coords.x, @o.coords.y)
			@line.noFill().stroke = @o.strokeColor or "#00DFFC" 
			@line.linewidth = @o.strokeWidth or 2

			for vert in @line.vertices
				vert.addSelf @line.translation
			@line.translation.clear()
			setTimeout (=> @$dom = $("#two-#{@line.id}"); @addMarkers()), 25

		removeIfEmpty:->
			@line.vertices.length is 2 and @line.remove()

		addPoint:(coords)->
			# console.log @line.vertices[@line.vertices.length-1].x, @line.vertices[@line.vertices.length-1].y
			@line.vertices.push coords
			@addMarkers()

		addMarkers:->
			@$dom.attr 'marker-mid', "url('#marker-mid')"

		simplify:(n=2)->
			# @line.vertices.remove 2, 5




	Path