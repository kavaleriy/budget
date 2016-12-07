function aEmbedCode() {

    var el_id, width, height, src, k,
        min_width, min_height,
        max_width, max_height;

    function reset() {
        $(el_id).find('input').val("<iframe width='100%' height=" + height + " src='" + src + "' " + screen_full + "></iframe>");
        $(el_id + ' .iframe_other_size').html('');
        $(el_id).find('.iframe_size_select').html("<option value=\"min\">" + min_width + "x" + min_height + "</option>\
                                                 <option value=\"default\" selected>100%x" + height + "</option>" +
            "<option value=\"max\">" + max_width + "x" + max_height + "</option>\
                                                 <option value=\"other\">" + I18n.t('iframe.size') + "</option>")
    }

    return {
        initialize: function(options) {
            screen_full = options.screen_full;
            width = options.width;
            min_width = width - 300;
            max_width = width + 300;
            height = options.height;
            min_height = height - 300;
            max_height = height + 300;
            el_id = options.el_id;
            src = options.src;
            k = width/height;

            reset();

            $(el_id + ' .embed_btn').find('[data-toggle="popover"]').popover({
                html: true,
                placement : 'left',
                title: I18n.t('embed'),
                content: function() {
                    var content = "";
                    $(el_id).find('input').val("<iframe width='100%' height=" + height + " src='" + src + "'></iframe>")
                    if(el_id != "#embed_code_timeline") {
                        $(el_id).find('.iframe_size_select').html("<option value=\"min\">" + min_width + "x" + min_height + "</option>\
                                                         <option value=\"default\" selected>100%x" + height + "</option>" +
                            "<option value=\"max\">" + max_width + "x" + max_height + "</option>\
                                                         <option value=\"other\">" + I18n.t('iframe.size') + "</option>")
                        $(el_id).find('.iframe_other_size').html("");
                        content = $(el_id + ' .form-horizontal');
                    } else {
                        content = $(el_id + ' input');
                    }
                    return content;
                }
            })

            // hide popover if click outside
            $('body').on('click', function (e) {
                $('[data-toggle="popover"]').each(function () {
                    //console.log(1);
                    //the 'is' for buttons that trigger popups
                    //the 'has' for icons within a button that triggers a popup
                    if (!$(this).is(e.target) && $(this).has(e.target).length === 0 && $('.popover').has(e.target).length === 0) {
                        $(this).popover('hide');
                    }
                });
            });

            $(document.body).on('shown.bs.popover', function () {
                reset();

                $(el_id + ' .iframe_size_select').change(function(e) {
                    var option = $(this).find(":selected").val();
                    if(option == "other" && $('.iframe_other_size').text() == "") {
                        $(el_id + ' .iframe_other_size').html("<input autofocus type=\"number\" min=\"100\" max=\"1000\" step=\"1\" name=\"width\" placeholder=\"width\"'></input> X \
                                                         <input type=\"number\" min=\"100\" max=\"1000\" step=\"1\" name=\"height\" placeholder=\"height\"'></input> px");
                    } else if (option != "other") {
                        $(el_id + ' .iframe_other_size').html('');
                        var size = $(this).find(":selected").text().split("x");
                        var width = size[0];
                        var height = size[1];
                        $(el_id + ' input').val("<iframe width='" + width + "' height='" + height + "' src='" + src + "'></iframe>");
                    }
                })

                // function to dynamically fill the embed code with indicator_file width and height
                $(el_id + ' .iframe_other_size').on('focusout', 'input', function(event){
                    var curr_value = $(this).val();
                    var curr_field = $(this).attr('name');

                    var sibling_value = $(this).siblings().val();
                    var width, height;

                    if(sibling_value != "") {
                        if(!$.isNumeric(curr_value) || curr_value < (curr_field == "width" ? min_width : min_height)) {
                            curr_field == "width" ? width = min_width : height = min_height;
                        } else if(curr_value > (curr_field == "width" ? max_width : max_height)) {
                            curr_field == "width" ? width = max_width : height = max_height;
                        } else {
                            curr_field == "width" ? width = curr_value : height = curr_value;
                        }
                        curr_field == "width" ? height = width/k : width = height*k;
                        $(this).siblings().val(curr_field == "width" ? height : width);
                        $(el_id + ' input').val("<iframe width='" + width + "' height='" + height + "' src='" + src + "'></iframe>");
                    }

                });
            })

            //$(el_id + " input").on("click", function () {
            //    console.log(2);
            //    $(this).select();
            //});
        },
        set_iframe: function(new_src) {
            src = new_src;
            reset();
        }
    }
}