# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).on 'ready page:load', ->
  # initialize the calendar
  #	-----------------------------------------------------------------
  $('#calendar_view').fullCalendar
    lang: 'uk',
    editable: false,
    header:
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaDay'
    defaultView: 'month',
    events: {
      url: '/events',
      data: {
        calendar_id: $('#calendar_view').attr('calendar_id')
      }
    },
    timeFormat: 'H:mm',

    droppable: false

    selectable: false

    eventClick: (calEvent, jsEvent, view) ->
      $.get "/events/"+calEvent.id,
        calendar_id: $('#calendar_view').attr('calendar_id')

    eventRender: (e, t, n) ->
      t.css('color', e.text_color)
      icon = (if e.icon then " <i class='fa fa-lg " + e.icon + " '></i> " else "")
      i = (if e.description then e.description else "")
      t.find(".fc-event-title").before $("<span class=\"fc-event-icons\"></span>").html(icon)
      t.find(".fc-event-title").append "<br><small data-toggle='tooltip' data-placement='top' title='Tooltip'>" + i + "</small>"
      return

