// 
// 
// If you can read this, we should be friends. Especially if you like Ruby
// 


$( document ).on('page:load', function() {
	//load courses.
	window.courses = null;
	
	//no currently selected courses
	window.currentschedulearray = {}; //set as an obj not an array 
	
	//populate courses available
	load_courses();

	//This next line only works in Chrome which is bullshit because it's amazing and needs 
	//to work in Safari too. Safari sucks.
	// Object.observe(window.currentschedulearray, update_view);

	//searches 
	$('#search_bar').keyup(function (e) {
		course_search();
	});
	
	//handly any course plus button being clicked. ul must be static/extant when the page loads, whereas the li can be added dynamically later and this will still fire.
	$('body #classlisttarget').on('click', 'li .fa-plus-square', function(e) {
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
	var html = html + '<li style="overflow:hidden;" class="available_course" id="list_'+course.crn+'">';
	var html = html + '<span class="fa fa-plus-square fa-2x" style="color:green;" alt="'+course.additional_info+'" id='+course.crn+'></span>';
	var html = html + '<span class="classname">'+course.gwid+'-'+course.section+' '+course.course_name+'</span><span class="profname">'+course.professor+'</span><span class="ratings"><a href="https://my.law.gwu.edu/Evaluations/page%20library/ByFaculty.aspx?Source=%2fEvaluations%2fdefault.aspx&IID=13802" target="_blank"><button class="GWU_btn"> GWU </button></a></span>';
	var html = html + '</li>';
	return html 
}


function load_courses() {
	$.get('/api/courses/courses.json', function(courses){
		window.courses = courses
		populate_course_list();	
	})
}


//fills classlisttarget with all of the courses.
function populate_course_list() {
	$('#classlisttarget').empty();
	$.each(window.courses, function(index, course) {
		html = render_course_listing(course);
		$('#classlisttarget').append(html);
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
	// console.info(coursedata);

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
	// console.log('rawtime received :'+rawtime);
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
		// console.log('updating because window.currentschedulearray is '+window.currentschedulearray);
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

		window.courses_exist = false;
		$.each(window.currentschedulearray, function(index, course){
			var id = index;
			// console.log('index: '+index);
			// console.info(course);
			var html = '';
			var html = html+ '<li>';
			var html = html+ '<span class="fa fa-remove fa-2x" style="color:red;" onclick=removecourse('+course.crn+')></span>';
			var html = html+ '<span class="classname">'+course.course_name+', </span>';
			var html = html+ '<span class="profname"> '+course.professor+'</span>';
			var html = html+ '<span class="chosen_hours"> , '+course.hours+' hours</span>';
			var html = html+ '</li>';
			$('#chosenclasseslist').append(html);
			window.courses_exist = true;
		});


		//append the 'next button to the classlist'
		if (window.courses_exist) {
			var html = '';
			var html = html + '<li id="next_btn" class="btn btn-lg btn-primary" onclick="next()">Next</li>';
			$('#chosenclasseslist').append(html);
		}
		
		
		//update striped classes etc. 
		check_schedule_conflicts();

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
	var selected_courses = window.currentschedulearray;
	selected = []
	for (var key in selected_courses) {
		selected.push(selected_courses[key]);
	}

	conflicted_courses = [];
	unconflicted_courses = [];

	//this makes the minimum number of comparisons :) :) :) 
	for (i=0; i<selected.length; i++) {
		console.log('length: '+selected.length);
		if (selected.length < 1) {
			unconflicted_courses.push(course1);
			continue;
		}
		var course1 = selected.shift();
		for (a=0; a<selected.length; a++) {
			var course2 = selected[a];
			if ('conflict' == compare_courses(course1, course2)) {
				conflicted_courses.push(course1);
				conflicted_courses.push(course2);
			} else {
				unconflicted_courses.push(course1);
			}
		}	
	}

	//make the overlapping courses white/red slashed in color 
	$.each(conflicted_courses, function (index, conflicted_course) {
		mark_overlapped_on_schedule(conflicted_course);
	})

	$.each(unconflicted_courses, function (index, unconflicted_course) {
		mark_non_overlapped_on_schedule(unconflicted_course);
	})

	//gray out the courses on the list that are incompatible with the classes currently chosen. 
	unavailable_courses = [];
	$.each(window.courses, function(index1, course1) {
		$.each(window.currentschedulearray, function(index2, course2) {
			if ("conflict" == compare_courses(course1, course2)) {
				unavailable_courses.push(course1.crn);
			} else {
				mark_available_in_list(course1.crn);
			}
		})
	})

	$.each(unavailable_courses, function(index, crn) {
		mark_unavailable_in_list(crn);
	})

	if (unavailable_courses.length === 0) {
		$.each(window.courses, function(index, course) {
			mark_available_in_list(course.crn);
		})
	}

}

function compare_courses(course1, course2) {
	// returns 'conflict' else 'true'

	//Monday 
	if (course1.day2_start && course2.day2_start) {
		if (course1.day2_start == course2.day2_start) {
			return 'conflict';
		}
		if (course1.day2_start <= course2.day2_start && course1.day2_end > course2.day2_start ||
			course1.day2_start < course2.day2_end && course1.day2_end >= course2.day2_end) {
			//console.log(course1.course_name+' and '+course2.course_name+' overlap.');
			return 'conflict';
		}
		if (course2.day2_start <= course1.day2_start && course2.day2_end > course1.day2_start ||
			course2.day2_start < course1.day2_end && course2.day2_end >= course1.day2_end) {
			//console.log(course1.course_name+' and '+course2.course_name+' overlap.');
			return 'conflict';
		}
	}

	//Tuesday
	if (course1.day3_start && course2.day3_start) {
		if (course1.day3_start == course2.day3_start) {
			return 'conflict';
		}
		if (course1.day3_start <= course2.day3_start && course1.day3_end > course2.day3_start ||
			course1.day3_start < course2.day3_end && course1.day3_end >= course2.day3_end) {
			//console.log(course1.course_name+' and '+course2.course_name+' overlap.');
			return 'conflict';
		}
		if (course2.day3_start <= course1.day3_start && course2.day3_end > course1.day3_start ||
			course2.day3_start < course1.day3_end && course2.day3_end >= course1.day3_end) {
			//console.log(course1.course_name+' and '+course2.course_name+' overlap.');
			return 'conflict';
		}
	}

	//Weds
	if (course1.day4_start && course2.day4_start) {
		if (course1.day4_start == course2.day4_start) {
			return 'conflict';
		}
		if (course1.day4_start <= course2.day4_start && course1.day4_end > course2.day4_start ||
			course1.day4_start < course2.day4_end && course1.day4_end >= course2.day4_end) {
			//console.log(course1.course_name+' and '+course2.course_name+' overlap.');
			return 'conflict';
		}
		if (course2.day4_start <= course1.day4_start && course2.day4_end > course1.day4_start ||
			course2.day4_start < course1.day4_end && course2.day4_end >= course1.day4_end) {
			//console.log(course1.course_name+' and '+course2.course_name+' overlap.');
			return 'conflict';
		}
	}

	//Thurs
	if (course1.day5_start && course2.day5_start) {
		if (course1.day5_start == course2.day5_start) {
			return 'conflict';
		}
		if (course1.day5_start <= course2.day5_start && course1.day5_end > course2.day5_start ||
			course1.day5_start < course2.day5_end && course1.day5_end >= course2.day5_end) {
			//console.log(course1.course_name+' and '+course2.course_name+' overlap.');
			return 'conflict';
		}
		if (course2.day5_start <= course1.day5_start && course2.day5_end > course1.day5_start ||
			course2.day5_start < course1.day5_end && course2.day5_end >= course1.day5_end) {
			//console.log(course1.course_name+' and '+course2.course_name+' overlap.');
			return 'conflict';
		}
	}

	//Friday
	if (course1.day6_start && course2.day6_start) {
		if (course1.day6_start == course2.day6_start) {
			return 'conflict';
		}
		if (course1.day6_start <= course2.day6_start && course1.day6_end > course2.day6_start ||
			course1.day6_start < course2.day6_end && course1.day6_end >= course2.day6_end) {
			//console.log(course1.course_name+' and '+course2.course_name+' overlap.');
			return 'conflict';
		}
		if (course2.day6_start <= course1.day6_start && course2.day6_end > course1.day6_start ||
			course2.day6_start < course1.day6_end && course2.day6_end >= course1.day6_end) {
			//console.log(course1.course_name+' and '+course2.course_name+' overlap.');
			return 'conflict';
		}
	}

	//Test Finals Times Here. 


	return true; 
}



//triggered to go to next page
function next() {
	window.next_courses = '';
	count = 0;
	$.each(window.currentschedulearray, function(index, course){
		if (count > 0) {
			window.next_courses = window.next_courses + ',' + course.crn
		} else {
			window.next_courses = window.next_courses + course.crn
		}
		count++
	});

	var url_frag = 'schedules?courses='+next_courses;
	target = document.URL+url_frag;

	$.post(target, function(result){
		
	})

	window.location = '/schedules';
}





function test() {
	display_all_test();
	comparison_test();
}

function display_all_test() {
	console.log("Testing display of every single class. This may take a long time. ")
	var l = window.courses.length;
	var i=0;
	setInterval(function() {
		if (i<l) {
			addthisclass(window.courses[i]['crn']);
			i++
		}
	}, 1000)
}

function comparison_test() {
	//test for 

	var l = courses.length;
	for (i=0; i<l; i++) {

		//find all of the test classes we need
		if (courses[i]['crn'] == '45788') var foreign_relations = courses[i];
		if (courses[i]['crn'] == '43221') var humanrights = courses[i];
		if (courses[i]['crn'] == '41567') var mediation = courses[i];
		if (courses[i]['crn'] == '43219') var antitrust = courses[i];
		if (courses[i]['crn'] == '40948') var contracts = courses[i];
		if (courses[i]['crn'] == '44780') var crim = courses[i];
	}

	var test_name = 'Test Check Same Start Time for Conflict';
	if ('conflict' == compare_courses(antitrust, humanrights)) {
		console.log(test_name+' : PASSED.');
	} else {
		console.error(test_name+ ' : FAILED!');
		addthisclass(humanrights.crn);
		addthisclass(antitrust.crn);
	}

	var test_name = 'Test Check Same Start Time for Conflict (reversed)';
	if ('conflict' == compare_courses(humanrights, antitrust)) {
		console.log(test_name+' : PASSED.');
	} else {
		console.error(test_name+ ' : FAILED!');
		addthisclass(humanrights.crn);
		addthisclass(antitrust.crn);
	}

	var test_name = 'Test Class Times Overlap (mediation starts first)';
	if ('conflict' == compare_courses(mediation, foreign_relations)) {
		console.log(test_name+' : PASSED.');
	} else {
		console.error(test_name+ ' : FAILED!');
		addthisclass(mediation.crn);
		addthisclass(foreign_relations.crn);
	}

	var test_name = 'Test Class Times Overlap (course 2 (mediation) starts first)';
	if ('conflict' == compare_courses(foreign_relations, mediation)) {
		console.log(test_name+' : PASSED.');
	} else {
		console.error(test_name+ ' : FAILED!');
		addthisclass(mediation.crn);
		addthisclass(foreign_relations.crn);
	}

	var test_name = 'Test: Make sure compatible courses on the same day arent flagged as overlap.)';
	if ('conflict' !== compare_courses(mediation, contracts)) {
		console.log(test_name+' : PASSED.');
	} else {
		console.error(test_name+ ' : FAILED!');
		addthisclass(mediation.crn);
		addthisclass(contracts.crn);
	}

	var test_name = 'Test: Make sure compatible courses on the same day arent flagged as overlap (reversed).)';
	if ('conflict' !== compare_courses(contracts, mediation)) {
		console.log(test_name+' : PASSED.');
	} else {
		console.error(test_name+ ' : FAILED!');
		addthisclass(mediation.crn);
		addthisclass(contracts.crn);
	}

	var test_name = 'Test: Make sure compatible courses on different days but the same time arent flagged as overlap.)';
	if ('conflict' !== compare_courses(crim, mediation)) {
		console.log(test_name+' : PASSED.');
	} else {
		console.error(test_name+ ' : FAILED!');
		addthisclass(mediation.crn);
		addthisclass(crim.crn);
	}

	var test_name = 'Test: Make sure compatible courses on different days but the same time arent flagged as overlap (reversed).)';
	if ('conflict' !== compare_courses(mediation, crim)) {
		console.log(test_name+' : PASSED.');
	} else {
		console.error(test_name+ ' : FAILED!');
		addthisclass(mediation.crn);
		addthisclass(crim.crn);
	}

}

function mark_overlapped_on_schedule(course1) {
	$('.'+course1.crn+'').css({background: 'repeating-linear-gradient(45deg, #D63518, #D63518 10px, #D3C6AB 10px, #D3C6AB 20px)'});
	//$('.'+course2.crn+'').css({background: 'repeating-linear-gradient(45deg, #D63518, #D63518 10px, #D3C6AB 10px, #D3C6AB 20px)'});
}

function mark_non_overlapped_on_schedule(course) {
	$('.'+course.crn+'').css({background: random_color()});
}

function mark_unavailable_in_list(crn) {
	$( '#list_'+ crn +'' ).removeClass( "available_course" ).addClass( "unavailable_course" );
}

function mark_available_in_list(crn) {
	$( '#list_'+ crn +'' ).removeClass( "unavailable_course" ).addClass( "available_course" );
} 


