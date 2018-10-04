/**
 * Created by serhii on 01.10.18.
 */

function ChartUnit() {
    this.rates = {};
    var that = this;
    function initRates(){

        $.ajax({
            type: "GET",
            url: "/by_currency/USD",
            dataType: "json",
            success: function(json) {
                that.rates = json;
            }
        })
    }

    this.data_by_unit = function(data, years){
        var selected_unit = $('#_amount_select').val();
        var arr;

        switch (selected_unit) {
            case 'uah':
                arr = data;
                break;
            case 'usd':
                this.set_unit('тис.дол.')
                arr = this.per_dollar(data, years);
                break;
            case 'citizens':
                this.set_unit('грн. на одного мешканця')
                arr = this.per_citizens(data);
                break;
            default:
                arr = data;
        }

        return arr;
    }

    this.per_dollar  = function(data, years){
        var rate = this.rates;

        var data_chart = [];

        $.each(data, function(key, value) {
            data_chart.push(value / rate[years[key]]);
        });

        return data_chart;
    }

    this.per_citizens = function(data){
        var count = parseInt($('#_amount_select').attr('data-town-citizens'));

        // thousands of hryvnia to the hryvnia
        return data.map(x => x * 1000 / count);
    }

    this.set_unit = function(unit){
        $(
            '#form_1.tab-pane.active .chart .unit, ' +
            '#form_2.tab-pane.active .chart .unit, ' +
            '#compare.tab-pane.active #code-unit'
        ).text(unit);
    }

    initRates();
}
