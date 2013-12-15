define 'path', ['two'], (Two)->
	class Path
		constructor:(@o={})->
			@line = App.two.makeLine(@o.coords.x, @o.coords.y, @o.coords.x, @o.coords.y)
			@line.noFill().stroke = @o.strokeColor or "#00DFFC" 
			@line.linewidth = @o.strokeWidth or 2

			for vert in @line.vertices
				vert.addSelf @line.translation
			@line.translation.clear()

	Path