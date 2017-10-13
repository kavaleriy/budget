/**
 * Created by sergii on 13/10/17.
 */

$("#spinner-container").on('spinner:run', function(){
    $("#spinner-container").show();
})
$("#spinner-container").on('spinner:stop', function(){
    $("#spinner-container").hide();
})