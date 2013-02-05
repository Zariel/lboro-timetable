require! htmlparser
require! fs
global <<< require \prelude-ls

dfsClass = !(clazz, nodes) ->
	for node in nodes
		if node?attribs?class is clazz
			return node

		if node.children
			n2 = dfsClass clazz, node.children

			if n2 is not void
				return n2

dfsId = !(id, nodes) ->
	for node in nodes
		if node?attribs?id is id
			return node

		if node.children
			n2 = dfsId id, node.children

			if n2 is not void
				return n2

dfsTag = !(tag, nodes) ->
	for node in nodes
		if node.name is tag
			return node

		if node.children
			n2 = dfsTag tag, node.children

			if n2 is not void
				return n2

pp = (o) -> JSON.stringify o, void, 2 |> console.log

findTimetableTrs = (nodes) ->
	for node in nodes.children
		if node.type is \tag and node.name is \tr and node.children.length > 1
			if node.children.0.name is \th
				continue
			
			node

findContainer = (nodes) ->
	container = dfsId \main-content, nodes .children

	t1 = dfsClass \t1ReportsRegion100Width, container
	id = t1.attribs.id

	t2 = dfsId "report_#id", t1.children

	dfsTag \table, t2.children

parseTimeTableData = (table) ->
	if table is void
		return

	table

getTimeTableData = (nodes) ->
	days = <[Monday Tuesday Wednesday Thursday Friday ]>
	times = [ 9 to 17 ]

	i = 0

	dayRows = findTimetableTrs nodes

	for row in dayRows
		day = days[i++]

		j = 0
		for slot in row.children
			time = times[j++]
			table = dfsTag \table slot.children |> parseTimeTableData
			console.log "#day (#time) -> #table" if table

findHtml = (nodes) ->
	html = dfsTag \html, nodes
	dfsTag \body, html.children .children

parse = (data) ->
	handler = new htmlparser.DefaultHandler (err, dom) ->
		return console.err err if err

		findHtml dom |> findContainer |> getTimeTableData
	,
		versbose: true
		ignoreWhiteSpace: false

	parser = new htmlparser.Parser handler

	parser.parseComplete data

(err, data) <- fs.readFile 'test.html', 'ascii'
parse data

module.exports.parse = parse
