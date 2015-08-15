# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'page:change', ->

  # For the booklist suggestion part
  insert_course = (data) ->
    $('#title').html "#{data[0].course_name} - #{data[0].professor}" unless jQuery.isEmptyObject(data)
    $('#current_isbn_list_div').html "Already have these books: #{data[0].isbn} #{data[0].pinned_isbn}" unless jQuery.isEmptyObject(data)
    $('.other_feedback_div').slideUp 800
    return

    # Ajax calls
  $('#booklistsuggestion_section,#booklistsuggestion_crn').blur ->
    section = $('#booklistsuggestion_section').val()
    gwid = $('#booklistsuggestion_gwid').val()
    crn = $('#booklistsuggestion_crn').val()
    console.log(gwid, section)
    callback = (response) -> insert_course response
    $.get '/addtobooklist/get_course/', {gwid, section, crn}, callback, 'json'
    return

  # For the rest of the feedback form
  insert_course_name = (data) ->
    $('#course_name').html "#{data[0].course_name} - #{data[0].professor}" unless jQuery.isEmptyObject(data)
    $('.add_missing_book_div').slideUp 300
    return

  # Ajax calls
  $('#feedback_section,#feedback_crn').blur ->
    section = $('#feedback_section').val()
    gwid = $('#feedback_gwid').val()
    crn = $('#feedback_crn').val()
    console.log(gwid, section)
    callback = (response) -> insert_course_name response
    $.get '/addtobooklist/get_course/', {gwid, section, crn}, callback, 'json'
    return
