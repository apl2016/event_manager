# Work with a CSV file.
# Data is arranged as:
#   ID - the empty column represents a unique identifier or row number of all the subsequent rows
#   RegDate - the date the user registered for the event
#   first_Name - their first name
#   last_Name - their last name
#   Email_Address - their email address
#   HomePhone - their home phone number
#   Street - their street address
#   City - their city
#   State - their state
#   Zipcode - their zipcode

require "csv"
# gem name is sunlight-congress, this gem can get various info on US congress members
require "sunlight/congress" 
require "erb" # for form

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

# basic zipcode validation
def clean_zipcode(zipcode)

	# if zipcode.nil?
	# 	# if no zipcode provided, default to 00000
	# 	"00000"
	# elsif zipcode.length < 5
	# 	# too short, pad with zeroes
	# 	zipcode.rjust(5, "0")
	# elsif zipcode.length > 5
	# 	# too long, only take first 5 digits
	# 	zipcode[0..4]
	# else
	# 	zipcode
	# end

	# this will accomplish all of the above
	#  Note that nil.to_s will return ""
	zipcode.to_s.rjust(5, "0")[0..4]
end

# retrieves list of legislators based on given zipcode
def legislators_by_zipcode(zipcode)
	Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

# create directory and files for personalized letters
def save_thank_you_letters(id,form_letter)
	Dir.mkdir("output") unless Dir.exists?("output")
	filename = "output/thanks_#{id}.html"

	File.open(filename, 'w') do |file|
		file.puts form_letter
	end
end

puts "EventManager Initialized!\n\n"

# contents is an array of lines from the file, each element is an array with 
#  elements containing data from each column (data between commas)
contents = CSV.open("event_attendees.csv", headers: true, header_converters: :symbol)

template_letter = File.read("form_letter.erb")
erb_template = ERB.new(template_letter)

contents.each do |row|
	# name = row[2]
	# the header_converters option above allows use of header name, as spec'd in source file (lowercase)
	name = row[:first_name]
	id = row[0]
	zipcode = clean_zipcode(row[:zipcode])
	
	legislators = legislators_by_zipcode(zipcode)

	form_letter = erb_template.result(binding)
	save_thank_you_letters(id, form_letter)
	
end
