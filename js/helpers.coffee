define 'helpers', ['md5'], (md5)->

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

		getRandom:(min,max)->
			Math.floor((Math.random() * ((max + 1) - min)) + min)

		stopEvent:(e)->
			e.preventDefault()
			e.stopPropagation()
			false
	
	helpers

