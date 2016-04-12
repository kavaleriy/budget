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

function init_town_select2(url){

    $('#user_town').select2({
        sortResults: function(results, container, query) {
            if (query.term) {
                // use the built in javascript sort function
                return results.sort(function(a, b) {
                    if (a.text.length > b.text.length) {
                        return 1;
                    } else if (a.text.length < b.text.length) {
                        return -1;
                    } else {
                        return 0;
                    }
                });
            }
            return results;
        },
        allowClear: false,
        multiSelect: false,
        multiple: false,
        minimumInputLength: 2,
        width: '100%',
        ajax: {
            url: url,
            dataType: 'json',
            quietMillis: 250,
            data: function (term, page) {
                return {
                    query: term, // search term
                };
            },
            results: function (data, page) {
                var resArr = [];
                for(var i = 0; i < data.length;i++) {
                    var arr = {};
                    arr['id'] = data[i].text;
                    arr['text'] = data[i].text;
                    resArr.push(arr);
                }
                return { results: resArr };
            },
            cache: true
        },
    })
}
