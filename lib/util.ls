
dfsClass = module.exports.dfsClass = !(clazz, nodes) ->
	for node in nodes
		if node?attribs?class is clazz
			return node

		if node.children
			n2 = dfsClass clazz, node.children

			if n2 is not void
				return n2

dfsId = module.exports.dfsId = !(id, nodes) ->
	for node in nodes
		if node?attribs?id is id
			return node

		if node.children
			n2 = dfsId id, node.children

			if n2 is not void
				return n2

dfsTag = module.exports.dfsTag = !(tag, nodes) ->
	for node in nodes
		if node.name is tag
			return node

		if node.children
			n2 = dfsTag tag, node.children

			if n2 is not void
				return n2

dfsText = module.exports.dfsText = (nodes) ->
	list = []
	for node in nodes
		if node.type is \text
			list.push node.data

		if node.children
			n2 = dfsText node.children

			if n2 is not void
				list := list ++ n2
				
	return list

module.exports.firstText = head << dfsText

module.exports.findHtml = !(nodes, cb) ->
	html = dfsTag \html, nodes

	cb (dfsTag \body, html.children .children)
