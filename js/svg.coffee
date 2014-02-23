define 'svg', ['line', 'helpers'], (Line, helpers)->

	class SVG
		version: 1.1
		ns: 'http://www.w3.org/2000/svg'
		xlink: 'http://www.w3.org/1999/xlink'
		constructor:(@o={})->
			@grid = @o.grid or App.grid
			@createCanvas(@o.$el)
			@

		createCanvas:($el)->
			attrs = 
				version: 					@version
				xmlns: 						@ns
				'xmln:xlink': 		@xlink
				id: 							'svg-canvas'
				width: 						"#{@grid.w}em"
				height: 					"#{@grid.h}em"
			
			@canvas = @createElement 'svg', attrs
			$el[0].appendChild @canvas

		createElement: (name, attrs) ->
			tag = name
			elem = document.createElementNS(@ns, tag)
			@setAttributes elem, attrs  if attrs is Object(attrs)
			elem

		setAttribute:(k, v)-> 
			@setAttribute k, v

		removeAttribute:(k)-> @removeAttribute k

		setAttributes: (elem, attrs) ->
			for attrName, attrValue of attrs
				@setAttribute.call(elem, attrName, attrValue) if attrs.hasOwnProperty(attrName)
			@

		removeAttributes: (elem, attrs) ->
			for attrName, attrValue of attrs
				@removeAttribute.call(elem, attrName) if attrs.hasOwnProperty(attrName)
			@

		lineToDom:(elem)-> @canvas.appendChild(elem); @
		removeElem:(elem)-> @canvas.removeChild(elem); @

	SVG




























