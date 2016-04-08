/**
 * Created by alex on 04.04.16.
 */
function init_town_typeahead(url){
    var typeahead_count = 2;
    $('#user_town').typeahead({
        minLength: typeahead_count,
        source: function (query, process) {
            return $.get(url, { query: $('#user_town').val() }, function (json) {
                var data = [];
                $.each(json,function(i,name){
                    data.push(name.text);
                });
                return process(data)
            },'json');
        }, highlighter: function(item) {
            return item;
        }
    });
}
