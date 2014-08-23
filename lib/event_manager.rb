require "csv"
require "sunlight/congress"
require "erb"
Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"



def clean_zipcode(zipcode)
	zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone(phone)
	phone.to_s.gsub!(/[-(). ]/, "")
	if phone.length < 10 || phone == ""
		phone = "0000000000"
	elsif phone.length == 11
		phone = phone[1..-1]
	end
	phone
end


def legislators_by_zipcode(zipcode)
	legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end


def save_thank_you_letters(id, form_letter)
	Dir.mkdir("output") unless Dir.exists? "output"

	filename = "output/thanks_#{id}.html"

	File.open(filename,'w') do |file|
		file.puts form_letter
	end
end

puts "EventManagement Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter
regtime_array = []
regday_array = []
contents.each do |row|
	id = row[0]
	
	regtime = row[:regdate]
	
	regtime = 	DateTime.strptime(row[:regdate], '%m/%d/%y %H:%M').hour
	regtime_array << regtime

	regday = DateTime.strptime(row[:regdate], '%m/%d/%y %H:%M').wday
	regday_array << regday

	name = row[:first_name]

	phone = clean_phone(row[:homephone])

	zipcode = clean_zipcode(row[:zipcode])
	
	legislators = legislators_by_zipcode(zipcode)

	form_letter = erb_template.result(binding)

	save_thank_you_letters(id,form_letter)	
		

	puts "Name: #{name}, [clean] phone number: #{phone} "
	
end
puts ""
puts "#########################################" 
puts "The most active hour of the day is:"

if regtime_array.max > 12
	puts (regtime_array.max % 12).to_s + "pm"
else
	puts regtime_array.max + "am"
end


puts ""
puts "#########################################" 
puts "The most active day of the week is:"
if regday_array.max == 1
	puts "Monday"
elsif regday_array.max == 2
	puts "Tuesday"
elsif regday_array.max == 3
	puts "Wednesday"
elsif regday_array.max == 4
	puts "Thursday"
elsif regday_array.max == 5
	puts "Friday"
elsif regday_array.max == 6
	puts "Saturday"
elsif regday_array.max == 7
	puts "Sunday funday"
else
	puts "Something must be wrong with the way we're extracting week days..."
end
puts ""
		
		
		
		
		















