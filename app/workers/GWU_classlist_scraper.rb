

	#grabs pdf to text quickly. 
	require 'yomu'
	require 'active_record'
	require 'pg'
	
	ActiveRecord::Base.establish_connection(
	  adapter:  'postgresql', # or 'postgresql' or 'sqlite3'
	  database: 'omniauth_development',
	  username: 'omniauth',
	  password: '',
	  host:     'localhost'
	)

	class Course < ActiveRecord::Base
	end

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

		$frag = nil

		if line =~ /\d{5}/i
			$crn = nil
			$gwid = nil
			$section = nil
			$course_name = nil
			$hours = nil
			$days = nil
			$start_time = nil
			$end_time = nil
			$prof_name = nil
			

			#reset all of the day start/end times 
			$day1_start = nil
			$day1_end = nil

			$day2_start = nil
			$day2_end = nil
			
			$day3_start = nil
			$day3_end = nil
			
			$day4_start = nil
			$day4_end = nil

			$day5_start = nil
			$day5_end = nil

			$day6_start = nil
			$day6_end = nil

			$day7_start = nil
			$day7_end = nil

			#has 5 digits, so it's the start of a line and class data

			#puts "line:'#{line}'"

			line.scan(/\s?+(\d{5})\s+(\d{4})\s+(\d{2})\s+([A-Za-z\/\-]+[^\d]+)(\d\.\d)\s+:?(OR|TO)?(:?(\s+\d\.\d\s+)?)(([MTWRF]+|TBA)(:?(\s[MTWRFBA]+)?))\s+(:?(TBA)?)(:?(\d{4})?)(:?(\s+-\s+(\d{4})(\D\D))?)\s+(\w+)\s?+/) { 
				|m| 
				#puts "#{m.inspect}"
				puts "\n\n\n"
				puts "CRN: #{$1}"
				$crn = $1.to_i

				$gwid = $2 ? $2.to_i : nil

				$section = $3 ? $3.to_i : nil

				$course_name = $4 ? $4.rstrip.to_s : nil

				$hours = $5 ? $5.slice(0,1).to_i : nil		

				$days = $9 #? $9.gsub(/\b\s\b/, '') : nil

				ampm = $20
				orig_start_time = $15
				orig_end_time = $19 

				case ampm 
				when 'pm' 
					$end_time = orig_end_time.to_i + 1200

					#if start time is before end time, and start time is under 1200, add 1200 to it
					if ((orig_start_time.to_i < orig_end_time.to_i) && (orig_start_time.to_i < 1200))
						$start_time = orig_start_time.to_i + 1200
					else
						$start_time = orig_start_time.to_i
					end
				else
					$start_time = orig_start_time.to_i
					$end_time = orig_end_time.to_i
				end 
				
				$professor = $21
				
			
			}

			#check for variable hours indicated by the phrase "1.0 or 2.0" or "1.0 to 3.0"
			if line =~ /\d\.\d\s(:?OR|TO)\s\d\.\d/
				$hours = 'variable'
			end

			#assign the time captured to each day captured so far. Alt times and days mentioned on the next line (frag) will be added below
			if (($days != 'TBA') && ($days != nil))
				$days.scan(/(\w)/) { |s|
					case $1
					when 'U'
						$day1_start = $start_time
						$day1_end = $end_time
					when 'M'
						$day2_start = $start_time
						$day2_end = $end_time
					when 'T'
						$day3_start = $start_time
						$day3_end = $end_time
					when 'W'
						$day4_start = $start_time
						$day4_end = $end_time
					when 'R'
						$day5_start = $start_time
						$day5_end = $end_time
					when 'F'
						$day6_start = $start_time
						$day6_end = $end_time
					when 'S'
						$day7_start = $start_time
						$day7_end = $end_time
					end
				}
			end


		else 
			#doesn't start with 5 digits, so it is either a fragment or an addition to the last line. If it's an addition to the last line we need to capture it.
			#puts "Fragment or continuation of previous line: '#{$crn}'"
			#puts line
			$frag = line
			puts "line: '#{line}'"

				#this case is the fragment is more class meeting times (very important.)
			case $frag 
			when $frag =~ /\s+([MTWRF]+)\s+(\d{4})\s+.\s+(\d{4})(\D\D)\s+[A-Za-z-\/]+/
				
				$frag.scan(/\s+([MTWRF]+)\s+(\d{4})\s+.\s+(\d{4})(\D\D)\s+[A-Za-z-\/]+/) {
					|s|
					$days = $1 
					
					#adjust for am/pm
					orig_start_time = $2
					orig_end_time = $3 
					ampm = $4
					case ampm 
					when 'pm' 
						$end_time = orig_end_time.to_i + 1200

						#if start time is before end time, and start time is under 1200, add 1200 to it
						if ((orig_start_time.to_i < orig_end_time.to_i) && (orig_start_time.to_i < 1200))
							$start_time = orig_start_time.to_i + 1200
						else
							$start_time = orig_start_time.to_i
						end
					else
						$start_time = orig_start_time.to_i
						$end_time = orig_end_time.to_i
					end 

					#add to the day. 
					if (($days != 'TBA') && ($days != nil))
					$days.scan(/(\w)/) { |s|
						case $1
						when 'U'
							$day1_start = $start_time
							$day1_end = $end_time
						when 'M'
							$day2_start = $start_time
							$day2_end = $end_time
						when 'T'
							$day3_start = $start_time
							$day3_end = $end_time
						when 'W'
							$day4_start = $start_time
							$day4_end = $end_time
						when 'R'
							$day5_start = $start_time
							$day5_end = $end_time
						when 'F'
							$day6_start = $start_time
							$day6_end = $end_time
						when 'S'
							$day7_start = $start_time
							$day7_end = $end_time
						end
					}
				end

				}
				
			#matches LL.Ms ONLY
			when $frag =~ /LL.Ms\s+ONLY/
				$llm_only = true

			#matches (J.D.s only)
			when $frag =~ /\(J.D.s only\)/
				$jd_only = true
			
			#matches (class sub name) except (J.D.s only)
			when $frag =~ /(\(.+[^J.D.s only]\))/
				$course_name_2 = $1.rstrip.lstrip

			#matches alternat or modified schedule lines
			when $frag =~ /(alternat*|modified)?/
				$alt_schedule = true
			else 
				#just save it as additional info if it doesn't match a pattern
				$additional_info = $frag
			end	

		end

		#commit to the database all globals here for this course
		
		puts "CRN: '#{$crn}'"
		puts "$gwid: #{$gwid}" 
		puts "$section: #{$section}"
		puts "$course_name: #{$course_name}"
		puts "$hours: #{$hours}"
		puts "days: #{$days}"

		puts "day1_start: #{$day1_start}"
		puts "day1_end: #{$day1_end}"

		puts "day2_start: #{$day2_start}"
		puts "day2_end: #{$day2_end}"

		puts "day3_start: #{$day3_start}"
		puts "day3_end: #{$day3_end}"

		puts "day4_start: #{$day4_start}"
		puts "day4_end: #{$day4_end}"

		puts "day5_start: #{$day5_start}"
		puts "day5_end: #{$day5_end}"

		puts "day6_start: #{$day6_start}"
		puts "day6_end: #{$day6_end}"

		puts "day7_start: #{$day7_start}"
		puts "day7_end: #{$day7_end}"

		puts "llm_only #{$llm_only}"
		puts "jd_only #{$jd_only}"

		puts "$course_name_2: #{$course_name_2}"
		puts "alt schedule: #{$alt_schedule}"

		puts "additional info: '#{$additional_info}'"

		course = Course.find_or_initialize_by(crn: $crn)
			course.crn = $crn
			course.course_name = $course_name
			course.course_name_2 = $course_name_2
			course.gwid = $gwid
			course.section = $section
			course.hours = $hours
			
			course.day1_start = $day1_start
			course.day1_end = $day1_end

			course.day2_start = $day2_start
			course.day2_end = $day2_end

			course.day3_start = $day3_start
			course.day3_end = $day3_end

			course.day4_start = $day4_start
			course.day4_end = $day4_end

			course.day5_start = $day5_start
			course.day5_end = $day5_end

			course.day6_start = $day6_start
			course.day6_end = $day6_end

			course.day7_start = $day7_start
			course.day7_end = $day7_end

			course.llm_only = $llm_only
			course.jd_only = $jd_only
			course.alt_schedule = $alt_schedule
			course.additional_info = $additional_info

		course.save!
	}










