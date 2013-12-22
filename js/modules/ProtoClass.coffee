define 'ProtoClass', ['backbone'], (BB)->
	class ProtoClass extends BB.Model
		# set:(key,value)->
		# 	if key? and typeof key is 'object'
		# 		for key1, value of key
		# 			@setAttr(key1, value)
		# 	else @setAttr key, value
		# 	@onChange?()

		# setAttr:(key,value)->
		# 	@[key] = value

	ProtoClass