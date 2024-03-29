//
//
// If you can read this, we should be friends. Especially if you like Ruby
//

$( document ).on('page:change', function() {
	// prevent jquery from caching results - want new json from courses to update instantly.
	// $.ajaxSetup({ cache: false });

	//load courses.
	window.courses = null;

	//no currently selected courses
	window.currentschedulearray = {}; //set as an obj not an array

	//sessions/courses on the schedule that overlap / don't overlap
	window.conflicted_courses = [];
	window.unconflicted_courses = [];

	// Get the semester from server side (moving towards one-way data flow)
	// This should be value of semester_select field || get_variable || spring2016
	window.semester = parseInt( $("#semester_select").val() );

	//populate courses available
	load_courses(window.semester);

	//This next line only works in Chrome which is bullshit because it's amazing and needs
	//to work in Safari too. Safari sucks.
	// Object.observe(window.currentschedulearray, update_view);

	//searches
	$('#search_bar').keyup(function (e) {
		search_courses();
	});

	//handly any course plus button being clicked. ul must be static/extant when the page loads, whereas the li can be added dynamically later and this will still fire.
	$('body #classlisttarget').on('click', 'li .fa-plus-square', function(e) {
		var id = $(this).attr('id');

		if (e.shiftKey) {
			// if shift is held down, it means user is trying to flag this listing as incorrect.
        	c = confirm("Use the Feedback Link to Report Mistakes!");
        	if (c == true){

        		//flag_incorrect(id);
        	}
    	} else {
			addthisclass(id);
		}
	});

	//anytime an option is changed, filter immediately
	$( '.filter_option' ).on('change', function(e) {
		console.log('changd filter');
		search_courses();
	})

	$( '#semester_select' ).on('change', function(e) {
		console.log('changd semester');

		// clear the current schedule so no cross-semester schedules are created
		$.each(window.currentschedulearray, function(index, course){
			removecourse(index);
		})

		window.semester = semester = $('#semester_select').val();

		load_courses(semester);
	})

	// if the user has blocked ads....
 	$.ajax( "https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js" ).fail(function() {
 		//$( '#schedule-container' ).css( 'background', 'url("/td.jpg")' );
  })

})

//renders html for a course.
//goes right before the closing li below

function render_course_listing(course) {
	var html = '';
	var html = html + '<li style="overflow:hidden;" class="available_course" id="list_'+course.id+'">';
	var html = html + '<span class="fa fa-plus-square fa-2x" style="color:green;" alt="'+course.additional_info+'" id='+course.id+'></span>';
	var html = html + '<span class="classname">'+course.gwid+'-'+course.section+' '+course.course_name+'</span><span class="profname">'+course.professor+'</span>';
	var html = html + '<span class="ratings"><a href="https://my.law.gwu.edu/Evaluations/page%20library/ByFaculty.aspx?Source=%2fEvaluations%2fdefault.aspx&IID='+course.prof_id+'" target="_blank"><button class="GWU_btn"> GWU </button></a></span>';
	var html = html + '</li>';
	return html
}

