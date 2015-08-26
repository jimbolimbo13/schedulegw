# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).on 'page:change', ->

  $('#popular_courses_header').click ->
    $('#popular_courses_div').slideToggle 'slow'
    return

  $('#all_courses_header').click ->
    $('#all_courses_div').slideToggle 'slow'
    return
