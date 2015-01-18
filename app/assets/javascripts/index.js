// 
// 
// If you can read this, we should be friends. Especially if you like Ruby
// 


$( document ).ready(function() {
	//load courses.
	window.courses = null;
	
	//no currently selected courses
	window.currentschedulearray = {}; //set as an obj not an array 
	
	//populate courses available
	populate_course_list();

	//This next line only works in Chrome which is bullshit because it's amazing and needs 
	//to work in Safari too. Safari sucks.
	// Object.observe(window.currentschedulearray, update_view);

	//searches 
	$('#search_bar').keyup(function (e) {
		course_search();
	});
	
	//handly any course plus button being clicked. ul must be static/extant when the page loads, whereas the li can be added dynamically later and this will still fire.
	$('body #classlisttarget').on('click', 'li img', function(e) {
		var id = $(this).attr('id');
		console.log('clicked an li its id is '+id);
		
		if (e.shiftKey) {
			// if shift is held down, it means user is trying to flag this listing as incorrect.
        	c = confirm("Mark this class as incorrect?");
        	if (c == true){
        		
        		//flag_incorrect(id);
        	} 
    	} else {
			addthisclass(id);
		}
	});
})

//renders html for a course. 
function render_course_listing(course) {
	var html = '';
	var html = html + '<li style="overflow:hidden;">';
	var html = html + '<img src="assets/plus.png" height=20 width=20 alt="alt data" id='+course.crn+'>';
	var html = html + '<span class="classname">'+course.gwid+'-'+course.section+' '+course.course_name+'</span><span class="profname">'+course.professor+'</span><span class="ratings"><a href="https://my.law.gwu.edu/Evaluations/page%20library/ByFaculty.aspx?Source=%2fEvaluations%2fdefault.aspx&IID=13802" target="_blank"><button class="GWU_btn"> GWU </button></a></span>';
	var html = html + '</li>';
	return html 
}

//fills classlisttarget with all of the courses.
function populate_course_list() {
	$.get('/api/courses.json', function(courses){
			if (courses !=="") {
				window.courses = courses;
				$('#classlisttarget').empty();

				$.each(courses, function(index, course) {
					html = render_course_listing(course);

					$('#classlisttarget').append(html);
				})
			} else {
				$('#classlisttarget').append("No Classes Loaded. Something has gone terribly wrong. Email grantmnelsn@gmail.com ASAP.");
			}
	})
}

//shows/hides courses available based on search input 
function search_courses(term) {
	$.each(window.courses, function(index, course) {
		match = ( ((course.course_name.indexOf(term)) > -1) || ((course.professor.indexOf(term)) > -1) );
		if (match) {
			//render
			html = render_course_listing(course);
			$('#classlisttarget').append(html);
		} 

	})
}

function addthisclass(crn) {
	var color = random_color();

	//get course info from json using the crn 
	var course = $.grep(window.courses, function(e){ return e.crn == crn; });
	var course = course[0];

	if ((course['day1_start'])) {
		var col = 'day1_column';
		start_time = course['day1_start'];
		end_time = course['day1_end']

		//render
		render_session(col, start_time, end_time, course, color);

	}

	if ((course['day2_start'])) {
		var col = 'day2_column';
		start_time = course['day2_start'];
		end_time = course['day2_end']

		//render
		render_session(col, start_time, end_time, course, color);
	}

	if ((course['day3_start'])) {
		var col = 'day3_column';
		start_time = course['day3_start'];
		end_time = course['day3_end']

		//render
		render_session(col, start_time, end_time, course, color);
	}

	if ((course['day4_start'])) {
		var col = 'day4_column';
		start_time = course['day4_start'];
		end_time = course['day4_end']

		//render
		render_session(col, start_time, end_time, course, color);
	}

	if ((course['day5_start'])) {
		var col = 'day5_column';
		start_time = course['day5_start'];
		end_time = course['day5_end']

		//render
		render_session(col, start_time, end_time, course, color);
	}

	if ((course['day6_start'])) {
		var col = 'day6_column';
		start_time = course['day6_start'];
		end_time = course['day6_end']

		//render
		render_session(col, start_time, end_time, course, color);
	}

	if ((course['day7_start'])) {
		var col = 'day7_column';
		start_time = course['day7_start'];
		end_time = course['day7_end']

		//render
		render_session(col, start_time, end_time, course, color);
	}

	//add it to the currently selected list of courses
	var crn = course['crn'];
	window.currentschedulearray[crn] = course;

	//update the view manually
	update_view();

}

