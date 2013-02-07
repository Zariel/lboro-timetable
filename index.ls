timetable = require \./lib/timetable
parser = require \./lib/ttparser
ical = require \./lib/ical

user = process.argv.2
pass = process.argv.3

if user is void or pass is void
	return console.log "Must provide username and password"

(data) <- timetable user, pass
(tt, semester) <- parser.parse data.toString \ascii
ical.generate user, tt, semester
