define 'ports-collection', ['ProtoCollection', 'port'], (ProtoCollection, port)->
	class PortsCollection extends ProtoCollection
		model: port

		containPath:(id)->
			isPath = false
			@each (port)->
				for connection in port.get 'connections'
					console.log connection
					if connection.path.get('id') is id then isPath = true

			isPath

	PortsCollection
