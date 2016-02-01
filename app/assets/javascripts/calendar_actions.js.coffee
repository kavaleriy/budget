# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.erb.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:change', ->

# For selection type fa-icon, color-text and color-background
#-----------------------------------------------------------------
  formatFaSelect = (el) ->
    '<i class=\'fa ' + el.id + '\'/> ' + el.id

  formatColorSelect = (el) ->
    '<div style=\'width: 100%; height: 43px; background-color: ' + el.id + '\'/>'

  $('.fa-select').select2
    allowClear: true
    formatResult: formatFaSelect
    formatSelection: formatFaSelect
    escapeMarkup: (m) ->
      m
  $('.color-select').select2
    allowClear: true
    formatResult: formatColorSelect
    formatSelection: formatColorSelect
    escapeMarkup: (m) ->
      m