timetable = require \./lib/timetable
parser = require \./lib/ttparser
ical = require \./lib/ical

user = process.argv.2
pass = process.argv.3

(data) <- timetable user, pass
(tt) <- parser.parse data.toString \ascii
console.log tt
