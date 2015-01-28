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
//= require fullcalendar/en

//= require timecircles

//= require d3
//= require d3.slider

//= require select2
//= require select2_locale_uk

//= require fileupload/jquery.fileupload
//= require fileupload/jquery.fileupload-process
//= require fileupload/jquery.fileupload-validate
// This is optional (in case you have `I18n is not defined` error)
// If you want to put this line, you must put it BEFORE `i18n/translations`
//= require i18n
//
// This is a must
//= require i18n/translations
//= require_tree .


$(document).on('ready page:change', function() {
    $(".bootstrap_flash").delay(10000).fadeOut(200);
})

$(document).on('ready page:change', function() {
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


$(document).on('ready page:change', function() {
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