function render_session(column, start_time, end_time, coursedata, color) {
	//column is the css id of the column - ie day2_column etc. 
	console.info(coursedata);

	//start time minus 8*60 = 0 percent 
	//480 minutes = 0% 
	var start_time = (convert_to_minutes(start_time) - 480);
	var start_percent = ((start_time/780)*100); //total height of Y axis is 780 minutes, so find how many minutes are before (above) it. multiple to make it XX% instaed of .XX

	//end time
	var end_time = (convert_to_minutes(end_time) - 480);
	var end_percent = ((end_time/780)*100);
	var height = (end_percent-start_percent);

	//etc
	var prof = coursedata['professor'];
	var name = coursedata['course_name'];
	var second_name = coursedata['second_name'];
	var additional_info = coursedata['additional_info'];
	var jsclass = coursedata['crn']; //how we remove all of the scheduled classes @ once.

	var html = '';
	var html = html+ '<div class="scheduled_course '+jsclass+'" style="top:'+start_percent+'%; height:'+height+'%; background:'+color+';">';
	var html = html+ '<span class="scheduled_course_name">'+name+'</span>,<span class="scheduled_course_prof">'+prof+'</span>';
	var html = html + '</div>';

	$('#'+column+'').append(html);


}

function random_color() {
	//random colors for variety 
	var colors = [
		'#D2DEE6', //whitish
		'#3396D1', //light blue
		'#006099', //medium blue 
		'#FF6433', //burnt orange 
		'#F03A00', //burnter orange 
		'#C32F00', //burnter-er orange
		'#FFC933', //yellowish
		'#C38F00', //goldenrod?
		'#F0B000', //more goldenrod bright
		'#33987F', //green from next_btn
		'#FFCE80', //orange of chosenclasses box
	]; 

	var l = colors.length;
	var color = Math.floor(Math.random()*l);
	var color = colors[color];
	return color 
}

function convert_to_minutes(rawtime) {
	console.log('rawtime received :'+rawtime);
	//have to convert rawtime to string to substr it. 
	if (rawtime) {
		var rawtime = rawtime.toString();

		if (rawtime.length < 4) {
			if (rawtime.length < 3) {
				rawtime = '0'+rawtime;
			}
			rawtime = '0'+rawtime;
		}

		var h = parseInt(rawtime.substr(0,2));
		var mm = parseInt(rawtime.substr(-2,2));

		//parseInt()?
		// console.log('rawtime is '+h+' '+mm);
		var m = h*60;
		var m = m+mm;

		//return how many minutes are in the 4-digit military time entered as rawtime
		return m;
	} 
}

function removecourse(classid) {
	delete window.currentschedulearray[classid];
	$('.'+classid).remove();
	update_view();
}

function update_view() {
	
	$('#chosenclasseslist').empty();

	if (typeof window.currentschedulearray != "undefined") {
		console.log('updating because window.currentschedulearray is '+window.currentschedulearray);
		//append hours counter first
		$('#chosenclasseslist').append('<li id="hours_total"></li>');

			//update hours counter
			window.hours = 0;
			window.variable_hours = false;
			$.each(window.currentschedulearray, function(index, course){
				if (course.hours !== 'variable') {
					window.hours = window.hours + parseInt(course.hours);
					set_hours(window.hours);
				} else {
					window.variable_hours = true;
				}
			});

			var html = '';
			function set_hours(hours) {
				if (hours > 0) {
					var html = hours+' hour';
					if (hours > 1) {
						var html = hours+' hours';
					}
				} else {
					var html = 'No Hours';
				}

				if (window.variable_hours == true) {
					var html = html+'++';
				}

				$('#hours_total').html(html);
			}

		$.each(window.currentschedulearray, function(index, course){
			var id = index;
			console.log('index: '+index);
			console.info(course);
			var html = '';
			var html = html+ '<li>';
			var html = html+ '<img src="assets/minusbutton.png" height=20 width=20 onclick=removecourse('+course.crn+')>';
			var html = html+ '<span class="classname">'+course.course_name+', </span>';
			var html = html+ '<span class="profname"> '+course.professor+'</span>';
			var html = html+ '<span class="chosen_hours"> , '+course.hours+' hours</span>';
			var html = html+ '</li>';
			$('#chosenclasseslist').append(html);
		});


		//append the 'next button to the classlist'
		
		var html = '';
		var html = html + '<li id="next_btn"><a onclick="next()">Next --> Get CRNs and Books</a></li>';
		$('#chosenclasseslist').append(html);
	} else {
		$('#chosenclasseslist').empty();
	}
}

