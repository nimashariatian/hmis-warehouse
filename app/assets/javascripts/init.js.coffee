#= require namespace
App.init = ->
  $('abbr').tooltip();
  $('[data-toggle="tooltip"]').tooltip();
  $('[data-toggle="popover"]').popover();
  $.fn.datepicker.defaults.format = "M d, yyyy";
  $('.nav-tabs .active-tab').on 'click', 'a', (e)->
    e.preventDefault()
  return true

# TODO may also need to do on pjax_modal change
$ ->
  App.init()