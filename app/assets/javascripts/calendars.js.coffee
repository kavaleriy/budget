# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:change', ->

  # initialize the external events
  #-----------------------------------------------------------------
  $(".external-events div.external-event").each ->
    eventObject =
      title: $.trim($(this).attr("data-title"))
      icon: $.trim($(this).attr("data-icon"))
      description: $(this).attr("data-description")
      text_color: $(this).attr("data-text_color")
      color: $(this).attr("data-color")
      holder: $(this).attr("data-holder")

    $(this).data "eventObject", eventObject
    $(this).draggable
      zIndex: 999
      revert: true
      revertDuration: 0

    return


  # initialize the calendar
  #	-----------------------------------------------------------------

  $('#calendar').fullCalendar
    lang: window.aHelper.lang(),
    editable: true,
    header:
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaDay'
    defaultView: 'month',
    events: {
      url: $('#calendar').attr('calendar_id') + '/events',
#        data: {
#          calendar_id:
#        }
    },
#        timezone: false,
#        ignoreTimezone: true,
    timeFormat: 'H:mm',
    dragOpacity: "0.35"

    droppable: true
    drop: (date) ->
      originalEventObject = $(this).data("eventObject")
      copiedEventObject = $.extend({}, originalEventObject)
      # assign it the date that was reported
      copiedEventObject.start = date
      copiedEventObject.allDay = true

      createEvent(copiedEventObject)
      return

    selectable: true
    selectHelper: true
    select: (start, end, allDay) ->
      dt_start = moment(start).format("DD/MM/YYYY")

      $.get $('#calendar').attr('calendar_id') + "/events/new",
        starts_at: dt_start
        ends_at: dt_start
        all_day: true
#          .done (data) ->
#            $("#eventModal .modal-content").html data
#            $('#eventModal').modal('show')

#            calendar.fullCalendar('unselect');

    eventClick: (calEvent, jsEvent, view) ->
      $.get $('#calendar').attr('calendar_id') + "/events/"+calEvent.id+"/edit"
#        .done (data) ->
#          $("#eventModal .modal-content").html data
#          $('#eventModal').modal('show')

    eventRender: (e, t, n) ->
      icon = (if e.icon then " <i class='fa " + e.icon + " '></i> " else "")
      i = (if e.description then e.description else "")

      t.css('color', e.text_color) if (e.color)

      t.find(".fc-event-title").before $("<span class=\"fc-event-icons\"></span>").html(icon)
      #          t.find(".fc-event-title").append "<br><small data-toggle='tooltip' data-placement='top'>" + i + "</small>"
      return

    eventResize: (event, dayDelta, minuteDelta, revertFunc) ->
      updateEvent(event);

    eventDrop: (event, dayDelta, minuteDelta, allDay, revertFunc) ->
      updateEvent(event);


  createEvent = (event) ->
    dt_start = (if event.start? then moment(event.start).format("YYYY-MM-DDTHH:mm:ss") else "")
    dt_end = (if event.end? then moment(event.end).format("YYYY-MM-DDTHH:mm:ss") else "")
    $.ajax
      url: $('#calendar').attr('calendar_id') + "/events"
      type: 'POST'
      dataType: 'json'
      data:
        event:
          icon: event.icon
          title: event.title
          description: event.description
          text_color: event.text_color
          color: event.color
          starts_at: dt_start
          ends_at: dt_end
          all_day: event.allDay
          holder: event.holder
    .success (data) ->
      event.id = data.id
      #      $("#calendar").fullCalendar "renderEvent", event, true
      $("#calendar").fullCalendar "refetchEvents"

  updateEvent = (event) ->
    dt_start = (if event.start? then moment(event.start).format("YYYY-MM-DDTHH:mm:ss") else "")
    dt_end = (if event.end? then moment(event.end).format("YYYY-MM-DDTHH:mm:ss") else "")

    $.ajax
      url: $('#calendar').attr('calendar_id') + "/events/" + event.id
      type: 'PUT'
      dataType: 'json'
      data:
        event:
          starts_at: dt_start,
          ends_at: dt_end,
          all_day: event.allDay,
          text_color: event.text_color
          color: event.color
    .success ->

  $('#eventModal').on "ajax:success", 'form',  (e, data, status, xhr) ->
    $("#calendar").fullCalendar "refetchEvents"
    $('#eventModal').modal('hide')
  $('#eventModal').on "ajax:error", 'form',  (e, data, status, xhr) ->
#    if $('event_title').val()
    eval('err=' + data.responseText)
    if err.title
      I18n.locale = document.location.href.split("locale=")[1]
      alert(I18n.t("calendars_err.title") + err.title[0])
    else if err.holder
      alert(I18n.t("calendars_err.owner") + err.holder[0])
    else
      alert(I18n.t("calendars_err.save_error") + data.responseText)
    err = 'null'