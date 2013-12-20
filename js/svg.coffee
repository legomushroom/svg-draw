define 'svg', ['line', 'helpers'], (Line, helpers)->

	class SVG
		version: 1.1
		ns: 'http://www.w3.org/2000/svg'
		xlink: 'http://www.w3.org/1999/xlink'
		constructor:(@o={})->
			@createCanvas(@o.$el)
			@

		createCanvas:($el)->
			attrs = 
				version: 					@version
				xmlns: 						@ns
				'xmln:xlink': 		@xlink
				id: 							'svg-canvas'
				style: 						'left:0;top:0;right:0;bottom:0;position:absolute;'
				width: 						'1440'
				height: 					'900'
			
			@canvas = @createElement 'svg', attrs
			$el[0].appendChild @canvas

		createElement: (name, attrs) ->
			tag = name
			elem = document.createElementNS(@ns, tag)
			@setAttributes elem, attrs  if attrs is Object(attrs)
			elem

		setAttribute: (k, v) -> @setAttribute k, v

		removeAttribute: (k) -> @removeAttribute k

		setAttributes: (elem, attrs) ->
			for attrName, attrValue of attrs
				@setAttribute.call(elem, attrName, attrValue) if attrs.hasOwnProperty(attrName)
			@

		removeAttributes: (elem, attrs) ->
			for attrName, attrValue of attrs
				@removeAttribute.call(elem, attrName) if attrs.hasOwnProperty(attrName)
			@

		lineToDom:(id, elem)->
			@canvas.appendChild elem
			@

	SVG




























