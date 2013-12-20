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

		getRandom:(min,max)->
			Math.floor((Math.random() * ((max + 1) - min)) + min)

		stopEvent:(e)->
			e.preventDefault()
			e.stopPropagation()
			false
		
		makePoint:(x,y)->
			h = @getRandom(0,10)
			if arguments.length <= 1
				y = x.y
				x = x.x

			if h is 5 
				v = new Two.Anchor x, y, x*2, y*2, x*1.5, y*1.5,  Two.Commands.curve
			else
				v = new Two.Anchor x, y
			# v.position = new Two.Anchor().copy v
			v
	
	helpers

