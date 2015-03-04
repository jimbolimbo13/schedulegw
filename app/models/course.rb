class Course < ActiveRecord::Base
	has_many :schedules
	has_many :users, through: :schedules

	has_many :subscriptions
	has_many :users, through: :subscriptions



	



	










	#scrapers 
	def self.GWU_scrape
		#Compare the School's PDF with the one we have cached most recently. If they match, skip this step. If they don't match, run it. 
		#All of the PDFs are scraped at once here at the top. 
		#URLs are all brought together here for convenience.
		crn_text = Yomu.new 'http://www.law.gwu.edu/Students/Records/Spring2015/Documents/SP15%20CTF.pdf'
		exam_text = Yomu.new 'http://www.law.gwu.edu/Students/Records/Fall2014/Documents/SPRING%202015%20COURSE%20AND%20EXAM%20SCHEDULE.pdf'
		$school = "GWU"


		#begin CRN_classlist with checking if changes occurred. 
		new_text = crn_text.text
		cached_text = File.exist?("#{Rails.root}/lib/scrape_texts/crn_classlist_last") ? File.open("#{Rails.root}/lib/scrape_texts/crn_classlist_last").read : nil

		if new_text == cached_text && Course.first
			puts "CRN Classlist is the same: Skipping parse."
			puts "and there is a first Course: "
			puts Course.first
		else 
			puts "New Version of CRN Classlist, running scraper/parser."
			#timestamp and save the file formerly known as crn_classlist_last.
			timestamp = Time.now().to_i
			File.write("#{Rails.root}/lib/scrape_texts/crn_classlist#{timestamp}", cached_text)

			#save the new_text as crn_classlist_last
			File.write("#{Rails.root}/lib/scrape_texts/crn_classlist_last", new_text)

			sliced_text = new_text.scan(/\n.+/).map{ |s| s}

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
					$alt_schedule = nil
					$additional_info = nil
					$course_name_2 = nil
					$professor = nil
					

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
						# puts "\n\n\n"
						# puts "CRN: #{$1}"
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
					# puts "line: '#{line}'"

						#this case is the fragment is more class meeting times (very important.)
					if $frag =~ /\s+([MTWRF]+)\s+(\d{4})\s+.\s+(\d{4})(\D\D)\s+[A-Za-z\/-]+/
						
						$frag.scan(/\s+([MTWRF]+)\s+(\d{4})\s+.\s+(\d{4})(\D\D)\s+[A-Za-z\/-]+/) {
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
					end 

					#matches LL.Ms ONLY
					if $frag =~ /LL.Ms\s+ONLY/
						$llm_only = true
					end 

					#matches (J.D.s only)
					if $frag =~ /\(J.D.s only\)/
						$jd_only = true
					end

					#matches (class sub name) except (J.D.s only)
					if $frag =~ /(\(.+[^J.D.s only]\))/
						$course_name_2 = $1.rstrip.lstrip
					end 

					#matches alternat or modified schedule lines
					if $frag =~ /(alternat|modified)/
						$alt_schedule = true
					end  
					
					#just save it as additional info if it doesn't match a pattern
					$additional_info = $frag.strip

				end

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
					course.professor = $professor
					course.school = $school

				course.save! unless (course.manual_lock == true) 

				Course.delete_all(:crn => nil)
			}
		end #end of 'new text available to scrape'

		# Now finished the groundwork for the classes, time to add the finals information.

		#start with checking the foreign copy. exam_text is defined way above. 
		new_text = exam_text.text

		cached_text = File.exist?("#{Rails.root}/lib/scrape_texts/exam_schedule_last") ? File.open("#{Rails.root}/lib/scrape_texts/exam_schedule_last").read : nil

		if new_text == cached_text && Course.first
			puts "Exams PDF: Same as local copy, skipping parse."
		else
			puts "Exam schedule PDF has changed, parsing the new one now."
			#timestamp and save the file formerly known as exam_schedule_last.
			timestamp = Time.now().to_i
			File.write("#{Rails.root}/lib/scrape_texts/exam_schedule_#{timestamp}", cached_text)

			#save the new_text as crn_classlist_last
			File.write("#{Rails.root}/lib/scrape_texts/exam_schedule_last", new_text)

			# process:
			# 1. discard everything before the phrase "EXAMINATION SCHEDULE" in new_text
			# 2. 



		end #end of exam_schedule scrape

	##Notify scrape completed. 

 	AdminMailer.scrape_complete($school).deliver_now

	end #end of GWU_scrape



end
