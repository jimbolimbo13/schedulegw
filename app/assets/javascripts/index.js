// 
// 
// If you can read this, we should be friends. Especially if you like Ruby
// 


$( document ).ready(function() {
	//load courses.
	window.courses = null; 
	populate_course_list();

	//searches 
	$('#search_bar').keyup(function (e) {
		var terms = $('#search_bar').val();
		console.log('term: '+terms);
		if ((terms == null) || (terms == "") || (terms == undefined)) {
			//nothing in the box. 
			populate_course_list();
		} else {
			$('#classlisttarget').empty();
	    	search_courses(terms);
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

