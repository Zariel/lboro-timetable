require! icalendar
dates = require \./dates

dateUtil = require \date-utils

getUID = (user) ->
	date = Date.now!
	pid = process.pid 

	"#user@lboro.ac.uk$#date#pid"

generateEvent = (cal, lecture, date, uid) ->
	event = new icalendar.VEvent cal, uid
		
	sum = lecture.title + "\n"
	sum += lecture.professor + "\n"
	sum	+= lecture.building + "\n"
	sum	+= lecture.room + "\n"
	sum += lecture.type

	event.setSummary lecture.title + " - " + lecture.type
	event.setDate date, 3600 * lecture.length
	event.setDescription sum
	event.addProperty \LOCATION, lecture.room
	
	event

generate = (user, timetable, semester) ->
	uid = getUID user
	
	cal = new icalendar.iCalendar!
		
	i = 0
		
	for day, j in timetable
		for lecture in day
			for week in lecture.weeks
				dt = new Date(dates[semester][week])
				dt.setHours lecture.time
				dt.addDays j

				event = generateEvent cal, lecture, dt, uid + (i++)

				cal.addComponent event
	
	console.log cal.toString!

module.exports.generate = generate
