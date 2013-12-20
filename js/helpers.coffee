define 'helpers', ['two', 'md5'], (Two, md5)->

	helpers = 
		arrayRemove:(from, to) ->
			# Array Remove - By John Resig (MIT Licensed)
		  rest = @slice((to or from) + 1 or @length)
		  @length = (if from < 0 then @length + from else from)
		  @push.apply this, rest

		

		getEventCoords:(e)-> { x: e.gesture.center.pageX, y: e.gesture.center.pageY }
		
		timeIn:(name)->  console.time name
		
		timeOut:(name)-> console.timeEnd name
		
		genHash:-> md5 (new Date) + (new Date).getMilliseconds() + Math.random(9999999999999) + Math.random(9999999999999) + Math.random(9999999999999)

		stopEvent:(e)->
			e.preventDefault()
			e.stopPropagation()
			false
		
		makePoint:(x,y)->
			if arguments.length <= 1
				y = x.y
				x = x.x

			v = new Two.Vector x, y
			v.position = new Two.Vector().copy v
			v
	
	helpers

