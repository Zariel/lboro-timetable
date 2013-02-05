require! htmlparser

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

dfsText = !(nodes) ->
	for node in nodes
		if node.type is \text
			return node.data

		if node.children
			n2 = dfsText node.children

			if n2 is not void
				return n2

pp = (o) -> JSON.stringify o, void, 2 |> console.log

findTimetableTrs = (nodes) ->
	for node in nodes?children
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

	module = dfsTag \td table.children.0.children .children |> dfsText
	title = dfsTag \td table.children.1.children .children |> dfsText

	row3 = table.children.2.children.0.children.0.data.match /Sem (\d): (.+)$/
	semester = row3.1 |> parseInt

	weeks = []
	for week in row3.2.split /\s*,\s*/
		split = week.match /(\d+)\s*-?\s*(\d*)/

		start = split.1 |> parseInt
		end = split.2 or start |> parseInt

		for i from start to end
			weeks.push i

	professor = dfsTag \td table.children.3.children .children |> dfsText
	building = dfsTag \td table.children.4.children .children |> dfsText
	room = dfsTag \td table.children.6.children .children |> dfsText

	row8 = dfsTag \td table.children.7.children .children
	type = if row8
		then dfsText row8
		else 'Lecture'

	{ module
	, title
	, length
	, semester
	, weeks
	, professor
	, building
	, room
	, type
	}

getTimeTableData = (nodes) ->
	days = <[Monday Tuesday Wednesday Thursday Friday ]>
	dayRows = findTimetableTrs nodes

	lectures = {}

	i = 0
	for row in dayRows
		day = days[i++]

		lectures[day] = {}

		time = 9
		for slot in row.children
			table = dfsTag \div slot.children |> parseTimeTableData

			if table
				table.time = time

				lectures[day][time] = table

			time++

	lectures

findHtml = (nodes) ->
	html = dfsTag \html, nodes
	dfsTag \body, html.children .children

parse = (data, cb) ->
	handler = new htmlparser.DefaultHandler (err, dom) ->
		return console.err err if err

		timetable = findHtml dom |> findContainer |> getTimeTableData

		cb timetable

	parser = new htmlparser.Parser handler

	parser.parseComplete data


/*
(err, data) <- require \fs .readFile 'test.html', 'ascii'
(tt) <- parse data
console.log tt
*/

module.exports.parse = parse