function load_courses(semester) {
	semester = semester || window.semester;
	$.get("/api/courses/c.json?semester=" + semester, function(courses){
		window.courses = courses
		populate_course_list();
		check_for_loaded_schedule();
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

function check_for_loaded_schedule() {
	if (window.load_these) {
		$.each(window.load_these, function(index, course){
			addthisclass(course);
		})
	}
}

//shows/hides courses available based on search input
function search_courses() {
	var include_all = false;

	var term = $('#search_bar').val().toLowerCase();
	if ((term == null) || (term == "") || (term == undefined)) {
		// nothing in the box.
		var include_all = true;
	}

		$('#classlisttarget').empty();

		var monday = document.getElementById("monday").checked;
		var tuesday = document.getElementById("tuesday").checked;
		var wednesday = document.getElementById("wednesday").checked;
		var thursday = document.getElementById("thursday").checked;
		var friday = document.getElementById("friday").checked;
		var wknd = document.getElementById("wknd").checked;

		var h1 = document.getElementById("h1").checked;
		var h2 = document.getElementById("h2").checked;
		var h3 = document.getElementById("h3").checked;
		var h4 = document.getElementById("h4").checked;
		var hx = document.getElementById("hx").checked;

		$.each(window.courses, function(index, course) {

			term_match = (
				((course.course_name.toLowerCase().indexOf(term)) > -1) ||
				((course.professor.toLowerCase().indexOf(term)) > -1) ||
				((course.gwid.indexOf(term)) > -1)
				)

			match = (

				(
					(term_match || include_all)
				)

				&&

				(
					(wknd && course.day1_start) ||
					(monday && course.day2_start) ||
					(tuesday && course.day3_start) ||
					(wednesday && course.day4_start) ||
					(thursday && course.day5_start) ||
					(friday && course.day6_start) ||
					(wknd && course.day7_start) ||
							(course.day1_start == null &&
							course.day2_start == null &&
							course.day3_start == null &&
							course.day4_start == null &&
							course.day5_start == null &&
							course.day6_start == null &&
							course.day7_start == null) // If the course has NO hours set yet.
				)

				&&

				(
					(h1 && (course.hours == 1)) ||
					(h2 && (course.hours == 2)) ||
					(h3 && (course.hours == 3)) ||
					(h4 && (course.hours == 4)) ||
					(hx && (course.hours == "variable")) ||
					(hx && (course.hours < 1) || (course.hours > 4))
				)
			);

			//other options


			if (match) {
				//render
				html = render_course_listing(course);
				$('#classlisttarget').append(html);
			}
		})

}

function addthisclass(course_id) {
	var color = random_color();
	var id = course_id;

	//get course info from json using the course_id (id)
	var course = $.grep(window.courses, function(e){ return e.id == id; });
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
	var id = course['id'];
	window.currentschedulearray[id] = course;

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
	var jsclass = coursedata['id']; //how we remove all of the scheduled classes @ once.

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
			var html = get_hours_html();
			$('#hours_total').html(html);

		window.courses_exist = false;
		$.each(window.currentschedulearray, function(index, course){
			var id = index;
			// console.log('index: '+index);
			// console.info(course);
			if (course.final_date == null) { course.final_date = 'date unknown'; }
			if ( (course.final_time == null) && (course.final_date != null) ) { course.final_time = 'time TBD'; }
			if (course.final_time == null) { course.final_time = ', time unknown'; }
			var html = '';
			var html = html+ '<li>';
			var html = html+ '<span class="fa fa-remove fa-2x" style="color:red;" onclick=removecourse('+course.id+')></span>';
			var html = html+ '<span class="classname">'+course.course_name+', </span>';
			var html = html+ '<span class="profname"> '+course.professor+'</span>';
			var html = html+ '<span class="chosen_hours"> , '+course.hours+' hours </span>';
			var html = html+ '<span class="chosen_hours"> Final: '+course.final_date+'</span>';
			var html = html+ ' <span class="chosen_hours">'+course.final_time+'</span>';
			var html = html+ '</li>';
			$('#chosenclasseslist').append(html);
			window.courses_exist = true;
		});

		//append the 'next button to the classlist'
		if (window.courses_exist) {
			var html = '';
			var html = html + '<li id="next_btn" class="btn btn-lg btn-primary" onclick="next()">Save & See Booklist</li>';
			$('#chosenclasseslist').append(html);
		}

		//update striped classes etc.
		check_schedule_conflicts();

	} else {
		$('#chosenclasseslist').empty();
	}
}

var get_hours_html = function () {
	window.hours = 0;
	window.variable_hours = false;
	$.each(window.currentschedulearray, function(index, course){
		if (course.hours !== 'variable') {
			window.hours = window.hours + parseInt(course.hours);
		} else {
			window.variable_hours = true;
		}
	});

	var html = '';
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

	return html
}

//this is rough and probably can be optimized
function check_schedule_conflicts() {
	var selected_courses = window.currentschedulearray;
	selected = []
	for (var key in selected_courses) {
		selected.push(selected_courses[key]);
	}

	// conflicted_courses = window.conflicted_courses;


	//this makes the minimum number of comparisons :) :) :)
	for (i=0; i<selected.length; i++) {
		if (selected.length < 2) {
			window.conflicted_courses = [];
			$.each(selected_courses, function (index, unconflicted_course) {
				mark_non_overlapped_on_schedule(unconflicted_course);
			})
			continue;
		}
		var course1 = selected.shift();
		for (a=0; a<selected.length; a++) {
			var course2 = selected[a];
			if ('conflict' == compare_courses(course1, course2)) {
				window.conflicted_courses.push(course1);
				window.conflicted_courses.push(course2);
			}
		}
	}

	//make the overlapping courses white/red slashed in color
	$.each(window.conflicted_courses, function (index, conflicted_course) {
		mark_overlapped_on_schedule(conflicted_course);
	})


	//gray out the courses on the list that are incompatible with the classes currently chosen.
	unavailable_courses = [];
	$.each(window.courses, function(index1, course1) {
		$.each(window.currentschedulearray, function(index2, course2) {
			if ("conflict" == compare_courses(course1, course2)) {
				unavailable_courses.push(course1.id);
			} else {
				mark_available_in_list(course1.id);
			}
		})
	})

	$.each(unavailable_courses, function(index, id) {
		mark_unavailable_in_list(id);
	})

	if (unavailable_courses.length === 0) {
		$.each(window.courses, function(index, course) {
			mark_available_in_list(course.id);
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
			window.next_courses = window.next_courses + ',' + course.id
		} else {
			window.next_courses = window.next_courses + course.id
		}
		count++
	});

	var url_frag = '/schedules?courses='+next_courses;
	target = url_frag;
	console.log('url frag: '+url_frag);

	$.post(target, function(result){
		console.log('adding courses post call returned: ' + result);
		window.location = '/schedules';
	})
}

// Usage: geturlvar()["variable name"];
// e.g. var page = geturlvar()["page"] www.example.com/?page=21
function geturlvar() {
	var vars = {};
	var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
	vars[key] = value;
	});
	return vars;
}

function test() {
	display_all_test();
}

function display_all_test() {
	var l = window.courses.length;
	console.log("Testing display of every single class. This may take a long time. ");
	console.log("It will take: " + l*500 + " Seconds ");
	var i=0;
	setInterval(function() {
		if (i<l) {
			addthisclass(window.courses[i]['id']);
			i++
		}
	}, 500)
}

function mark_overlapped_on_schedule(course1) {
	$('.'+course1.id+'').css({background: 'repeating-linear-gradient(45deg, #D63518, #D63518 10px, #FFF 10px, #FFF 20px)'});
	//$('.'+course2.id+'').css({background: 'repeating-linear-gradient(45deg, #D63518, #D63518 10px, #D3C6AB 10px, #D3C6AB 20px)'});
}

function mark_non_overlapped_on_schedule(course) {
	$('.'+course.id+'').css({background: random_color()});
}

function mark_unavailable_in_list(id) {
	$( '#list_'+ id +'' ).removeClass( "available_course" ).addClass( "unavailable_course" );
}

function mark_available_in_list(id) {
	$( '#list_'+ id +'' ).removeClass( "unavailable_course" ).addClass( "available_course" );
}
