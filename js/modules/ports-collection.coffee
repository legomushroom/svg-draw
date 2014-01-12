define 'ports-collection', ['ProtoCollection', 'port'], (ProtoCollection, port)->
	class PortsCollection extends ProtoCollection
		model: port
		
	PortsCollection
