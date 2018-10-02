/**
 * Created by serhii on 01.10.18.
 */

class ChartUnit {
    constructor() {
        this.rates = this.exchange_rates();
    }

    data_by_unit(data, years){
        var selected_unit = $('#_amount_select').val();
        var arr;

        switch (selected_unit) {
            // per UAH
            case '1':
                arr = data;
                break;
            // per USD
            case '2':
                this.set_unit('тис.дол.')
                arr = this.per_dollar(data, years);
                break;
            // per citizens
            case '3':
                this.set_unit('грн. на одного мешканця')
                arr = this.per_citizens(data);
                break;
            default:
                arr = data;
        }

        return arr;
    }

    // set USD unit
    per_dollar(data, years){
        var rate = this.rates;
        var data_chart = [];

        $.each(data, function(key, value) {
            data_chart.push(value / rate[years[key]]);
        });

        return data_chart;
    }

    // set per citizen unit
    per_citizens(data){
        var count = parseInt($('#_amount_select').attr('data-town-citizens'));

        // thousands of hryvnia to the hryvnia
        return data.map(x => x * 1000 / count);
    }

    // get USD rates from db
    exchange_rates(){
        var data;
        $.ajax({
            type: "GET",
            url: "/by_currency/USD",
            dataType: "json",
            async: false,
            success: function(json) {
                data = json;
            }
        });

        return data;
    }

    // set unit for each chart
    set_unit(unit){
        $(
            '#form_1.tab-pane.active .chart .unit, ' +
            '#form_2.tab-pane.active .chart .unit, ' +
            '#compare.tab-pane.active #code-unit'
        ).text(unit);
    }
}
