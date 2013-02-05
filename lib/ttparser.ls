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

parseTimeTableData = (div) ->
	if div is void
		return

	table = dfsTag \table, div.children
	if table is void
		return

	length = div.attribs.style.match /width:(\d)\d+%/ .1 |> parseInt

	module = table.children.0.children.0.children.0.data
	title = table.children.1.children.0.children.0.data

	row3 = table.children.2.children.0.children.0.data.match /Sem (\d): (.+)$/
	semester = row3.1 |> parseInt

	weeks = []
	for week in row3.2.split /\s*,\s*/
		split = week.match /(\d+)\s*-?\s*(\d*)/

		start = split.1 |> parseInt
		end = split.2 or start |> parseInt

		for i from start to end
			weeks.push i

	console.log weeks

	{ module
	, title
	, length
	, semester
	}

getTimeTableData = (nodes) ->
	days = <[Monday Tuesday Wednesday Thursday Friday ]>
	times = [ 9 to 17 ]

	dayRows = findTimetableTrs nodes

	i = 0
	for row in dayRows
		day = days[i++]

		j = 0
		for slot in row.children
			time = times[j++]
			table = dfsTag \div slot.children |> parseTimeTableData

			console.log "#day -> #time = " + JSON.stringify table

findHtml = (nodes) ->
	html = dfsTag \html, nodes
	dfsTag \body, html.children .children

parse = (data) ->
	handler = new htmlparser.DefaultHandler (err, dom) ->
		return console.err err if err

		findHtml dom |> findContainer |> getTimeTableData

	parser = new htmlparser.Parser handler

	parser.parseComplete data

(err, data) <- fs.readFile 'test.html', 'ascii'
parse data

module.exports.parse = parse
