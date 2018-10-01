/**
 * Created by serhii on 01.10.18.
 */

function data_by_select(data){
    selected_unit = $('#_amount_select').val();
    switch (selected_unit) {
        // per UAH
        case '1':
            arr = data;
            break;
        // per USD
        case '2':
            set_unit('тис.дол.')
            arr = per_dollar(data);
            break;
        // per citizens
        case '3':
            set_unit('грн. на одного мешканця')
            arr = per_citizens(data);
            break;
        default:
            arr = data;
    }

    return arr;
}

function set_unit(unit){
    $('.chart .unit').text(unit);
}

function per_dollar(data){
    var count = parseInt($('#_amount_select').attr('data-town-citizens'));

    return data.map(x => x * 100 / count);
}

function rates(){
    var data;
    $.ajax({
        type: "GET",
        url: "/by_currency/USD",
        dataType: "json",
        cache: true,
        // data: { unit: 'USD' },
        success: function(json) {
            console.log('jsonaaaaa');
            data = json;
            // alert(I18n.t('success_destroy'));
        }
    });

    return data;
}


function per_citizens(data){
    var count = parseInt($('#_amount_select').attr('data-town-citizens'));

    return data.map(x => x * 1000 / count);
}