function course_search() {
	var terms = $('#search_bar').val();
	if ((terms == null) || (terms == "") || (terms == undefined)) {
		//nothing in the box. 
		populate_course_list();
	} else {
		$('#classlisttarget').empty();
    	search_courses(terms);
    }
}

//this is rough and probably can be optimized
function check_schedule_conflicts() {
	addthisclass(40948); //civ pro II, Schaffner
	addthisclass(40265); //Contracts II, Selmi conflict on day 3
	var l = Object.keys(window.currentschedulearray).length;

	var comparisons = 0;
	var conflicts = '';

	//clone the current array
	var selected_courses = window.currentschedulearray;
		
		//roughly double as slow as it could be :/ 
		for (var key in selected_courses) {
		   	var first_course = selected_courses[key];
	  		for (var key2 in selected_courses) {
	  			var second_course = selected_courses[key2];
	  			if (first_course !== second_course) {
	  				compare_courses(first_course, second_course);
	  				comparisons++;
	  			}
	  		}
		}



	console.log('made '+comparisons+' comparisons.');
	console.log(conflicts);


}

function compare_courses(course1, course2) {
	//returns 'conflict' else 'true'
	// console.info(course1);
	// console.info(course2);

	//for each day that the first course meets, see if 
	//any of them begin a
	if (course1.day2_start && course2.day2_start) {
		
		//if course1 starts first or same time
		if (course1.day2_start <= course2.day2_start) {
			console.log(course1.course_name+' starts ('+course1.day2_start+') before or at the same time ('+course2.day2_start+') as '+course2.course_name);
			if (course2.day2_start <= course1.day2_end) {
				console.log(course2.course_name+' starts ('+course2.day2_start+') at or before '+course1.course_name+' ends ('+course1.day2_end+')');
				return 'conflict';
			}

		//if course2 starts first
		} else if (course2.day2_start <= course1.day2_start) {
			if (course1.day2_start <= course2.day2_end) {
				return 'conflict';
			}

		} else { 
			if (course1.day2_start == course2.day2_start) {
				return 'conflict'; 
			}
		}
	} 

}

function test() {
	//display_all_test();
	comparison_test();
}

function display_all_test() {
	var l = window.courses.length;
	for (i=0; i<l; i++) {
		addthisclass(window.courses[i]['crn']);
	}
}

function comparison_test() {
	//test for 
	$.each(courses, function(index, course) {
		if (course.professor == 'Terry') {
			
		}	
	})

	var l = courses.length;
	for (i=0; i<l; i++) {
		if (courses[i]['crn'] == '45788') console.log('Array Location: '+i);
	}

	//courses[171], courses[100] = Monday 850am start (Antitrust and Human Rights)
	var test_name = 'Test Check Same Start Time for Conflict';
	if ('conflict' == compare_courses(courses[171], courses[100])) {
		console.log(test_name+' : PASSED.');
	} else {
		console.log(test_name+ ' : FAILED!');
	}

	//test Mediation courses[199] and US Foreign Relations courses[286]
	var test_name = 'Test Class Times Overlap (course1 first)';
	if ('conflict' == compare_courses(courses[199], courses[286])) {
		console.log(test_name+' : PASSED.');
	} else {
		console.log(test_name+ ' : FAILED!');
	}

	var test_name = 'Test Class Times Overlap (course 2 first)';
	if ('conflict' == compare_courses(courses[286], courses[199])) {
		console.log(test_name+' : PASSED.');
	} else {
		console.log(test_name+ ' : FAILED!');
	}


	

}



