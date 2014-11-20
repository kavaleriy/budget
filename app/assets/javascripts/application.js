// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all

//= require twitter/bootstrap
//= require turbolinks

//= require moment
//= require moment/uk.js
//= require fullcalendar/fullcalendar.min
//= require fullcalendar/uk

//= require timecircles

//= require d3

//= require select2
//= require select2_locale_uk

//= require fileupload/jquery.fileupload
//= require fileupload/jquery.fileupload-process
//= require fileupload/jquery.fileupload-validate

//= require_tree .


$(document).on('ready page:load', function() {
    $(".bootstrap_flash").delay(3000).fadeOut(200);
})

$(document).on('ready page:load', function() {
    $(".fa-select").select2(
        {
            allowClear: true,
            formatResult: formatFaSelect,
            formatSelection: formatFaSelect,
            escapeMarkup: function(m) { return m; }
        }
    );

    function formatFaSelect(el) {
        return "<i class='fa " + el.id + "'/> " + el.id;
    }
});


$(document).on('ready page:load', function() {
    $(".color-select").select2(
        {
            allowClear: true,
            formatResult: formatColorSelect,
            formatSelection: formatColorSelect,
            escapeMarkup: function(m) { return m; },
        }
    );

    function formatColorSelect(el) {
        return "<div style='width: 100%; height: 30px; background-color: " + el.id + "'/>";
    }
});
