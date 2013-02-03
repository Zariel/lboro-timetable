require! http
qs = require \querystring
require! htmlparser

dfs = (nodes, ids) ->
	for node in nodes
		if node?attribs?name of ids
			ids[node.attribs.name] = node.attribs.value

		if node.type is \tag and node.children
			dfs node.children, ids

getFlowIds = (cb) ->
	opts =
		hostname: \luis.lboro.ac.uk
		path: \/apx/f?p=250:2
		method: \GET
		headers:
			Host: \luis.lboro.ac.uk
			Origin: \http://luis.lboro.ac.uk

	handler = new htmlparser.DefaultHandler (err, dom) ->
		return console.err err if err
	
		ids = 
			p_flow_id: true
			p_flow_step_id: true
			p_instance: true
			p_page_submission_id: true

		for node in dom

			if node.name is \html and node.children
				for html in node.children

					if html.name is \body
						dfs html.children, ids

						return cb ids

	parser = new htmlparser.Parser handler

	req = http.request opts, (res) ->
		res.on \data, (chunk) ->
			parser.parseChunk chunk

		res.on \end, ->
			parser.done!

	req.end!

getTimeTable = (loc, cookies, cb) ->
	opts =
		hostname: \luis.lboro.ac.uk
		path: "/apx/#loc"
		method: \GET
		headers:
			Host: \luis.lboro.ac.uk
			Origin: \http://luis.lboro.ac.uk
			Referer: \http://luis.lboro.ac.uk/apx/f?p=250:2
			'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.56 Safari/537.17'
			Cookie: cookies

	req = http.request opts, (res) ->
		console.log res.statusCode

		len = res.headers[\x-db-content-length] |> parseInt

		data = new Buffer len
		offset = 0

		res.on \data, (chunk) ->
			chunk.copy data, offset
			offset += chunk.length

		res.on \end, ->
			console.log data.toString!

	req.end!

toCookie = (obj) ->
	qs.stringify obj, '; '

doLogin = (user, passw, cb) ->
	(ids) <- getFlowIds
	data = qs.stringify ids

	data += "&" + qs.stringify {
		p_request: \LOGIN
		p_arg_names: \126051438646446159
		p_t01: user
	}

	data += "&" + qs.stringify {
		p_arg_names: \126051548060446165
		p_t02: passw
		p_md5_checksum: ''
	}

	opts =
		hostname: \luis.lboro.ac.uk
		path: \/apx/wwv_flow.accept
		method: \POST
		headers:
			Host: \luis.lboro.ac.uk
			Origin: \http://luis.lboro.ac.uk
			Referer: \http://luis.lboro.ac.uk/apx/f?p=250:2
			'Content-Length': data.length
			'Content-Type': \application/x-www-form-urlencoded
			'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.56 Safari/537.17'
			Cookie: toCookie {
				LOGIN_USERNAME_COOKIE: user
				WWV_CUSTOM-F_996031460838586_250: -1
			}

	req = http.request opts, (res) ->
		if res.statusCode is 302
			cookies = {}
			for cookie in res.headers['set-cookie']
				[a, b] = (cookie.match /([^;]*);?.*/)[1].split \=
				cookies[a] = b

			return getTimeTable res.headers.location, toCookie cookies, cb

		console.err "UNABLE TO LOGIN"

	req.write data

	req.end!

module.exports = doLogin
