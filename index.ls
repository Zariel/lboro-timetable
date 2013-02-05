timetable = require \./lib/timetable
parser = require \./lib/ttparser
ical = require \./lib/ical

user = process.argv.2
pass = process.argv.3

(page) <- timetable user, pass
(tt) <- parser.parse data.toString \ascii
(ical) <- ical.generate tt
console.log ical
