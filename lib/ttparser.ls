require! htmlparser

{ dfsClass
, dfsId
, dfsTag
, dfsText
, firstText
, findHtml
} = require \./util.ls

pp = (o) -> JSON.stringify o, void, 2 |> console.log

findTimetableTrs = (nodes) ->
	for node in nodes?children
		if node.type is \tag and node.name is \tr and node.children.length > 1
			if node.children.0.name is \th
				continue

			node

findContainer = !(nodes, cb) ->
	container = dfsId \main-content, nodes .children

	t1 = dfsClass \t1ReportsRegion100Width, container
	id = t1.attribs.id

	t2 = dfsId "report_#id", t1.children

	cb (dfsTag \table, t2.children)


parseTimeTableData = (div) ->
	if div is void
		return

	table = dfsTag \table, div.children
	if table is void
		return

	length = div.attribs.style.match /width:(\d)\d+%/ .1 |> parseInt

	module = dfsTag \td table.children.0.children .children |> firstText
	title = dfsTag \td table.children.1.children .children |> firstText

	row3 = table.children.2.children.0.children.0.data.match /Sem (\d): (.+)$/
	semester = row3.1 |> parseInt

	weeks = []
	for week in row3.2.split /\s*,\s*/
		split = week.match /(\d+)\s*-?\s*(\d*)/

		start = split.1 |> parseInt
		end = split.2 or start |> parseInt

		for i from start to end
			weeks.push i - 1

	professor = dfsTag \td table.children.3.children .children |> firstText
	building = dfsTag \td table.children.4.children .children |> firstText
	room = dfsTag \td table.children.6.children .children |> firstText

	row8 = dfsTag \td table.children.7.children .children
	type = if row8
			then firstText row8
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

getTimeTableData = !(nodes, cb) ->
	dayRows = findTimetableTrs nodes

	lectures = []

	for row in dayRows
		day = []

		time = 9
		for slot in row.children
			table = dfsTag \div slot.children |> parseTimeTableData

			if table
				table.time = time

				day.push table

			time++

		lectures.push day

	cb lectures

getYear = (html) ->
	title = dfsClass \t1RegionHeader, html

	line = (title.children |> dfsText).1
	[ _, year1, year2, semester ] = line.match /Timetable (\d+)\/(\d+) - Semester (\d+)/

	year = year1 + "-" + year2.substring(2, 4)

	{ year, semester }

parse = (data, cb) ->
	handler = new htmlparser.DefaultHandler (err, dom) ->
		return console.log err if err

		(html) <- findHtml dom
		{ year
		, semester
		} = getYear html

		(container) <- findContainer html
		(timetable) <- getTimeTableData container
		cb timetable, semester

	parser = new htmlparser.Parser handler

	parser.parseComplete data

module.exports.parse = parse
