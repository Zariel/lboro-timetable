/*
require! http
require! htmlparser

{ dfsClass
, dfsId
, dfsTag
, dfsText
, firstText
, findHtml
} = require \./util.ls
*/

module.exports =

	2: [
		new Date 2013 1 4 
		new Date 2013 1 11
		new Date 2013 1 18
		new Date 2013 1 25
		new Date 2013 2 4
		new Date 2013 2 11
		new Date 2013 3 15
		new Date 2013 3 22
		new Date 2013 3 29
		new Date 2013 4 6
		new Date 2013 4 13
		new Date 2013 4 20
	]

/*
getDatePage = (cb) ->
	opts =
		hostname: \lboro.ac.uk
		path: \/students/enquiries/termdates/
		method: \GET
		
	handler = new htmlparser.DefaultHandler (err, dom) ->
		cb dom
		
	parser = new htmlparser.Parser handler

	req = http.request opts, (res) ->
		res.on \data, (chunk) ->
			parser.parseChunk chunk
	
		res.on \end, ->
			parser.done!
	
	req.end!

pp = (o) -> JSON.stringify o, void, 2 |> console.log

parseDates = (node) ->

parseData = (nodes) ->

(dom) <- getDatePage
(html) <- findHtml dom
div = dfsId \main-content, html
for node in div.children
	if node.type is \tag and node?name is \p
		# expect a strong
		if node.children?0?name is \strong
			parseData node.children
*/
