# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).ready ->

  # initialize the calendar
  #	-----------------------------------------------------------------
  $('#calendar').fullCalendar
    lang: 'uk',
    editable: false,
    header:
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaDay'
    defaultView: 'month',
    events: {
      url: '/events',
    },
    timeFormat: 'H:mm',

    droppable: false

    selectable: false

    eventClick: (calEvent, jsEvent, view) ->
      $.get("/events/"+calEvent.id).done (data) ->
        $("#eventModal .modal-content").html data
        $('#eventModal').modal('show')

    eventRender: (e, t, n) ->
      icon = (if e.icon then e.icon else "")
      i = (if e.description then e.description else "")
      t.find(".fc-event-title").before $("<span class=\"fc-event-icons\"></span>").html(icon)
      t.find(".fc-event-title").append "<br><small data-toggle='tooltip' data-placement='top' title='Tooltip'>" + i + "</small>"
      return
