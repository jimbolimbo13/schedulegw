
#grabs pdf to text quickly. 
# require 'yomu'

# yomu = Yomu.new 'http://www.law.gwu.edu/Students/Records/Spring2015/Documents/SP15%20CTF.pdf'
# #yomu = Yomu.new '/workers/courselist_with_crns.pdf'
# orig_text = yomu.text

# #timestamp and save locally to make future comparisons easier
# timestamp = Time.now().to_i
# File.write("crn_classlist_#{timestamp}", orig_text)

orig_text = File.open("crn_classlist_1420222526").read

sliced_text = orig_text.scan(/\n.+/).map{ |s| s}

#nasty regex to capture each line
#https://regex101.com/r/aG2xP2/3
#this regex is great; just need to edit capturing groups
# :?\s+(\d{5})\s+(\d{4})\s+(\d{2})\s+([A-Za-z\/\-]+[^\d]+)(\d\.\d)\s+:?(OR)?:?(TO)?(:?(\s+\d\.\d\s+)?)[MTWRFBA]+(:?(\s[MTWRFBA]+)?)\s+(:?(TBA)?)(:?(\d{4})?)(:?(\s+-\s+(\d{4})(\D\D))?)\s+(\w+)\s+?

sliced_text.each { |line|

	if line =~ /\d{5}/i
		$crn = nil
		$frag = nil
		#has 5 digits, so it's the start of a line and class data

		#puts "line:'#{line}'"

		line.scan(/\s?+(\d{5})\s+(\d{4})\s+(\d{2})\s+([A-Za-z\/\-]+[^\d]+)(\d\.\d)\s+:?(OR|TO)?(:?(\s+\d\.\d\s+)?)(([MTWRF]+|TBA)(:?(\s[MTWRFBA]+)?))\s+(:?(TBA)?)(:?(\d{4})?)(:?(\s+-\s+(\d{4})(\D\D))?)\s+(\w+)\s?+/) { 
			|m| 
			puts "#{m.inspect}"
			puts "CRN: #{$1}"
			$crn = $1.to_i
			puts "gwid: #{$2}"
			puts "section: #{$3}"

			class_name = $4 ? $4.rstrip : nil
			puts "class name:#{class_name}"
	
			hours = $5 ? $5.slice(0,1).to_i	: nil		
			puts "hours: #{hours}"

			days = $9 ? $9.gsub(/\s+/,'') : nil
			puts "days: #{days}"
			
			puts "start_time: #{$15}"
			puts "?: #{$16}"
			puts "?: #{$17}"
			puts ": #{$18}"
			puts "end time: #{$19}"
			puts "am/pm: #{$20}"
			puts "professor: #{$21}"
		
		}

		


		#check for variable hours indicated by the phrase "1.0 or 2.0" or "1.0 to 3.0"
		if line =~ /\d\.\d\s(:?OR|TO)\s\d\.\d/
			$class_hours = 'variable'
			$class_hours_set = true
		end


	else 
		#doesn't start with 5 digits, so it is either a fragment or an addition to the last line. If it's an addition to the last line we need to capture it.
		#puts "Fragment or continuation of previous line: '#{$crn}'"
		#puts line
		$frag = line

	end

	#commit to the database all globals here for this class
	puts "CRN: '#{$crn}'"
	# puts "gwid: '#{$gwid}'"
	# puts "section:'#{$section}"
	# # puts "class_name: '#{$classname}'"
	# puts "class_hours: '#{$class_hours}'"
	# # puts "start_time: '#{$start_time}'"
	# # puts "end_time: '#{$end_time}'"
	# # puts "Prof 0: '#{$prof_name.inspect}'"
	puts "Fragment: '#{$frag}'"

	#unset all globals except crn here
	$gwid = nil
	$section = nil
	$class_name = nil
	$class_hours = nil
	$start_time = nil
	$end_time = nil
	$prof_name = nil


	$section_set = nil
	$class_name_set = nil
	$class_hours_set = nil
	$start_time_set = nil
	$end_time_set = nil
	$prof_name_set = nil
}











